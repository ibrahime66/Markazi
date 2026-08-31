<?php

namespace App\Models;

use App\Models\Concerns\BelongsToMarkaz;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Auth;

/**
 * CDC section 8.9 / 19 — journal d'activité, horodaté, non modifiable.
 * Pas de colonne updated_at : un log ne se modifie jamais après écriture.
 */
class ActivityLog extends Model
{
    use BelongsToMarkaz, HasFactory;

    const UPDATED_AT = null;

    protected $fillable = [
        'markaz_id', 'user_id', 'action', 'entity_type', 'entity_id', 'description', 'meta',
    ];

    protected $casts = [
        'meta' => 'array',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Enregistre une entrée de journal pour l'utilisateur authentifié courant.
     */
    public static function record(string $action, ?Model $entity = null, ?string $description = null, array $meta = []): self
    {
        $user = Auth::user();

        return static::create([
            'markaz_id' => $user?->markaz_id,
            'user_id' => $user?->id,
            'action' => $action,
            'entity_type' => $entity ? $entity::class : null,
            'entity_id' => $entity?->getKey(),
            'description' => $description,
            'meta' => $meta,
        ]);
    }
}
