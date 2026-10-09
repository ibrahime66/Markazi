<?php

namespace Tests\Feature;

use App\Models\Markaz;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

/**
 * CDC §8.2 / §21 — logo du Markaz : envoi, lecture réservée au Markaz,
 * remplacement, suppression, validation.
 */
class MarkazLogoTest extends TestCase
{
    use RefreshDatabase;

    private Markaz $markaz;

    private User $teacher;

    protected function setUp(): void
    {
        parent::setUp();
        Storage::fake('local');

        $this->markaz = Markaz::create(['name' => 'Markaz A']);
        $this->teacher = User::factory()->create(['markaz_id' => $this->markaz->id]);
    }

    private function upload(?User $user = null, ?UploadedFile $file = null)
    {
        return $this->actingAs($user ?? $this->teacher, 'sanctum')->post('/api/markaz/logo', [
            'logo' => $file ?? UploadedFile::fake()->image('logo.png', 200, 200),
        ], ['Accept' => 'application/json']);
    }

    public function test_upload_then_download_the_logo(): void
    {
        $response = $this->upload()->assertOk();
        $path = $response->json('logo_path');

        $this->assertStringStartsWith('logos/markaz-'.$this->markaz->id.'-', $path);
        Storage::disk('local')->assertExists($path);

        $this->actingAs($this->teacher, 'sanctum')->get('/api/markaz/logo')->assertOk();
    }

    public function test_replacing_the_logo_deletes_the_old_file(): void
    {
        $old = $this->upload()->json('logo_path');
        $new = $this->upload()->json('logo_path');

        $this->assertNotSame($old, $new);
        Storage::disk('local')->assertMissing($old);
        Storage::disk('local')->assertExists($new);
    }

    public function test_delete_the_logo(): void
    {
        $path = $this->upload()->json('logo_path');

        $this->actingAs($this->teacher, 'sanctum')->deleteJson('/api/markaz/logo')
            ->assertOk()
            ->assertJsonPath('logo_path', null);
        Storage::disk('local')->assertMissing($path);
        $this->actingAs($this->teacher, 'sanctum')->getJson('/api/markaz/logo')->assertNotFound();
    }

    public function test_each_markaz_only_gets_its_own_logo(): void
    {
        $this->upload();

        $other = User::factory()->create(['markaz_id' => Markaz::create(['name' => 'Markaz B'])->id]);
        $this->actingAs($other, 'sanctum')->getJson('/api/markaz/logo')->assertNotFound();
    }

    public function test_rejects_non_images_and_large_files(): void
    {
        $this->upload(file: UploadedFile::fake()->create('logo.pdf', 10, 'application/pdf'))
            ->assertStatus(422);
        $this->upload(file: UploadedFile::fake()->image('logo.png')->size(3000))
            ->assertStatus(422);
    }

    public function test_logo_path_cannot_be_set_through_the_markaz_update(): void
    {
        $this->actingAs($this->teacher, 'sanctum')
            ->putJson('/api/markaz', ['logo_path' => '../../.env'])
            ->assertOk();

        $this->assertNull($this->markaz->fresh()->logo_path);
        $this->actingAs($this->teacher, 'sanctum')->getJson('/api/markaz/logo')->assertNotFound();
    }
}
