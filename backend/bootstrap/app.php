<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Http\Exceptions\ThrottleRequestsException;
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

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

        // Langue des messages du serveur = langue de l'app (en-tête
        // Accept-Language : fr, en ou ar — doc/audit.md K8). En tête de
        // pile pour couvrir aussi les erreurs d'authentification.
        $middleware->api(prepend: [\App\Http\Middleware\SetLocaleFromRequest::class]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $request->is('api/*') || $request->expectsJson(),
        );

        // Messages lisibles et traduits (doc/audit.md K8) à la place des
        // messages techniques de Laravel, affichés tels quels par l'app
        // (ex. « No query results for model [App\Models\Student] 12 »).
        // Les codes HTTP restent inchangés.
        $exceptions->render(function (ThrottleRequestsException $e, Request $request) {
            if ($request->is('api/*')) {
                return response()->json(
                    ['message' => __('Trop de tentatives. Réessayez dans une minute.')],
                    429,
                    $e->getHeaders(),
                );
            }
        });
        $exceptions->render(function (NotFoundHttpException $e, Request $request) {
            if ($request->is('api/*')) {
                return response()->json(['message' => __('Élément introuvable.')], 404);
            }
        });
        $exceptions->render(function (AccessDeniedHttpException $e, Request $request) {
            if ($request->is('api/*')) {
                return response()->json(['message' => __('Action non autorisée.')], 403);
            }
        });
        $exceptions->render(function (AuthenticationException $e, Request $request) {
            if ($request->is('api/*')) {
                return response()->json(['message' => __('Session expirée. Veuillez vous reconnecter.')], 401);
            }
        });
    })->create();
