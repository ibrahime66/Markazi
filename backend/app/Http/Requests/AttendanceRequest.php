<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

/**
 * CDC section 8.6 — Marquage de présence : présent, absent, retard, absence justifiée.
 */
class AttendanceRequest extends FormRequest
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
            'class_id' => [
                'nullable',
                Rule::exists('classes', 'id')->where('markaz_id', $this->user()->markaz_id),
            ],
            'date' => ['required', 'date'],
            'status' => ['required', Rule::in(['present', 'absent', 'late', 'justified'])],
            'lesson' => ['nullable', 'string', 'max:255'],
            'note' => ['nullable', 'string'],
        ];
    }
}
