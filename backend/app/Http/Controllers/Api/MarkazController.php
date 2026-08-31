<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\MarkazRequest;
use App\Models\ActivityLog;
use Illuminate\Http\Request;

/**
 * CDC section 8.2 / 17 — GET/PUT /api/markaz : fiche du Markaz courant.
 * L'identifiant du Markaz n'est jamais pris depuis le client : il est
 * toujours dérivé de l'utilisateur authentifié (CDC section 16).
 */
class MarkazController extends Controller
{
    public function show(Request $request)
    {
        $markaz = $request->user()->markaz()->firstOrFail();
        $this->authorize('view', $markaz);

        return response()->json($markaz);
    }

    public function update(MarkazRequest $request)
    {
        $markaz = $request->user()->markaz()->firstOrFail();
        $this->authorize('update', $markaz);

        $markaz->update($request->validated());

        ActivityLog::record('markaz.updated', $markaz, 'Mise à jour de la fiche Markaz');

        return response()->json($markaz);
    }
}
