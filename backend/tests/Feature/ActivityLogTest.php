<?php

namespace Tests\Feature;

use App\Models\ActivityLog;
use App\Models\Markaz;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * CDC §8.9 / doc/audit.md point F4 — GET /api/activity-logs, consulté par
 * l'écran "Journal d'activité" de l'app : filtres par catégorie et par
 * période, tri par date réelle, isolation stricte entre Markaz.
 */
class ActivityLogTest extends TestCase
{
    use RefreshDatabase;

    private User $teacher;

    private User $otherTeacher;

    protected function setUp(): void
    {
        parent::setUp();

        $markaz = Markaz::create(['name' => 'Markaz A']);
        $other = Markaz::create(['name' => 'Markaz B']);
        $this->teacher = User::factory()->create(['markaz_id' => $markaz->id]);
        $this->otherTeacher = User::factory()->create(['markaz_id' => $other->id]);

        $rows = [
            [$markaz->id, 'payment.recorded', '2026-10-01 10:00:00'],
            [$markaz->id, 'student.created', '2026-10-03 10:00:00'],
            [$markaz->id, 'payment.status_updated', '2026-10-05 10:00:00'],
            [$other->id, 'payment.recorded', '2026-10-04 10:00:00'],
        ];
        foreach ($rows as [$markazId, $action, $performedAt]) {
            ActivityLog::create([
                'markaz_id' => $markazId,
                'action' => $action,
                'description' => $action,
                'performed_at' => $performedAt,
            ]);
        }
    }

    public function test_lists_only_own_markaz_newest_first(): void
    {
        $response = $this->actingAs($this->teacher, 'sanctum')->getJson('/api/activity-logs');

        $response->assertOk();
        $this->assertSame(
            ['payment.status_updated', 'student.created', 'payment.recorded'],
            array_column($response->json('data'), 'action'),
        );
    }

    public function test_filters_by_category(): void
    {
        $response = $this->actingAs($this->teacher, 'sanctum')->getJson('/api/activity-logs?category=payment');

        $this->assertSame(
            ['payment.status_updated', 'payment.recorded'],
            array_column($response->json('data'), 'action'),
        );
    }

    public function test_filters_by_period_on_real_date(): void
    {
        $response = $this->actingAs($this->teacher, 'sanctum')
            ->getJson('/api/activity-logs?date_from=2026-10-02&date_to=2026-10-04');

        $this->assertSame(['student.created'], array_column($response->json('data'), 'action'));
    }

    public function test_rejects_unknown_category(): void
    {
        $this->actingAs($this->teacher, 'sanctum')
            ->getJson('/api/activity-logs?category=inconnue')
            ->assertStatus(422);
    }

    public function test_other_markaz_sees_only_its_own_logs(): void
    {
        $response = $this->actingAs($this->otherTeacher, 'sanctum')->getJson('/api/activity-logs');

        $this->assertSame(['payment.recorded'], array_column($response->json('data'), 'action'));
    }

    public function test_requires_authentication(): void
    {
        $this->getJson('/api/activity-logs')->assertUnauthorized();
    }
}
