import 'package:hive/hive.dart';

part 'entry.g.dart'; // Generated file

@HiveType(typeId: 0) // Unique typeId for this model
class Entry {
  @HiveField(0)
  final String carPlate;

  @HiveField(1)
  final DateTime entryTime;

  @HiveField(2)
  DateTime? exitTime;

  @HiveField(3)
  bool isPaid;

  Entry(this.carPlate, this.entryTime, {this.exitTime, this.isPaid = false});

  double calculateFee() {
    if (exitTime == null) return 0.0;

    final duration = exitTime!.difference(entryTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours < 3) {
      return 30.0;
    } else {
      return 30.0 + (hours - 3) * 20.0 + (minutes > 0 ? 20.0 : 0.0);
    }
  }
}
