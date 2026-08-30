<?php

namespace Tests\Feature;

use App\Models\Markaz;
use App\Models\Payment;
use App\Models\Student;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * CDC section 22 — "l'enregistrement des paiements et la génération des
 * reçus" font partie des points devant impérativement être couverts par des
 * tests automatisés avant toute mise en production.
 *
 * Couvre aussi le correctif du point A2 (doc/plan_resolution.md) : marquer
 * un paiement "payé" doit modifier l'enregistrement existant, jamais en
 * créer un second, et le numéro de reçu ne doit jamais être réattribué une
 * fois déjà posé.
 */
class PaymentTest extends TestCase
{
    use RefreshDatabase;

    private Markaz $markaz;

    private User $teacher;

    private Student $student;

    protected function setUp(): void
    {
        parent::setUp();

        $this->markaz = Markaz::create(['name' => 'Markaz Al-Nour']);
        $this->teacher = User::factory()->create(['markaz_id' => $this->markaz->id]);
        $this->student = Student::create(['markaz_id' => $this->markaz->id, 'name' => 'Élève A']);
    }

    private function asTeacher()
    {
        return $this->actingAs($this->teacher, 'sanctum');
    }

    public function test_creating_a_paid_payment_assigns_a_receipt_number(): void
    {
        $response = $this->asTeacher()->postJson('/api/payments', [
            'student_id' => $this->student->id,
            'amount' => 50000,
            'month' => '2026-08-01',
            'status' => 'paid',
            'payment_mode' => 'cash',
        ]);

        $response->assertCreated();
        $this->assertNotNull($response->json('receipt_number'));
        $this->assertStringStartsWith("MK-{$this->markaz->id}-2026-", $response->json('receipt_number'));

        $this->assertDatabaseHas('generated_documents', [
            'markaz_id' => $this->markaz->id,
            'type' => 'receipt',
            'number' => $response->json('receipt_number'),
            'documentable_type' => 'App\\Models\\Payment',
            'documentable_id' => $response->json('id'),
        ]);
    }

    public function test_creating_an_unpaid_payment_does_not_assign_a_receipt_number(): void
    {
        $response = $this->asTeacher()->postJson('/api/payments', [
            'student_id' => $this->student->id,
            'amount' => 50000,
            'month' => '2026-08-01',
            'status' => 'unpaid',
            'payment_mode' => 'cash',
        ]);

        $response->assertCreated();
        $this->assertNull($response->json('receipt_number'));
    }

    public function test_a_second_paid_payment_for_the_same_student_and_month_is_flagged_as_duplicate(): void
    {
        $this->asTeacher()->postJson('/api/payments', [
            'student_id' => $this->student->id,
            'amount' => 50000,
            'month' => '2026-08-01',
            'status' => 'paid',
            'payment_mode' => 'cash',
        ])->assertCreated();

        $duplicate = $this->asTeacher()->postJson('/api/payments', [
            'student_id' => $this->student->id,
            'amount' => 50000,
            'month' => '2026-08-15', // même mois calendaire, jour différent
            'status' => 'paid',
            'payment_mode' => 'cash',
        ]);

        $duplicate->assertStatus(409)->assertJsonPath('duplicate', true);
        $this->assertDatabaseCount('payments', 1);
    }

    public function test_duplicate_payment_is_accepted_when_explicitly_confirmed(): void
    {
        $this->asTeacher()->postJson('/api/payments', [
            'student_id' => $this->student->id,
            'amount' => 50000,
            'month' => '2026-08-01',
            'status' => 'paid',
            'payment_mode' => 'cash',
        ])->assertCreated();

        $confirmed = $this->asTeacher()->postJson('/api/payments', [
            'student_id' => $this->student->id,
            'amount' => 50000,
            'month' => '2026-08-15',
            'status' => 'paid',
            'payment_mode' => 'cash',
            'confirm_duplicate' => true,
        ]);

        $confirmed->assertCreated();
        $this->assertDatabaseCount('payments', 2);

        // Deux paiements payés distincts doivent avoir deux numéros de reçu distincts.
        $receiptNumbers = \App\Models\Payment::withoutGlobalScopes()->pluck('receipt_number');
        $this->assertCount(2, $receiptNumbers->unique());
    }

    public function test_marking_a_payment_as_paid_updates_it_in_place_without_duplicating(): void
    {
        $created = $this->asTeacher()->postJson('/api/payments', [
            'student_id' => $this->student->id,
            'amount' => 50000,
            'month' => '2026-08-01',
            'status' => 'unpaid',
            'payment_mode' => 'cash',
        ])->assertCreated();

        $paymentId = $created->json('id');

        $updated = $this->asTeacher()->patchJson("/api/payments/{$paymentId}", ['status' => 'paid']);

        $updated->assertOk()
            ->assertJsonPath('id', $paymentId)
            ->assertJsonPath('status', 'paid');
        $this->assertNotNull($updated->json('receipt_number'));

        // Toujours un seul enregistrement pour ce paiement, jamais deux.
        $this->assertDatabaseCount('payments', 1);
    }

    public function test_marking_an_already_paid_payment_as_paid_again_keeps_the_same_receipt_number(): void
    {
        $created = $this->asTeacher()->postJson('/api/payments', [
            'student_id' => $this->student->id,
            'amount' => 50000,
            'month' => '2026-08-01',
            'status' => 'paid',
            'payment_mode' => 'cash',
        ])->assertCreated();

        $originalReceipt = $created->json('receipt_number');
        $paymentId = $created->json('id');

        $again = $this->asTeacher()->patchJson("/api/payments/{$paymentId}", ['status' => 'paid']);

        $again->assertOk()->assertJsonPath('receipt_number', $originalReceipt);

        // Un seul document a été enregistré pour ce paiement, pas deux.
        $this->assertDatabaseCount('generated_documents', 1);
    }

    public function test_a_deleted_payment_is_archived_not_erased(): void
    {
        // CDC section 18 : "soft delete (deleted_at) sur students, classes
        // et payments pour l'archivage sans perte d'historique" — corrige
        // doc/audit.md, point F7 (absent initialement sur payments).
        $payment = Payment::create([
            'markaz_id' => $this->markaz->id,
            'student_id' => $this->student->id,
            'amount' => 50000,
            'month' => '2026-08-01',
            'status' => 'unpaid',
            'payment_mode' => 'cash',
        ]);

        $payment->delete();

        $this->assertSame(0, Payment::count());
        $this->assertSame(1, Payment::withTrashed()->count());
        $this->assertDatabaseHas('payments', ['id' => $payment->id]);
        $this->assertNotNull(Payment::withTrashed()->find($payment->id)->deleted_at);
    }
}
