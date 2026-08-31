<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// CDC section 18 / 21 : table "generated_documents" — registre polymorphique
// de tous les documents PDF produits (reçu, rapport hebdo, rapport mensuel...),
// avec numérotation unique par Markaz et par type (ex: reçu n° MK-2026-000123).
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('generated_documents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('markaz_id')->constrained('markaz')->restrictOnDelete();
            $table->enum('type', ['receipt', 'weekly_report', 'monthly_report', 'other']);
            $table->string('number'); // ex: MK-2026-000123
            $table->string('documentable_type')->nullable();
            $table->unsignedBigInteger('documentable_id')->nullable();
            $table->string('template_version')->nullable();
            $table->string('file_path')->nullable();
            $table->foreignId('generated_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();

            $table->unique(['markaz_id', 'type', 'number']);
            $table->index(['markaz_id', 'type', 'created_at']);
            $table->index(['documentable_type', 'documentable_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('generated_documents');
    }
};
