// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recitation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecitationAdapter extends TypeAdapter<Recitation> {
  @override
  final int typeId = 7;

  @override
  Recitation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Recitation(
      id: fields[0] as String,
      studentId: fields[1] as String,
      markazId: fields[2] as String,
      date: fields[3] as DateTime,
      surah: fields[4] as String,
      status: fields[5] as RecitationStatus,
      ayahFrom: fields[6] as int?,
      ayahTo: fields[7] as int?,
      note: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Recitation obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.studentId)
      ..writeByte(2)
      ..write(obj.markazId)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.surah)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.ayahFrom)
      ..writeByte(7)
      ..write(obj.ayahTo)
      ..writeByte(8)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecitationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecitationStatusAdapter extends TypeAdapter<RecitationStatus> {
  @override
  final int typeId = 8;

  @override
  RecitationStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecitationStatus.recited;
      case 1:
        return RecitationStatus.notRecited;
      case 2:
        return RecitationStatus.partial;
      default:
        return RecitationStatus.recited;
    }
  }

  @override
  void write(BinaryWriter writer, RecitationStatus obj) {
    switch (obj) {
      case RecitationStatus.recited:
        writer.writeByte(0);
        break;
      case RecitationStatus.notRecited:
        writer.writeByte(1);
        break;
      case RecitationStatus.partial:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecitationStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
