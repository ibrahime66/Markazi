<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ActivityLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

/**
 * CDC §8.2 / §21 — logo du Markaz, réutilisé sur les documents générés
 * (reçus, rapports). Jusqu'ici la colonne `markaz.logo_path` existait sans
 * aucun moyen de l'alimenter.
 *
 * Stockage sur le disque privé : le logo n'est servi qu'aux utilisateurs
 * authentifiés du même Markaz (isolation multi-tenant, CDC §16), via
 * GET /api/markaz/logo. Le chemin est toujours fixé par le serveur, jamais
 * fourni par le client.
 */
class MarkazLogoController extends Controller
{
    private const DIRECTORY = 'logos';

    public function store(Request $request)
    {
        $markaz = $request->user()->markaz()->firstOrFail();
        $this->authorize('update', $markaz);

        $request->validate([
            // PNG/JPEG uniquement (seuls formats lus par le moteur PDF de
            // l'app) ; 2 Mo maximum, l'app réduit l'image avant l'envoi (§25).
            'logo' => ['required', 'image', 'mimes:png,jpg,jpeg', 'max:2048'],
        ]);

        $file = $request->file('logo');
        $path = $file->storeAs(
            self::DIRECTORY,
            "markaz-{$markaz->id}-".Str::random(12).'.'.$file->extension(),
            'local',
        );

        $this->deleteStoredLogo($markaz->logo_path);
        $markaz->update(['logo_path' => $path]);

        ActivityLog::record('markaz.updated', $markaz, 'Logo du Markaz mis à jour');

        return response()->json($markaz->fresh());
    }

    public function show(Request $request)
    {
        $markaz = $request->user()->markaz()->firstOrFail();
        $this->authorize('view', $markaz);

        $path = $markaz->logo_path;
        if (! $this->isManagedPath($path) || ! Storage::disk('local')->exists($path)) {
            abort(404);
        }

        return Storage::disk('local')->response($path);
    }

    public function destroy(Request $request)
    {
        $markaz = $request->user()->markaz()->firstOrFail();
        $this->authorize('update', $markaz);

        $this->deleteStoredLogo($markaz->logo_path);
        $markaz->update(['logo_path' => null]);

        ActivityLog::record('markaz.updated', $markaz, 'Logo du Markaz supprimé');

        return response()->json($markaz->fresh());
    }

    /** Seuls les fichiers déposés par cette route sont servis ou supprimés. */
    private function isManagedPath(?string $path): bool
    {
        return is_string($path)
            && str_starts_with($path, self::DIRECTORY.'/')
            && ! str_contains($path, '..');
    }

    private function deleteStoredLogo(?string $path): void
    {
        if ($this->isManagedPath($path)) {
            Storage::disk('local')->delete($path);
        }
    }
}
