<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

/**
 * CDC section 8.5 — Enregistrement d'une séance de récitation.
 */
class RecitationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'student_id' => [
                'required',
                Rule::exists('students', 'id')->where('markaz_id', $this->user()->markaz_id),
            ],
            'date' => ['required', 'date'],
            'surah' => ['required', 'string', 'max:255'],
            'ayah_from' => ['nullable', 'integer', 'min:1'],
            'ayah_to' => ['nullable', 'integer', 'min:1', 'gte:ayah_from'],
            'status' => ['required', Rule::in(['recited', 'not_recited', 'partial'])],
            'note' => ['nullable', 'string'],
        ];
    }
}
