<?php

namespace App\Models;

use App\Models\Concerns\BelongsToMarkaz;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

/**
 * CDC section 8.4 — table "classes".
 * Nommé ClassModel côté PHP car "Class" est un mot réservé du langage.
 */
class ClassModel extends Model
{
    use BelongsToMarkaz, HasFactory, SoftDeletes;

    protected $table = 'classes';

    protected $fillable = [
        'markaz_id', 'name', 'level', 'description', 'teacher_id',
        'max_students', 'schedule', 'room', 'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function teacher(): BelongsTo
    {
        return $this->belongsTo(User::class, 'teacher_id');
    }

    public function students(): HasMany
    {
        return $this->hasMany(Student::class, 'class_id');
    }
}
