<?php

namespace App\Policies;

use App\Models\Markaz;
use App\Models\User;

/**
 * Un maître ne consulte/modifie que la fiche de son propre Markaz.
 * Pas de create/delete exposés en V1 : le Markaz est créé à l'inscription (AuthController).
 */
class MarkazPolicy
{
    public function view(User $user, Markaz $markaz): bool
    {
        return $user->isSuperAdmin() || $user->markaz_id === $markaz->id;
    }

    public function update(User $user, Markaz $markaz): bool
    {
        return $user->isSuperAdmin() || $user->markaz_id === $markaz->id;
    }
}
