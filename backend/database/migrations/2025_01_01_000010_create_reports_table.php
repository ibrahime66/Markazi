<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// CDC section 8.8 / 18 : table "reports" — méta des rapports hebdo/mensuels générés.
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('reports', function (Blueprint $table) {
            $table->id();
            $table->foreignId('markaz_id')->constrained('markaz')->restrictOnDelete();
            $table->foreignId('student_id')->constrained('students')->cascadeOnDelete();
            $table->enum('type', ['weekly', 'monthly']);
            $table->date('period_start');
            $table->date('period_end');
            $table->json('data')->nullable(); // statistiques calculées au moment de la génération
            $table->foreignId('generated_document_id')->nullable()
                ->constrained('generated_documents')->nullOnDelete();
            $table->foreignId('generated_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();

            $table->index(['markaz_id', 'student_id', 'type']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('reports');
    }
};
