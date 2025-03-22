import 'package:hive_flutter/hive_flutter.dart';
import 'entry.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(EntryAdapter());
    await Hive.openBox<Entry>('entriesBox');
  }
}
