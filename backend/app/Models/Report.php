<?php

namespace App\Models;

use App\Models\Concerns\BelongsToMarkaz;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * CDC section 8.8 — table "reports" (méta des rapports générés).
 */
class Report extends Model
{
    use BelongsToMarkaz, HasFactory;

    protected $fillable = [
        'markaz_id', 'student_id', 'type', 'period_start', 'period_end',
        'data', 'generated_document_id', 'generated_by',
    ];

    protected $casts = [
        'period_start' => 'date',
        'period_end' => 'date',
        'data' => 'array',
    ];

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    public function generatedDocument(): BelongsTo
    {
        return $this->belongsTo(GeneratedDocument::class);
    }
}
