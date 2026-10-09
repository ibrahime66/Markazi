<?php

namespace App\Models;

use App\Models\Concerns\BelongsToMarkaz;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;
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
        'performed_at',
    ];

    protected $casts = [
        'meta' => 'array',
        'performed_at' => 'datetime',
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
        $performedAt = static::performedAt();

        if ($performedAt !== null) {
            // Action saisie hors ligne puis rejouée (CDC §20).
            $meta['synced_offline'] = true;
        }

        return static::create([
            'markaz_id' => $user?->markaz_id,
            'user_id' => $user?->id,
            'action' => $action,
            'entity_type' => $entity ? $entity::class : null,
            'entity_id' => $entity?->getKey(),
            'description' => $description,
            'meta' => $meta,
            // CDC §27 : date réelle de réalisation, pas date de synchronisation.
            'performed_at' => $performedAt ?? Carbon::now(),
        ]);
    }

    /**
     * Date réelle de l'action quand la requête rejoue une saisie hors ligne
     * (en-tête X-Performed-At, voir CapturePerformedAt), sinon null.
     */
    public static function performedAt(): ?Carbon
    {
        $value = request()?->attributes->get('performed_at');

        return $value instanceof Carbon ? $value : null;
    }

    /**
     * CDC §20 — gestion des conflits : "dernière écriture serveur gagnante,
     * avec conservation d'une trace du conflit dans le journal d'activité
     * pour arbitrage manuel". À appeler AVANT d'appliquer une modification
     * ou une suppression rejouée : si la ressource a été modifiée côté
     * serveur après la date réelle de l'action hors ligne (autre appareil,
     * autre saisie), l'état serveur écrasé est conservé dans le journal.
     * Sans effet pour une requête en ligne classique.
     */
    public static function recordSyncConflictIfStale(Model $entity, string $operation): void
    {
        $performedAt = static::performedAt();
        $serverUpdatedAt = $entity->getAttribute('updated_at');

        if ($performedAt === null || $serverUpdatedAt === null) {
            return;
        }

        if (Carbon::parse($serverUpdatedAt)->lte($performedAt)) {
            return;
        }

        $label = class_basename($entity);

        static::record('sync.conflict', $entity, "Conflit de synchronisation ({$label} #{$entity->getKey()}) : la version serveur, plus récente que l'action hors ligne, a été remplacée", [
            'operation' => $operation,
            'server_updated_at' => Carbon::parse($serverUpdatedAt)->toIso8601String(),
            'performed_at' => $performedAt->toIso8601String(),
            'overwritten_server_version' => collect($entity->getAttributes())
                ->except(['markaz_id', 'created_at', 'deleted_at'])
                ->all(),
        ]);
    }
}
