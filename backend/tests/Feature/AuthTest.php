<?php

namespace Tests\Feature;

use App\Models\Markaz;
use App\Models\User;
use Illuminate\Auth\Notifications\ResetPassword;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Notification;
use Tests\TestCase;

/**
 * CDC section 22 — "les fonctionnalités devant impérativement être couvertes
 * par des tests automatisés avant toute mise en production sont :
 * l'authentification, l'isolation multi-tenant [...]".
 *
 * Cette suite couvre l'authentification (doc/audit.md, point E2 : ce
 * périmètre n'était vérifié que manuellement, via curl, pendant le
 * développement).
 */
class AuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_register_creates_markaz_and_user_and_returns_token(): void
    {
        $response = $this->postJson('/api/auth/register', [
            'name' => 'Ibrahime',
            'email' => 'ibrahime@markazi.test',
            'password' => 'password',
            'password_confirmation' => 'password',
            'markaz_name' => 'Markaz Al-Nour',
        ]);

        $response->assertCreated()
            ->assertJsonStructure(['user', 'token'])
            ->assertJsonPath('user.email', 'ibrahime@markazi.test')
            ->assertJsonPath('user.role', 'teacher')
            ->assertJsonPath('user.markaz.name', 'Markaz Al-Nour');

        $this->assertDatabaseCount('markaz', 1);
        $this->assertDatabaseHas('users', [
            'email' => 'ibrahime@markazi.test',
            'role' => 'teacher',
        ]);

        // Le mot de passe ne doit jamais être renvoyé en clair ni haché.
        $response->assertJsonMissingPath('user.password');
    }

    public function test_register_rejects_duplicate_email(): void
    {
        User::factory()->create(['email' => 'deja@markazi.test']);

        $response = $this->postJson('/api/auth/register', [
            'name' => 'Autre',
            'email' => 'deja@markazi.test',
            'password' => 'password',
            'password_confirmation' => 'password',
            'markaz_name' => 'Un autre Markaz',
        ]);

        $response->assertStatus(422)->assertJsonValidationErrors('email');
    }

    public function test_login_with_correct_credentials_returns_token(): void
    {
        $markaz = Markaz::create(['name' => 'Markaz Al-Nour']);
        $user = User::factory()->create([
            'markaz_id' => $markaz->id,
            'email' => 'ibrahime@markazi.test',
            'password' => 'password',
        ]);

        $response = $this->postJson('/api/auth/login', [
            'email' => 'ibrahime@markazi.test',
            'password' => 'password',
        ]);

        $response->assertOk()->assertJsonStructure(['user', 'token']);
        $this->assertNotEmpty($response->json('token'));
        $this->assertSame($user->id, $response->json('user.id'));
    }

    public function test_login_with_wrong_password_is_rejected(): void
    {
        $markaz = Markaz::create(['name' => 'Markaz Al-Nour']);
        User::factory()->create([
            'markaz_id' => $markaz->id,
            'email' => 'ibrahime@markazi.test',
            'password' => 'password',
        ]);

        $response = $this->postJson('/api/auth/login', [
            'email' => 'ibrahime@markazi.test',
            'password' => 'mauvais-mot-de-passe',
        ]);

        $response->assertStatus(422)->assertJsonValidationErrors('email');
    }

    public function test_login_with_unknown_email_is_rejected(): void
    {
        $response = $this->postJson('/api/auth/login', [
            'email' => 'inconnu@markazi.test',
            'password' => 'peu-importe',
        ]);

        $response->assertStatus(422);
    }

    public function test_forgot_password_does_not_crash_and_sends_a_french_email(): void
    {
        // Corrige doc/audit.md, point C2 : cette route plantait en 500
        // (RouteNotFoundException) car Laravel tentait par défaut de
        // générer un lien vers une route web "password.reset" inexistante
        // dans cette API pure — voir AppServiceProvider::boot().
        Notification::fake();

        $user = User::factory()->create(['email' => 'ibrahime@markazi.test']);

        // L'app envoie sa langue (doc/audit.md K8) ; le client de test de
        // Laravel enverrait sinon « en-us » par défaut.
        $response = $this->withHeader('Accept-Language', 'fr')->postJson('/api/auth/password/forgot', [
            'email' => 'ibrahime@markazi.test',
        ]);

        $response->assertOk();

        Notification::assertSentTo($user, function (ResetPassword $notification) {
            $mail = $notification->toMail($notification);
            // L'email doit être entièrement en français (CDC : la V1 est
            // en français) et présenter le code directement (pas de lien
            // cliquable, puisqu'il n'y a pas de page web de reset).
            $rendered = collect($mail->introLines)->implode(' ');
            $this->assertStringContainsString('réinitialisation', $rendered);
            $this->assertStringNotContainsString('http://', $rendered);

            return true;
        });
    }

    public function test_protected_route_requires_a_valid_token(): void
    {
        // Sans token du tout.
        $this->getJson('/api/students')->assertStatus(401);

        // Avec un token invalide/inconnu.
        $this->withHeader('Authorization', 'Bearer token-qui-n-existe-pas')
            ->getJson('/api/students')
            ->assertStatus(401);
    }

    public function test_me_returns_the_authenticated_user_with_its_markaz(): void
    {
        $markaz = Markaz::create(['name' => 'Markaz Al-Nour']);
        $user = User::factory()->create(['markaz_id' => $markaz->id]);

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/auth/me');

        $response->assertOk()
            ->assertJsonPath('id', $user->id)
            ->assertJsonPath('markaz.name', 'Markaz Al-Nour');
    }

    public function test_logout_revokes_only_the_current_device_token(): void
    {
        $user = User::factory()->create();
        $tokenA = $user->createToken('appareil-A')->plainTextToken;
        $user->createToken('appareil-B')->plainTextToken;

        $this->assertCount(2, $user->tokens);

        $this->withHeader('Authorization', 'Bearer '.$tokenA)
            ->postJson('/api/auth/logout')
            ->assertOk();

        // Le guard Sanctum mémorise l'utilisateur résolu pour la durée de vie
        // du conteneur applicatif ; comme ce test simule deux requêtes dans
        // le même conteneur (contrairement à deux vraies requêtes HTTP
        // séparées, chacune avec son propre conteneur), il faut forcer une
        // résolution fraîche pour que la suppression du token ci-dessus soit
        // bien prise en compte par l'appel suivant.
        $this->app['auth']->forgetGuards();

        // Le token de l'appareil A a été révoqué...
        $this->withHeader('Authorization', 'Bearer '.$tokenA)
            ->getJson('/api/auth/me')
            ->assertStatus(401);

        // ...mais un seul, pas les deux (un token par appareil, CDC section 14).
        $this->assertCount(1, $user->fresh()->tokens);
    }
}
