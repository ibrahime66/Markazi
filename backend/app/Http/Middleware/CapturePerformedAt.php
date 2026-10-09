<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Symfony\Component\HttpFoundation\Response;

/**
 * CDC §20 / §27 — mode hors ligne. Quand l'app rejoue une action saisie hors
 * ligne, elle envoie l'en-tête `X-Performed-At` (date ISO 8601 de l'action
 * réelle). Cette date est exposée aux contrôleurs via l'attribut de requête
 * `performed_at`, utilisé par ActivityLog pour :
 *  - dater l'entrée de journal à la date réelle de l'action ;
 *  - détecter un conflit (ressource modifiée côté serveur après l'action).
 *
 * Valeur ignorée (requête traitée normalement) si elle est illisible, dans
 * le futur (au-delà d'une tolérance d'horloge de 5 minutes) ou plus vieille
 * qu'un an — l'horloge d'un téléphone n'est pas une source de confiance.
 */
class CapturePerformedAt
{
    public function handle(Request $request, Closure $next): Response
    {
        $header = $request->header('X-Performed-At');

        if (is_string($header) && $header !== '') {
            try {
                $performedAt = Carbon::parse($header);
                $now = Carbon::now();

                if ($performedAt->lte($now->copy()->addMinutes(5))
                    && $performedAt->gte($now->copy()->subYear())) {
                    $request->attributes->set('performed_at', $performedAt->min($now));
                }
            } catch (\Throwable) {
                // En-tête invalide : ignoré, la requête est traitée comme une
                // action en ligne classique.
            }
        }

        return $next($request);
    }
}
