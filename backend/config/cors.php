<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    |
    | Here you may configure your settings for cross-origin resource sharing
    | or "CORS". This determines what cross-origin operations may execute
    | in web browsers. You are free to adjust these settings as needed.
    |
    | To learn more: https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
    |
    */

    // doc/audit.md, point C4 : cette API est consommée par un token Bearer
    // (Sanctum), jamais par un cookie de session — il n'y a donc pas de
    // risque CSRF à autoriser toute origine ici (`supports_credentials`
    // reste à false : aucun cookie n'est jamais envoyé cross-origin).
    // Si un futur tableau de bord web (CDC §29) doit restreindre l'origine,
    // remplacer '*' par [env('FRONTEND_URL', 'http://localhost:3000')].
    'paths' => ['api/*', 'sanctum/csrf-cookie'],

    'allowed_methods' => ['*'],

    'allowed_origins' => ['*'],

    'allowed_origins_patterns' => [],

    'allowed_headers' => ['*'],

    'exposed_headers' => [],

    'max_age' => 0,

    'supports_credentials' => false,

];
