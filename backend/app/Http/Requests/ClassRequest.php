<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

/**
 * CDC section 8.4 — Création / modification d'une classe.
 */
class ClassRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'level' => ['nullable', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'teacher_id' => [
                'nullable',
                Rule::exists('users', 'id')->where('markaz_id', $this->user()->markaz_id),
            ],
            'max_students' => ['required', 'integer', 'min:1', 'max:200'],
            'schedule' => ['nullable', 'string', 'max:255'],
            'room' => ['nullable', 'string', 'max:255'],
            'is_active' => ['sometimes', 'boolean'],
        ];
    }
}
