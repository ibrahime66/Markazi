// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClassModelAdapter extends TypeAdapter<ClassModel> {
  @override
  final int typeId = 5;

  @override
  ClassModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClassModel(
      id: fields[0] as String,
      name: fields[1] as String,
      level: fields[2] as String,
      description: fields[3] as String,
      teacherId: fields[4] as String,
      teacherName: fields[5] as String,
      maxStudents: fields[6] as int,
      studentIds: (fields[7] as List).cast<String>(),
      markazId: fields[8] as String,
      createdAt: fields[9] as DateTime,
      isActive: fields[10] as bool,
      schedule: fields[11] as String?,
      room: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ClassModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.level)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.teacherId)
      ..writeByte(5)
      ..write(obj.teacherName)
      ..writeByte(6)
      ..write(obj.maxStudents)
      ..writeByte(7)
      ..write(obj.studentIds)
      ..writeByte(8)
      ..write(obj.markazId)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.isActive)
      ..writeByte(11)
      ..write(obj.schedule)
      ..writeByte(12)
      ..write(obj.room);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
