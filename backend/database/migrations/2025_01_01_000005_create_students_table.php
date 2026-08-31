<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// CDC section 8.3 / 18 : table "students".
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('students', function (Blueprint $table) {
            $table->id();
            $table->foreignId('markaz_id')->constrained('markaz')->restrictOnDelete();
            $table->foreignId('class_id')->nullable()->constrained('classes')->nullOnDelete();
            $table->foreignId('guardian_id')->nullable()->constrained('guardians')->nullOnDelete();
            $table->string('name');
            $table->enum('gender', ['m', 'f'])->nullable();
            $table->date('birth_date')->nullable();
            // Conservé pour accès rapide même sans fiche parent complète (tuteur direct).
            $table->string('parent_phone')->nullable();
            $table->string('photo_path')->nullable();
            $table->date('enrollment_date')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->softDeletes();

            $table->index(['markaz_id', 'id']);
            $table->index(['markaz_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('students');
    }
};
