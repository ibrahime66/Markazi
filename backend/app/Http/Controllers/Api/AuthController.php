<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Models\ActivityLog;
use App\Models\Markaz;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

/**
 * CDC section 8.1 — Authentification et gestion de compte.
 * Un token Sanctum par appareil (CDC section 14).
 */
class AuthController extends Controller
{
    /**
     * Inscription du Maître : crée la fiche Markaz et le compte utilisateur associé.
     */
    public function register(RegisterRequest $request)
    {
        $data = $request->validated();

        $user = DB::transaction(function () use ($data) {
            $markaz = Markaz::create([
                'name' => $data['markaz_name'],
                'city' => $data['markaz_city'] ?? null,
                'country' => $data['markaz_country'] ?? 'Guinée',
                'phone' => $data['markaz_phone'] ?? null,
                'address' => $data['markaz_address'] ?? null,
            ]);

            return User::create([
                'markaz_id' => $markaz->id,
                'name' => $data['name'],
                'email' => $data['email'],
                'password' => $data['password'],
                'role' => 'teacher',
            ]);
        });

        $token = $user->createToken($data['name'].'-registration')->plainTextToken;

        ActivityLog::record('user.registered', $user, 'Inscription du Maître et création du Markaz');

        return response()->json([
            'user' => $user->load('markaz'),
            'token' => $token,
        ], 201);
    }

    /**
     * Connexion : un token par appareil, révocable individuellement.
     */
    public function login(LoginRequest $request)
    {
        $data = $request->validated();

        $user = User::where('email', $data['email'])->first();

        if (! $user || ! Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => [__('Email ou mot de passe incorrect.')],
            ]);
        }

        $deviceName = $data['device_name'] ?? 'appareil-inconnu';
        $token = $user->createToken($deviceName)->plainTextToken;

        ActivityLog::record('user.logged_in', $user, "Connexion depuis {$deviceName}", ['subject' => $deviceName]);

        return response()->json([
            'user' => $user->load('markaz'),
            'token' => $token,
        ]);
    }

    /**
     * Déconnexion : révoque uniquement le token de l'appareil courant.
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => __('Déconnecté.')]);
    }

    public function me(Request $request)
    {
        return response()->json($request->user()->load('markaz'));
    }

    public function forgotPassword(Request $request)
    {
        $request->validate(['email' => ['required', 'email']]);

        $status = Password::sendResetLink($request->only('email'));

        return $status === Password::RESET_LINK_SENT
            ? response()->json(['message' => __('Lien de réinitialisation envoyé.')])
            : response()->json(['message' => __('Impossible d\'envoyer le lien de réinitialisation.')], 422);
    }

    public function resetPassword(Request $request)
    {
        $request->validate([
            'token' => ['required'],
            'email' => ['required', 'email'],
            'password' => ['required', 'string', 'min:6', 'confirmed'],
        ]);

        $status = Password::reset(
            $request->only('email', 'password', 'password_confirmation', 'token'),
            function (User $user, string $password) {
                $user->forceFill(['password' => $password])->save();
                $user->tokens()->delete();
            }
        );

        return $status === Password::PASSWORD_RESET
            ? response()->json(['message' => __('Mot de passe réinitialisé.')])
            : response()->json(['message' => __('Jeton invalide ou expiré.')], 422);
    }

    public function changePassword(Request $request)
    {
        $request->validate([
            'current_password' => ['required', 'string'],
            'password' => ['required', 'string', 'min:6', 'confirmed'],
        ]);

        $user = $request->user();

        if (! Hash::check($request->input('current_password'), $user->password)) {
            throw ValidationException::withMessages([
                'current_password' => [__('Mot de passe actuel incorrect.')],
            ]);
        }

        $user->forceFill(['password' => $request->input('password')])->save();

        return response()->json(['message' => __('Mot de passe modifié.')]);
    }
}
