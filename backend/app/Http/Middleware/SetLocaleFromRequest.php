<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\App;
use Symfony\Component\HttpFoundation\Response;

/**
 * doc/audit.md, point K8 — l'app est disponible en français, anglais et
 * arabe : elle envoie sa langue active dans l'en-tête `Accept-Language`, et
 * les messages du serveur (validation, erreurs, emails) suivent cette
 * langue. Toute autre langue, ou l'absence d'en-tête, garde la langue par
 * défaut de l'application (français, CDC §7.2).
 */
class SetLocaleFromRequest
{
    public const SUPPORTED = ['fr', 'en', 'ar'];

    public function handle(Request $request, Closure $next): Response
    {
        $header = (string) $request->header('Accept-Language', '');
        // Premier élément de la liste ("en-US,en;q=0.9" -> "en").
        $language = strtolower(substr(trim(explode(',', $header)[0]), 0, 2));

        if (in_array($language, self::SUPPORTED, true)) {
            App::setLocale($language);
        }

        return $next($request);
    }
}
