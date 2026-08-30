<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * CDC section 8.2 / 18 — Fiche du Markaz (tenant).
 * Ces informations sont réutilisées automatiquement dans tous les documents générés.
 */
class Markaz extends Model
{
    use HasFactory;

    protected $table = 'markaz';

    protected $fillable = [
        'name', 'slogan', 'logo_path', 'address', 'city', 'country',
        'currency', 'phone', 'email', 'website', 'primary_color',
        'secondary_color', 'working_days',
    ];

    protected $casts = [
        'working_days' => 'array',
    ];

    public function users(): HasMany
    {
        return $this->hasMany(User::class);
    }

    public function classes(): HasMany
    {
        return $this->hasMany(ClassModel::class);
    }

    public function students(): HasMany
    {
        return $this->hasMany(Student::class);
    }
}
