<?php

namespace Tests\Unit;

use App\Models\GeneratedDocument;
use App\Models\Markaz;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * CDC section 21 — numérotation unique des documents générés.
 * Corrige doc/audit.md, point D3 : la séquence est désormais tenue dans une
 * table de compteurs dédiée (`document_counters`) plutôt que déduite d'un
 * COUNT() sur le registre — voir GeneratedDocument::nextNumber() pour le
 * détail, et un test de charge réel (15 requêtes HTTP concurrentes) a été
 * exécuté manuellement pour vérifier l'absence de doublon sous concurrence
 * (non reproductible en PHPUnit mono-processus).
 */
class GeneratedDocumentNumberingTest extends TestCase
{
    use RefreshDatabase;

    public function test_sequence_increments_across_successive_calls(): void
    {
        $markaz = Markaz::create(['name' => 'Markaz Al-Nour']);

        $first = GeneratedDocument::nextNumber($markaz->id, 'receipt');
        $second = GeneratedDocument::nextNumber($markaz->id, 'receipt');
        $third = GeneratedDocument::nextNumber($markaz->id, 'receipt');

        $year = now()->year;
        $this->assertSame("MK-{$markaz->id}-{$year}-000001", $first);
        $this->assertSame("MK-{$markaz->id}-{$year}-000002", $second);
        $this->assertSame("MK-{$markaz->id}-{$year}-000003", $third);

        // Une seule ligne de compteur, jamais réinitialisée par insertOrIgnore.
        $this->assertDatabaseCount('document_counters', 1);
        $this->assertDatabaseHas('document_counters', [
            'markaz_id' => $markaz->id,
            'type' => 'receipt',
            'year' => $year,
            'sequence' => 3,
        ]);
    }

    public function test_sequences_are_independent_per_markaz_and_per_type(): void
    {
        $markazA = Markaz::create(['name' => 'Markaz A']);
        $markazB = Markaz::create(['name' => 'Markaz B']);
        $year = now()->year;

        $this->assertSame("MK-{$markazA->id}-{$year}-000001", GeneratedDocument::nextNumber($markazA->id, 'receipt'));
        $this->assertSame("MK-{$markazB->id}-{$year}-000001", GeneratedDocument::nextNumber($markazB->id, 'receipt'));
        $this->assertSame("MK-{$markazA->id}-{$year}-000001", GeneratedDocument::nextNumber($markazA->id, 'weekly_report'));
        $this->assertSame("MK-{$markazA->id}-{$year}-000002", GeneratedDocument::nextNumber($markazA->id, 'receipt'));
    }
}
