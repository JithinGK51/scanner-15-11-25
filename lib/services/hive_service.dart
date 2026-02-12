import 'package:hive_flutter/hive_flutter.dart';
import '../models/scan_history_item.dart';

class HiveService {
  static const String historyBoxName = 'scan_history';
  static const String settingsBoxName = 'app_settings';
  static const String onboardingKey = 'onboarding_completed';
  static const String darkModeKey = 'dark_mode';
  static const String soundKey = 'sound_enabled';
  static const String vibrationKey = 'vibration_enabled';

  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    
    await Hive.initFlutter();
    Hive.registerAdapter(ScanHistoryItemAdapter());
    await Hive.openBox<ScanHistoryItem>(historyBoxName);
    await Hive.openBox(settingsBoxName);
    
    _isInitialized = true;
  }

  static Box<ScanHistoryItem> get historyBox =>
      Hive.box<ScanHistoryItem>(historyBoxName);

  static Box get settingsBox => Hive.box(settingsBoxName);

  static Future<void> saveHistoryItem(ScanHistoryItem item) async {
    await historyBox.put(item.id, item);
  }

  static List<ScanHistoryItem> getHistoryItems() {
    return historyBox.values.toList().reversed.toList();
  }

  static Future<void> deleteHistoryItem(String id) async {
    await historyBox.delete(id);
  }

  static Future<void> clearAllHistory() async {
    await historyBox.clear();
  }

  static bool isOnboardingCompleted() {
    return settingsBox.get(onboardingKey, defaultValue: false) as bool;
  }

  static Future<void> setOnboardingCompleted(bool value) async {
    await settingsBox.put(onboardingKey, value);
  }

  static bool isDarkMode() {
    return settingsBox.get(darkModeKey, defaultValue: false) as bool;
  }

  static Future<void> setDarkMode(bool value) async {
    await settingsBox.put(darkModeKey, value);
  }

  static bool isSoundEnabled() {
    return settingsBox.get(soundKey, defaultValue: true) as bool;
  }

  static Future<void> setSoundEnabled(bool value) async {
    await settingsBox.put(soundKey, value);
  }

  static bool isVibrationEnabled() {
    return settingsBox.get(vibrationKey, defaultValue: true) as bool;
  }

  static Future<void> setVibrationEnabled(bool value) async {
    await settingsBox.put(vibrationKey, value);
  }
}

