// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_queue_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncQueueItemAdapter extends TypeAdapter<SyncQueueItem> {
  @override
  final int typeId = 9;

  @override
  SyncQueueItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncQueueItem(
      id: fields[0] as String,
      entityType: fields[1] as SyncEntityType,
      operation: fields[2] as SyncOperation,
      entityId: fields[3] as String,
      createdAt: fields[4] as DateTime,
      performedAt: fields[5] as DateTime?,
      lastError: fields[6] as String?,
      payload: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SyncQueueItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.entityType)
      ..writeByte(2)
      ..write(obj.operation)
      ..writeByte(3)
      ..write(obj.entityId)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.performedAt)
      ..writeByte(6)
      ..write(obj.lastError)
      ..writeByte(7)
      ..write(obj.payload);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncQueueItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SyncOperationAdapter extends TypeAdapter<SyncOperation> {
  @override
  final int typeId = 10;

  @override
  SyncOperation read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SyncOperation.update;
      case 1:
        return SyncOperation.delete;
      case 2:
        return SyncOperation.create;
      default:
        return SyncOperation.update;
    }
  }

  @override
  void write(BinaryWriter writer, SyncOperation obj) {
    switch (obj) {
      case SyncOperation.update:
        writer.writeByte(0);
        break;
      case SyncOperation.delete:
        writer.writeByte(1);
        break;
      case SyncOperation.create:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncOperationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SyncEntityTypeAdapter extends TypeAdapter<SyncEntityType> {
  @override
  final int typeId = 11;

  @override
  SyncEntityType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SyncEntityType.payment;
      case 1:
        return SyncEntityType.attendance;
      case 2:
        return SyncEntityType.guardian;
      case 3:
        return SyncEntityType.recitation;
      case 4:
        return SyncEntityType.classModel;
      case 5:
        return SyncEntityType.studentClass;
      default:
        return SyncEntityType.payment;
    }
  }

  @override
  void write(BinaryWriter writer, SyncEntityType obj) {
    switch (obj) {
      case SyncEntityType.payment:
        writer.writeByte(0);
        break;
      case SyncEntityType.attendance:
        writer.writeByte(1);
        break;
      case SyncEntityType.guardian:
        writer.writeByte(2);
        break;
      case SyncEntityType.recitation:
        writer.writeByte(3);
        break;
      case SyncEntityType.classModel:
        writer.writeByte(4);
        break;
      case SyncEntityType.studentClass:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncEntityTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
