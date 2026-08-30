<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// doc/audit.md, point D3 : la numérotation précédente calculait la séquence
// via un COUNT() sur "generated_documents", non fiable sous forte
// concurrence (deux requêtes concurrentes peuvent lire le même compte avant
// qu'aucune n'ait inséré). Cette table dédiée permet un incrément
// réellement atomique ("INSERT ... ON DUPLICATE KEY UPDATE") — une seule
// ligne par (markaz_id, type, année), impossible à lire en double.
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('document_counters', function (Blueprint $table) {
            $table->id();
            $table->foreignId('markaz_id')->constrained('markaz')->cascadeOnDelete();
            $table->enum('type', ['receipt', 'weekly_report', 'monthly_report', 'other']);
            $table->unsignedSmallInteger('year');
            $table->unsignedInteger('sequence')->default(0);

            $table->unique(['markaz_id', 'type', 'year']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('document_counters');
    }
};
