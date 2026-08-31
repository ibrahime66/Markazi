<?php

namespace App\Models;

use App\Models\Concerns\BelongsToMarkaz;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * CDC section 18 — table "parents" (parents/tuteurs).
 * Nommé Guardian côté PHP car "Parent" est un mot réservé du langage.
 */
class Guardian extends Model
{
    use BelongsToMarkaz, HasFactory;

    protected $fillable = ['markaz_id', 'name', 'phone', 'email', 'address'];

    public function students(): HasMany
    {
        return $this->hasMany(Student::class);
    }
}
