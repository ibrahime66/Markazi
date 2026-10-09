<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        // Cette API n'a aucune route web nommée "login" (pas d'interface web,
        // uniquement du JSON) : sans ceci, une requête non authentifiée qui
        // n'envoie pas explicitement "Accept: application/json" fait planter
        // le middleware d'auth en 500 (RouteNotFoundException) au lieu de
        // renvoyer un 401 propre, car Laravel tente par défaut de rediriger
        // vers route('login') (doc/audit.md, point E2 — bug découvert en
        // écrivant les tests automatisés d'authentification).
        $middleware->redirectGuestsTo(fn () => null);

        // CDC §20 / §27 (doc/audit.md, point F5) : date réelle d'une action
        // rejouée après une période hors ligne (en-tête X-Performed-At).
        $middleware->api(append: [\App\Http\Middleware\CapturePerformedAt::class]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $request->is('api/*') || $request->expectsJson(),
        );
    })->create();
