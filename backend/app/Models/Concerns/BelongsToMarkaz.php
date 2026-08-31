<?php

namespace App\Models\Concerns;

use App\Models\User;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Auth;

/**
 * CDC section 16 — Architecture multi-tenant.
 *
 * Applique automatiquement le filtre markaz_id à toute requête et à toute
 * création sur les modèles qui l'utilisent, afin qu'aucune lecture/écriture
 * ne puisse omettre l'isolation par Markaz (global scope Eloquent).
 *
 * - Un utilisateur "super_admin" (rôle plateforme, hors périmètre V1) n'est
 *   pas filtré : il voit tous les Markaz.
 * - En dehors d'un contexte HTTP authentifié (commandes artisan, seeders,
 *   jobs), le scope ne s'applique pas : c'est au code appelant de filtrer
 *   explicitement (ex: ->withoutGlobalScope() n'est alors pas nécessaire).
 */
trait BelongsToMarkaz
{
    public static function bootBelongsToMarkaz(): void
    {
        static::addGlobalScope('markaz', function (Builder $builder) {
            $user = Auth::user();

            if ($user instanceof User && $user->role !== 'super_admin' && $user->markaz_id) {
                $builder->where($builder->getModel()->getTable().'.markaz_id', $user->markaz_id);
            }
        });

        static::creating(function ($model) {
            if (empty($model->markaz_id)) {
                $user = Auth::user();
                if ($user instanceof User && $user->markaz_id) {
                    $model->markaz_id = $user->markaz_id;
                }
            }
        });
    }

    public function markaz(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(\App\Models\Markaz::class);
    }
}
