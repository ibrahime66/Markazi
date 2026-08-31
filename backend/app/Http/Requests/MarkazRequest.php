<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

/**
 * CDC section 8.2 — Configuration des informations du Markaz.
 */
class MarkazRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'slogan' => ['nullable', 'string', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'city' => ['nullable', 'string', 'max:255'],
            'country' => ['nullable', 'string', 'max:255'],
            // Pas de validation stricte ISO 4217 : certains Markaz utilisent
            // un libellé informel ("FCFA") plutôt qu'un code à 3 lettres.
            'currency' => ['nullable', 'string', 'max:10'],
            'phone' => ['nullable', 'string', 'max:30'],
            'email' => ['nullable', 'email', 'max:255'],
            'website' => ['nullable', 'string', 'max:255'],
            'primary_color' => ['nullable', 'string', 'max:7'],
            'secondary_color' => ['nullable', 'string', 'max:7'],
            'working_days' => ['nullable', 'array'],
            'working_days.*' => ['string', 'in:mon,tue,wed,thu,fri,sat,sun'],
        ];
    }
}
