<?php

namespace Tests\Feature;

use App\Models\Markaz;
use App\Models\User;
use Illuminate\Auth\Notifications\ResetPassword;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Notification;
use Tests\TestCase;

/**
 * doc/audit.md, point K8 — les messages du serveur suivent la langue de
 * l'app (en-tête Accept-Language : fr, en, ar), le français restant la
 * langue par défaut (CDC §7.2). Auparavant, faute de traductions de la
 * validation, un maître francophone voyait des messages en anglais.
 */
class LocaleTest extends TestCase
{
    use RefreshDatabase;

    private function registerWithoutName(string $language)
    {
        return $this->withHeader('Accept-Language', $language)->postJson('/api/auth/register', [
            'email' => 'maitre@markazi.test',
            'password' => 'secret123',
            'markaz_name' => 'Markaz Al-Nour',
        ]);
    }

    public function test_validation_messages_follow_the_app_language(): void
    {
        $this->registerWithoutName('fr')->assertStatus(422)
            ->assertJsonPath('errors.name.0', 'Le champ nom est obligatoire.');

        $this->registerWithoutName('ar')->assertStatus(422)
            ->assertJsonPath('errors.name.0', 'حقل الاسم مطلوب.');

        $this->registerWithoutName('en')->assertStatus(422)
            ->assertJsonPath('errors.name.0', 'The name field is required.');
    }

    public function test_unsupported_language_falls_back_to_french(): void
    {
        $this->registerWithoutName('de-DE,de;q=0.9')->assertStatus(422)
            ->assertJsonPath('errors.name.0', 'Le champ nom est obligatoire.');
    }

    public function test_business_messages_are_translated(): void
    {
        User::factory()->create(['email' => 'maitre@markazi.test', 'password' => 'secret123']);

        $this->withHeader('Accept-Language', 'en')->postJson('/api/auth/login', [
            'email' => 'maitre@markazi.test',
            'password' => 'mauvais',
        ])->assertStatus(422)->assertJsonPath('errors.email.0', 'Incorrect email or password.');
    }

    public function test_not_found_message_is_readable_and_translated(): void
    {
        $markaz = Markaz::create(['name' => 'Markaz A']);
        $teacher = User::factory()->create(['markaz_id' => $markaz->id]);

        $this->actingAs($teacher, 'sanctum')->withHeader('Accept-Language', 'fr')
            ->getJson('/api/students/999')
            ->assertNotFound()
            ->assertJsonPath('message', 'Élément introuvable.');
    }

    public function test_reset_email_follows_the_app_language(): void
    {
        Notification::fake();
        $user = User::factory()->create(['email' => 'maitre@markazi.test']);

        $this->withHeader('Accept-Language', 'ar')
            ->postJson('/api/auth/password/forgot', ['email' => 'maitre@markazi.test'])
            ->assertOk();

        Notification::assertSentTo($user, function (ResetPassword $notification) {
            $mail = $notification->toMail($notification);
            $this->assertSame('إعادة تعيين كلمة مرور مركزي', $mail->subject);

            return true;
        });
    }
}
