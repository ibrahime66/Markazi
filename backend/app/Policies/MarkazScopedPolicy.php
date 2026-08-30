<?php

namespace App\Policies;

use App\Models\User;
use Illuminate\Database\Eloquent\Model;

/**
 * CDC section 16 — "un maître ne peut voir/modifier que les ressources de
 * son propre Markaz", vérifié systématiquement côté serveur.
 *
 * Deuxième couche de défense en plus du global scope Eloquent
 * (App\Models\Concerns\BelongsToMarkaz) : même si une requête contournait le
 * scope, la policy bloque toute action sur une ressource d'un autre Markaz.
 * Les policies concrètes héritent de cette base et n'ont normalement rien à
 * redéfinir pour le rôle "teacher" de la V1.
 */
abstract class MarkazScopedPolicy
{
    public function viewAny(User $user): bool
    {
        return $this->isActingWithinMarkaz($user);
    }

    public function view(User $user, Model $model): bool
    {
        return $this->ownsResource($user, $model);
    }

    public function create(User $user): bool
    {
        return $this->isActingWithinMarkaz($user);
    }

    public function update(User $user, Model $model): bool
    {
        return $this->ownsResource($user, $model);
    }

    public function delete(User $user, Model $model): bool
    {
        return $this->ownsResource($user, $model);
    }

    protected function isActingWithinMarkaz(User $user): bool
    {
        return $user->isSuperAdmin() || filled($user->markaz_id);
    }

    protected function ownsResource(User $user, Model $model): bool
    {
        if ($user->isSuperAdmin()) {
            return true;
        }

        return filled($user->markaz_id) && $user->markaz_id === $model->markaz_id;
    }
}
