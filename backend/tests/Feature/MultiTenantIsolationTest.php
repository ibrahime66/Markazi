<?php

namespace Tests\Feature;

use App\Models\Attendance;
use App\Models\ClassModel;
use App\Models\Markaz;
use App\Models\Payment;
use App\Models\Student;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * CDC section 16 / 22 — "Tests multi-tenant : isolation stricte des données
 * entre deux Markaz distincts", et section 27 (critère d'acceptation) :
 * "un autre Markaz ne peut jamais consulter, modifier ou supprimer [une]
 * ressource, y compris en modifiant manuellement les identifiants dans les
 * requêtes API".
 *
 * Ce périmètre n'était vérifié que manuellement (curl) pendant le
 * développement (doc/audit.md, point E2) — cette suite le rend permanent et
 * automatique.
 */
class MultiTenantIsolationTest extends TestCase
{
    use RefreshDatabase;

    private Markaz $markazA;

    private Markaz $markazB;

    private User $teacherA;

    private User $teacherB;

    protected function setUp(): void
    {
        parent::setUp();

        $this->markazA = Markaz::create(['name' => 'Markaz Al-Nour']);
        $this->markazB = Markaz::create(['name' => 'Markaz Al-Fourqane']);

        $this->teacherA = User::factory()->create(['markaz_id' => $this->markazA->id]);
        $this->teacherB = User::factory()->create(['markaz_id' => $this->markazB->id]);
    }

    private function actingAsTeacherA()
    {
        return $this->actingAs($this->teacherA, 'sanctum');
    }

    private function actingAsTeacherB()
    {
        return $this->actingAs($this->teacherB, 'sanctum');
    }

    // ─── Élèves ─────────────────────────────────────────────────────────

    public function test_teacher_cannot_list_another_markaz_students(): void
    {
        Student::create(['markaz_id' => $this->markazA->id, 'name' => 'Élève A']);
        Student::create(['markaz_id' => $this->markazB->id, 'name' => 'Élève B']);

        $response = $this->actingAsTeacherA()->getJson('/api/students');

        $response->assertOk();
        $names = collect($response->json('data'))->pluck('name');
        $this->assertContains('Élève A', $names);
        $this->assertNotContains('Élève B', $names);
    }

    public function test_teacher_cannot_view_update_or_delete_another_markaz_student(): void
    {
        $student = Student::create(['markaz_id' => $this->markazA->id, 'name' => 'Élève A']);

        $this->actingAsTeacherB()->getJson("/api/students/{$student->id}")->assertNotFound();
        $this->actingAsTeacherB()->putJson("/api/students/{$student->id}", ['name' => 'Piraté'])->assertNotFound();
        $this->actingAsTeacherB()->deleteJson("/api/students/{$student->id}")->assertNotFound();

        // La ressource existe toujours, intacte, pour son vrai propriétaire.
        $this->assertDatabaseHas('students', ['id' => $student->id, 'name' => 'Élève A']);
    }

    public function test_teacher_cannot_create_a_student_referencing_another_markaz_class(): void
    {
        $foreignClass = ClassModel::create(['markaz_id' => $this->markazB->id, 'name' => 'Classe B']);

        $response = $this->actingAsTeacherA()->postJson('/api/students', [
            'name' => 'Nouvel élève',
            'class_id' => $foreignClass->id,
        ]);

        $response->assertStatus(422)->assertJsonValidationErrors('class_id');
    }

    // ─── Classes ────────────────────────────────────────────────────────

    public function test_teacher_cannot_list_view_or_modify_another_markaz_class(): void
    {
        $classA = ClassModel::create(['markaz_id' => $this->markazA->id, 'name' => 'Classe A']);
        ClassModel::create(['markaz_id' => $this->markazB->id, 'name' => 'Classe B']);

        $index = $this->actingAsTeacherB()->getJson('/api/classes');
        $index->assertOk();
        $this->assertNotContains('Classe A', collect($index->json('data'))->pluck('name'));

        $this->actingAsTeacherB()->getJson("/api/classes/{$classA->id}")->assertNotFound();
        $this->actingAsTeacherB()->putJson("/api/classes/{$classA->id}", [
            'name' => 'Piraté',
            'max_students' => 20,
        ])->assertNotFound();
        $this->actingAsTeacherB()->deleteJson("/api/classes/{$classA->id}")->assertNotFound();
    }

    // ─── Présences ──────────────────────────────────────────────────────

    public function test_teacher_cannot_view_update_or_delete_another_markaz_attendance(): void
    {
        $studentA = Student::create(['markaz_id' => $this->markazA->id, 'name' => 'Élève A']);
        $attendance = Attendance::create([
            'markaz_id' => $this->markazA->id,
            'student_id' => $studentA->id,
            'date' => '2026-08-30',
            'status' => 'present',
        ]);

        $index = $this->actingAsTeacherB()->getJson('/api/attendances');
        $index->assertOk();
        $this->assertCount(0, $index->json('data'));

        $this->actingAsTeacherB()->putJson("/api/attendances/{$attendance->id}", [
            'student_id' => $studentA->id,
            'date' => '2026-08-30',
            'status' => 'absent',
        ])->assertStatus(422); // student_id hors du périmètre de teacherB → rejeté par la validation

        $this->actingAsTeacherB()->deleteJson("/api/attendances/{$attendance->id}")->assertNotFound();

        $this->assertDatabaseHas('attendances', ['id' => $attendance->id, 'status' => 'present']);
    }

    // ─── Paiements ──────────────────────────────────────────────────────

    public function test_teacher_cannot_view_list_or_update_another_markaz_payment(): void
    {
        $studentA = Student::create(['markaz_id' => $this->markazA->id, 'name' => 'Élève A']);
        $payment = Payment::create([
            'markaz_id' => $this->markazA->id,
            'student_id' => $studentA->id,
            'amount' => 50000,
            'month' => '2026-08-01',
            'status' => 'unpaid',
            'payment_mode' => 'cash',
        ]);

        $index = $this->actingAsTeacherB()->getJson('/api/payments');
        $index->assertOk();
        $this->assertCount(0, $index->json('data'));

        $this->actingAsTeacherB()->getJson("/api/payments/{$payment->id}")->assertNotFound();
        $this->actingAsTeacherB()->patchJson("/api/payments/{$payment->id}", ['status' => 'paid'])->assertNotFound();

        $this->assertDatabaseHas('payments', ['id' => $payment->id, 'status' => 'unpaid', 'receipt_number' => null]);
    }

    // ─── Défense en profondeur : identifiant forcé manuellement ────────

    public function test_manually_forged_id_in_url_never_leaks_cross_markaz_data(): void
    {
        // CDC section 27 : "y compris en modifiant manuellement les
        // identifiants dans les requêtes API" — même en devinant un ID
        // séquentiel valide d'un autre Markaz, aucune fuite ne doit se produire.
        $studentA = Student::create(['markaz_id' => $this->markazA->id, 'name' => 'Élève A']);

        for ($i = 1; $i <= 5; $i++) {
            Student::create(['markaz_id' => $this->markazB->id, 'name' => "Élève B{$i}"]);
        }

        $response = $this->actingAsTeacherB()->getJson("/api/students/{$studentA->id}");

        $response->assertNotFound();
    }
}
