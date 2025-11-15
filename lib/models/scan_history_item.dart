import 'package:hive/hive.dart';

part 'scan_history_item.g.dart';

@HiveType(typeId: 0)
class ScanHistoryItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String data;

  @HiveField(2)
  final String type; // 'qr' or 'barcode'

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final String? format; // barcode format if applicable

  ScanHistoryItem({
    required this.id,
    required this.data,
    required this.type,
    required this.timestamp,
    this.format,
  });

  String get formattedDate {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

