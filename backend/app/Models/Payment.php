<?php

namespace App\Models;

use App\Models\Concerns\BelongsToMarkaz;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

/**
 * CDC section 8.7 — table "payments".
 */
class Payment extends Model
{
    use BelongsToMarkaz, HasFactory, SoftDeletes;

    protected $fillable = [
        'markaz_id', 'student_id', 'amount', 'month', 'status',
        'payment_mode', 'observation', 'receipt_number', 'paid_at', 'recorded_by',
    ];

    protected $casts = [
        'month' => 'date',
        'paid_at' => 'datetime',
        'amount' => 'decimal:2',
    ];

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    public function recordedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'recorded_by');
    }
}
