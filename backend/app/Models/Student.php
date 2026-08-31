<?php

namespace App\Models;

use App\Models\Concerns\BelongsToMarkaz;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

/**
 * CDC section 8.3 — table "students".
 */
class Student extends Model
{
    use BelongsToMarkaz, HasFactory, SoftDeletes;

    protected $fillable = [
        'markaz_id', 'class_id', 'guardian_id', 'name', 'gender',
        'birth_date', 'parent_phone', 'photo_path', 'enrollment_date', 'is_active',
    ];

    protected $casts = [
        'birth_date' => 'date',
        'enrollment_date' => 'date',
        'is_active' => 'boolean',
    ];

    public function classModel(): BelongsTo
    {
        return $this->belongsTo(ClassModel::class, 'class_id');
    }

    public function guardian(): BelongsTo
    {
        return $this->belongsTo(Guardian::class);
    }

    public function attendances(): HasMany
    {
        return $this->hasMany(Attendance::class);
    }

    public function recitations(): HasMany
    {
        return $this->hasMany(Recitation::class);
    }

    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }

    public function reports(): HasMany
    {
        return $this->hasMany(Report::class);
    }
}
