<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

/**
 * CDC section 8.3 — Ajout / modification d'un élève.
 */
class StudentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            // "sometimes" : la même requête sert à la création (POST, où le
            // nom est requis) et aux mises à jour ciblées (PUT) d'un seul
            // champ — affectation à un groupe (class_id) ou à un tuteur
            // (guardian_id) — sans renvoyer tout le profil. Avant ce
            // correctif, ces deux affectations échouaient systématiquement
            // avec une erreur 422 "name obligatoire" (doc/audit.md, point I5
            // — bug découvert en corrigeant le rattachement tuteur↔élève,
            // touchait déjà l'affectation aux groupes).
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'class_id' => [
                'nullable',
                Rule::exists('classes', 'id')->where('markaz_id', $this->user()->markaz_id),
            ],
            'guardian_id' => [
                'nullable',
                Rule::exists('guardians', 'id')->where('markaz_id', $this->user()->markaz_id),
            ],
            'gender' => ['nullable', Rule::in(['m', 'f'])],
            'birth_date' => ['nullable', 'date'],
            'parent_phone' => ['nullable', 'string', 'max:30'],
            'enrollment_date' => ['nullable', 'date'],
            'is_active' => ['sometimes', 'boolean'],
        ];
    }
}
