<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// CDC section 8.4 / 18 : table "classes" — une classe appartient à un seul Markaz.
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('classes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('markaz_id')->constrained('markaz')->restrictOnDelete();
            $table->string('name');
            $table->string('level')->nullable(); // Débutant, Intermédiaire, Avancé...
            $table->text('description')->nullable();
            $table->foreignId('teacher_id')->nullable()->constrained('users')->nullOnDelete();
            $table->unsignedInteger('max_students')->default(20);
            $table->string('schedule')->nullable(); // ex: "Lun, Mer, Ven - 16h-18h"
            $table->string('room')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->softDeletes();

            $table->index(['markaz_id', 'id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('classes');
    }
};
