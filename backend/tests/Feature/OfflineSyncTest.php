<?php

namespace Tests\Feature;

use App\Models\ActivityLog;
use App\Models\Attendance;
use App\Models\Guardian;
use App\Models\Markaz;
use App\Models\Payment;
use App\Models\Student;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Tests\TestCase;

/**
 * CDC §20 / §27, doc/audit.md point F5 — mode hors ligne côté serveur :
 *  - une action rejouée après une période hors ligne est journalisée à sa
 *    date réelle (en-tête X-Performed-At), pas à la date de synchronisation ;
 *  - une modification concurrente (ressource modifiée côté serveur après
 *    l'action hors ligne) est appliquée ("dernière écriture serveur
 *    gagnante") mais tracée dans le journal avec la version écrasée.
 */
class OfflineSyncTest extends TestCase
{
    use RefreshDatabase;

    private Markaz $markaz;

    private User $teacher;

    private Student $student;

    protected function setUp(): void
    {
        parent::setUp();

        Carbon::setTestNow('2026-10-09 12:00:00');

        $this->markaz = Markaz::create(['name' => 'Markaz Al-Nour']);
        $this->teacher = User::factory()->create(['markaz_id' => $this->markaz->id]);
        $this->student = Student::create(['markaz_id' => $this->markaz->id, 'name' => 'Élève A']);
    }

    protected function tearDown(): void
    {
        Carbon::setTestNow();
        parent::tearDown();
    }

    private function asTeacher()
    {
        return $this->actingAs($this->teacher, 'sanctum');
    }

    public function test_replayed_action_is_logged_at_its_real_date(): void
    {
        $this->asTeacher()
            ->withHeader('X-Performed-At', '2026-10-07T09:30:00+00:00')
            ->postJson('/api/attendances', [
                'student_id' => $this->student->id,
                'date' => '2026-10-07',
                'status' => 'present',
            ])->assertCreated();

        $log = ActivityLog::where('action', 'attendance.recorded')->firstOrFail();
        $this->assertSame('2026-10-07 09:30:00', $log->performed_at->format('Y-m-d H:i:s'));
        $this->assertTrue($log->meta['synced_offline']);
    }

    public function test_online_action_is_logged_now_without_offline_flag(): void
    {
        $this->asTeacher()->postJson('/api/guardians', ['name' => 'Parent', 'phone' => '622000000'])
            ->assertCreated();

        $log = ActivityLog::where('action', 'guardian.created')->firstOrFail();
        $this->assertSame('2026-10-09 12:00:00', $log->performed_at->format('Y-m-d H:i:s'));
        $this->assertArrayNotHasKey('synced_offline', $log->meta ?? []);
    }

    public function test_invalid_or_future_header_is_ignored(): void
    {
        foreach (['pas-une-date', '2027-01-01T00:00:00+00:00', '2020-01-01T00:00:00+00:00'] as $header) {
            $this->asTeacher()->withHeader('X-Performed-At', $header)
                ->postJson('/api/guardians', ['name' => "Parent {$header}", 'phone' => '622000000'])
                ->assertCreated();
        }

        $this->assertSame(
            3,
            ActivityLog::where('action', 'guardian.created')
                ->where('performed_at', '2026-10-09 12:00:00')
                ->count(),
        );
    }

    public function test_conflict_is_applied_and_logged_when_server_version_is_newer(): void
    {
        // Version serveur modifiée le 8 (ex. depuis un autre appareil)...
        Carbon::setTestNow('2026-10-08 10:00:00');
        $guardian = Guardian::create(['markaz_id' => $this->markaz->id, 'name' => 'Version serveur', 'phone' => '1']);

        // ... alors que la modification hors ligne date du 7, rejouée le 9.
        Carbon::setTestNow('2026-10-09 12:00:00');
        $this->asTeacher()
            ->withHeader('X-Performed-At', '2026-10-07T08:00:00+00:00')
            ->putJson("/api/guardians/{$guardian->id}", ['name' => 'Version hors ligne', 'phone' => '2'])
            ->assertOk()
            ->assertJsonPath('name', 'Version hors ligne'); // dernière écriture serveur gagnante

        $conflict = ActivityLog::where('action', 'sync.conflict')->firstOrFail();
        $this->assertSame($guardian->id, $conflict->entity_id);
        $this->assertSame('update', $conflict->meta['operation']);
        $this->assertSame('Version serveur', $conflict->meta['overwritten_server_version']['name']);
    }

    public function test_no_conflict_when_server_version_is_older_than_the_offline_action(): void
    {
        Carbon::setTestNow('2026-10-05 10:00:00');
        $guardian = Guardian::create(['markaz_id' => $this->markaz->id, 'name' => 'Ancienne', 'phone' => '1']);

        Carbon::setTestNow('2026-10-09 12:00:00');
        $this->asTeacher()
            ->withHeader('X-Performed-At', '2026-10-07T08:00:00+00:00')
            ->putJson("/api/guardians/{$guardian->id}", ['name' => 'Nouvelle', 'phone' => '2'])
            ->assertOk();

        $this->assertSame(0, ActivityLog::where('action', 'sync.conflict')->count());
    }

    public function test_replayed_attendance_overwriting_a_newer_one_logs_a_conflict(): void
    {
        Carbon::setTestNow('2026-10-07 16:00:00');
        Attendance::create([
            'markaz_id' => $this->markaz->id,
            'student_id' => $this->student->id,
            'date' => '2026-10-07',
            'status' => 'absent',
        ]);

        Carbon::setTestNow('2026-10-09 12:00:00');
        $this->asTeacher()
            ->withHeader('X-Performed-At', '2026-10-07T09:00:00+00:00')
            ->postJson('/api/attendances', [
                'student_id' => $this->student->id,
                'date' => '2026-10-07',
                'status' => 'present',
            ])->assertCreated();

        $this->assertSame(1, ActivityLog::where('action', 'sync.conflict')->count());
    }

    public function test_payment_marked_paid_offline_keeps_the_real_payment_day(): void
    {
        $payment = Payment::create([
            'markaz_id' => $this->markaz->id,
            'student_id' => $this->student->id,
            'amount' => 50000,
            'month' => '2026-10-01',
            'status' => 'unpaid',
            'payment_mode' => 'cash',
        ]);

        $this->asTeacher()
            ->withHeader('X-Performed-At', '2026-10-06T15:00:00+00:00')
            ->patchJson("/api/payments/{$payment->id}", ['status' => 'paid'])
            ->assertOk();

        $this->assertSame('2026-10-06', $payment->fresh()->paid_at->format('Y-m-d'));
    }
}
