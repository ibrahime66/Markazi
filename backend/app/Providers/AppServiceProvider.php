<?php

namespace App\Providers;

use Illuminate\Auth\Notifications\ResetPassword;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Markazi est une API pure consommée par l'app mobile (pas de page
        // web de réinitialisation) : le comportement par défaut de Laravel
        // (email avec un lien cliquable vers route('password.reset', ...))
        // plantait avec une RouteNotFoundException, cette route n'existant
        // pas ici (doc/audit.md, point C2 — bug plus grave que prévu :
        // "mot de passe oublié" ne se contentait pas de ne pas envoyer de
        // vrai email, il faisait planter la requête en 500).
        //
        // On remplace par un email présentant directement le code/jeton, à
        // saisir dans l'app avec l'email et le nouveau mot de passe — ce
        // que POST /api/auth/password/reset attend déjà. Aussi entièrement
        // en français (CDC : la V1 est en français) alors que le texte par
        // défaut de Laravel ne l'est pas.
        ResetPassword::toMailUsing(function (object $notifiable, string $token) {
            $expireMinutes = config('auth.passwords.'.config('auth.defaults.passwords').'.expire');

            return (new MailMessage)
                ->subject('Réinitialisation de votre mot de passe Markazi')
                ->greeting('Bonjour,')
                ->line('Vous avez demandé la réinitialisation de votre mot de passe Markazi.')
                ->line('Voici votre code de réinitialisation :')
                ->line('**'.$token.'**')
                ->line('Saisissez ce code avec votre adresse email dans l\'application pour choisir un nouveau mot de passe.')
                ->line("Ce code expire dans {$expireMinutes} minutes.")
                ->line("Si vous n'êtes pas à l'origine de cette demande, aucune action n'est nécessaire.");
        });
    }
}
