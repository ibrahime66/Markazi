<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

/**
 * CDC section 8.1 — Inscription du Maître + création de la fiche Markaz.
 */
class RegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:6', 'confirmed'],
            'markaz_name' => ['required', 'string', 'max:255'],
            'markaz_city' => ['nullable', 'string', 'max:255'],
            'markaz_country' => ['nullable', 'string', 'max:255'],
            'markaz_phone' => ['nullable', 'string', 'max:30'],
            'markaz_address' => ['nullable', 'string', 'max:255'],
        ];
    }
}
