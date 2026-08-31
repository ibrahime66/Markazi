<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

/**
 * CDC section 8.7 — Enregistrement manuel d'un paiement.
 * "confirm_duplicate" permet de passer outre l'avertissement de doublon
 * évident détecté par PaymentController (même élève, même mois).
 */
class PaymentRequest extends FormRequest
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
            'amount' => ['required', 'numeric', 'min:0'],
            'month' => ['required', 'date'],
            'status' => ['required', Rule::in(['paid', 'unpaid', 'partial'])],
            'payment_mode' => ['required', Rule::in(['cash', 'other'])],
            'observation' => ['nullable', 'string'],
            'paid_at' => ['nullable', 'date'],
            'confirm_duplicate' => ['sometimes', 'boolean'],
        ];
    }
}
