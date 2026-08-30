<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class LoginRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
            // Nom de l'appareil, pour permettre un token révocable par appareil (CDC 14).
            'device_name' => ['nullable', 'string', 'max:255'],
        ];
    }
}
