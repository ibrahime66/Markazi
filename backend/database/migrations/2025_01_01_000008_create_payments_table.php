<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// CDC section 8.7 / 18 : table "payments" — paiements enregistrés manuellement.
// Pas de contrainte unique dure sur (student_id, month) : le CDC demande une
// "détection des doublons évidents" avec confirmation explicite possible,
// donc le contrôle se fait en application (PaymentService), pas en base.
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('markaz_id')->constrained('markaz')->restrictOnDelete();
            $table->foreignId('student_id')->constrained('students')->cascadeOnDelete();
            $table->decimal('amount', 10, 2);
            $table->date('month'); // premier jour du mois concerné par le paiement
            $table->enum('status', ['paid', 'unpaid', 'partial'])->default('unpaid');
            $table->enum('payment_mode', ['cash', 'other'])->default('cash');
            $table->text('observation')->nullable();
            $table->string('receipt_number')->nullable();
            $table->dateTime('paid_at')->nullable();
            $table->foreignId('recorded_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();

            $table->unique(['markaz_id', 'receipt_number']);
            $table->index(['markaz_id', 'student_id', 'month']);
            $table->index(['markaz_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('payments');
    }
};
