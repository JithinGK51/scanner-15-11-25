// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_history_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScanHistoryItemAdapter extends TypeAdapter<ScanHistoryItem> {
  @override
  final int typeId = 0;

  @override
  ScanHistoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScanHistoryItem(
      id: fields[0] as String,
      data: fields[1] as String,
      type: fields[2] as String,
      timestamp: fields[3] as DateTime,
      format: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ScanHistoryItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.data)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.format);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanHistoryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

