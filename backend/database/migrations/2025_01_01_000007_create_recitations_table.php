<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// CDC section 8.5 / 18 : table "recitations" — séances de récitation coranique.
// Fonctionnalité absente de l'implémentation Flutter actuelle : introduite ici
// pour se conformer au CDC (statut récité / non récité / partiel).
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('recitations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('markaz_id')->constrained('markaz')->restrictOnDelete();
            $table->foreignId('student_id')->constrained('students')->cascadeOnDelete();
            $table->date('date');
            $table->string('surah'); // sourate étudiée
            $table->unsignedSmallInteger('ayah_from')->nullable();
            $table->unsignedSmallInteger('ayah_to')->nullable();
            $table->enum('status', ['recited', 'not_recited', 'partial']);
            $table->text('note')->nullable();
            $table->foreignId('recorded_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();

            $table->index(['markaz_id', 'student_id', 'date']);
            $table->index(['markaz_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('recitations');
    }
};
