<?php

namespace App\Models;

use App\Models\Concerns\BelongsToMarkaz;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * CDC section 8.5 — table "recitations" (suivi des séances de récitation).
 */
class Recitation extends Model
{
    use BelongsToMarkaz, HasFactory;

    protected $fillable = [
        'markaz_id', 'student_id', 'date', 'surah', 'ayah_from', 'ayah_to',
        'status', 'note', 'recorded_by',
    ];

    protected $casts = [
        'date' => 'date',
    ];

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    public function recordedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'recorded_by');
    }
}
