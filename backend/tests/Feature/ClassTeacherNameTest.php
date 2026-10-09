<?php

namespace Tests\Feature;

use App\Models\Markaz;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * doc/audit.md, point H5 : le "Nom de l'enseignant" saisi dans le formulaire
 * de groupe doit être réellement enregistré côté serveur, sinon il disparaît
 * à la première resynchronisation de l'app.
 */
class ClassTeacherNameTest extends TestCase
{
    use RefreshDatabase;

    private User $teacher;

    protected function setUp(): void
    {
        parent::setUp();

        $markaz = Markaz::create(['name' => 'Markaz Al-Nour']);
        $this->teacher = User::factory()->create(['markaz_id' => $markaz->id]);
    }

    public function test_teacher_name_is_saved_on_create_and_update(): void
    {
        $created = $this->actingAs($this->teacher, 'sanctum')->postJson('/api/classes', [
            'name' => 'Groupe Hifz',
            'teacher_name' => 'Oustaz Mamadou',
            'max_students' => 30,
        ]);

        $created->assertCreated();
        $this->assertSame('Oustaz Mamadou', $created->json('teacher_name'));

        $id = $created->json('id');

        $updated = $this->actingAs($this->teacher, 'sanctum')->putJson("/api/classes/{$id}", [
            'name' => 'Groupe Hifz',
            'teacher_name' => 'Oustaz Ibrahima',
            'max_students' => 30,
        ]);

        $updated->assertOk();
        $this->assertSame('Oustaz Ibrahima', $updated->json('teacher_name'));

        // Relu depuis la liste, comme le fait l'app à chaque resynchronisation.
        $list = $this->actingAs($this->teacher, 'sanctum')->getJson('/api/classes');
        $this->assertSame('Oustaz Ibrahima', $list->json('data.0.teacher_name'));
    }

    public function test_teacher_name_is_optional(): void
    {
        $this->actingAs($this->teacher, 'sanctum')->postJson('/api/classes', [
            'name' => 'Groupe sans enseignant',
            'max_students' => 30,
        ])->assertCreated()->assertJsonPath('teacher_name', null);
    }
}
