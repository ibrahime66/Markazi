<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// CDC section 8.6 / 18 : table "attendances" — présences journalières.
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('attendances', function (Blueprint $table) {
            $table->id();
            $table->foreignId('markaz_id')->constrained('markaz')->restrictOnDelete();
            $table->foreignId('student_id')->constrained('students')->cascadeOnDelete();
            $table->foreignId('class_id')->nullable()->constrained('classes')->nullOnDelete();
            $table->date('date');
            $table->enum('status', ['present', 'absent', 'late', 'justified']);
            $table->string('lesson')->nullable(); // matière/sourate étudiée ce jour-là
            $table->text('note')->nullable();
            $table->foreignId('recorded_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();

            $table->unique(['student_id', 'date']);
            $table->index(['markaz_id', 'date']);
            $table->index(['markaz_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('attendances');
    }
};
