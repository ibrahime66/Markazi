<?php

namespace Tests\Feature;

use App\Models\Attendance;
use App\Models\Markaz;
use App\Models\Recitation;
use App\Models\Student;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * CDC section 22 / 27 — "les calculs de taux de présence et de progression"
 * doivent être couverts par des tests automatisés, et "le taux de présence
 * affiché pour un élève correspond exactement au calcul (jours présents /
 * jours de cours) sur la période sélectionnée, vérifié par des tests
 * automatisés" est cité comme critère d'acceptation explicite.
 *
 * Depuis le correctif du point F6 (doc/plan_resolution.md), "jours de cours"
 * n'est plus le nombre de présences saisies mais le nombre réel de jours
 * ouvrés (CDC 8.6, configurable par Markaz — lundi-vendredi par défaut) sur
 * la période demandée : un jour non saisi compte désormais contre le taux
 * plutôt que d'être simplement ignoré.
 */
class AttendanceRecitationCalculationsTest extends TestCase
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

    private function stats(string $dateFrom, string $dateTo)
    {
        return $this->actingAs($this->teacher, 'sanctum')->getJson(
            "/api/students/{$this->student->id}/attendance-stats?date_from={$dateFrom}&date_to={$dateTo}"
        );
    }

    public function test_attendance_rate_matches_present_over_working_days_with_full_coverage(): void
    {
        // Semaine du lundi 3 au dimanche 9 août 2026 : 5 jours ouvrés
        // (lun-ven, par défaut) sur les 7 jours calendaires de la période.
        // Chaque jour ouvré est saisi : 4 présents, 1 absent.
        $days = ['2026-08-03', '2026-08-04', '2026-08-05', '2026-08-06', '2026-08-07'];
        $statuses = ['present', 'present', 'present', 'present', 'absent'];
        foreach ($days as $i => $date) {
            Attendance::create([
                'markaz_id' => $this->markaz->id,
                'student_id' => $this->student->id,
                'date' => $date,
                'status' => $statuses[$i],
            ]);
        }

        $response = $this->stats('2026-08-03', '2026-08-09');

        $response->assertOk();
        $this->assertSame(5, $response->json('total_days'));
        $this->assertSame(4, $response->json('present'));
        $this->assertSame(1, $response->json('absent'));
        // 4/5 = 80%, 1/5 = 20%
        $this->assertEquals(80.0, $response->json('attendance_rate'));
        $this->assertEquals(20.0, $response->json('absence_rate'));
    }

    public function test_days_never_recorded_lower_the_attendance_rate(): void
    {
        // Même semaine (5 jours ouvrés), mais seuls 3 des 5 jours ont été
        // saisis (l'enseignant a oublié jeudi et vendredi) : ces 2 jours ne
        // doivent plus être ignorés, ils pèsent contre le taux.
        $recordedDays = ['2026-08-03', '2026-08-04', '2026-08-05'];
        foreach ($recordedDays as $date) {
            Attendance::create([
                'markaz_id' => $this->markaz->id,
                'student_id' => $this->student->id,
                'date' => $date,
                'status' => 'present',
            ]);
        }

        $response = $this->stats('2026-08-03', '2026-08-09');

        $response->assertOk();
        $this->assertSame(5, $response->json('total_days')); // toujours 5 jours ouvrés attendus
        $this->assertSame(3, $response->json('present'));
        // 3/5 = 60% (et non 3/3 = 100% comme avec l'ancien calcul)
        $this->assertEquals(60.0, $response->json('attendance_rate'));
    }

    public function test_working_days_are_configurable_per_markaz(): void
    {
        // Ce Markaz travaille du samedi au jeudi (vendredi non travaillé),
        // configuration explicitement différente du défaut lundi-vendredi.
        $this->markaz->update(['working_days' => ['sat', 'sun', 'mon', 'tue', 'wed', 'thu']]);

        // Semaine du 3 (lundi) au 9 (dimanche) août 2026 : avec cette config,
        // les jours de cours sont lun,mar,mer,jeu,sam,dim = 6 jours (vendredi exclu).
        Attendance::create([
            'markaz_id' => $this->markaz->id,
            'student_id' => $this->student->id,
            'date' => '2026-08-08', // samedi : jour de cours avec cette config
            'status' => 'present',
        ]);

        $response = $this->stats('2026-08-03', '2026-08-09');

        $response->assertOk();
        $this->assertSame(6, $response->json('total_days'));
    }

    public function test_recitation_progress_rate_matches_recited_over_total_sessions(): void
    {
        // 3 récitées, 1 partielle, 1 non récitée sur 5 séances.
        $statuses = ['recited', 'recited', 'recited', 'partial', 'not_recited'];
        foreach ($statuses as $i => $status) {
            Recitation::create([
                'markaz_id' => $this->student->markaz_id,
                'student_id' => $this->student->id,
                'date' => "2026-08-".str_pad((string) ($i + 1), 2, '0', STR_PAD_LEFT),
                'surah' => 'Al-Baqara',
                'status' => $status,
            ]);
        }

        $response = $this->actingAs($this->teacher, 'sanctum')
            ->getJson("/api/students/{$this->student->id}/recitation-progress");

        $response->assertOk();
        $this->assertSame(5, $response->json('total_sessions'));
        $this->assertSame(3, $response->json('recited'));
        $this->assertSame(1, $response->json('partial'));
        $this->assertSame(1, $response->json('not_recited'));
        // 3/5 = 60%
        $this->assertEquals(60.0, $response->json('progress_rate'));
    }

    public function test_progress_rate_is_zero_when_no_sessions_recorded(): void
    {
        $response = $this->actingAs($this->teacher, 'sanctum')
            ->getJson("/api/students/{$this->student->id}/recitation-progress");

        $response->assertOk();
        $this->assertSame(0, $response->json('total_sessions'));
        $this->assertSame(0, $response->json('progress_rate'));
    }
}
