import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_item.dart';

class HistoryService {
  String _detectCategory(String data) {
    if (data.startsWith('http://') || data.startsWith('https://')) {
      return 'URL';
    } else if (data.startsWith('mailto:')) {
      return 'Email';
    } else if (data.startsWith('tel:')) {
      return 'Phone';
    } else if (data.startsWith('sms:')) {
      return 'SMS';
    } else if (data.startsWith('WIFI:')) {
      return 'WiFi';
    } else {
      return 'Text';
    }
  }
  static const String _historyKey = 'scan_history';
  static const int _maxHistoryItems = 1000;

  Future<List<HistoryItem>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);
      
      if (historyJson == null) {
        return [];
      }

      final List<dynamic> historyList = json.decode(historyJson);
      return historyList
          .map((item) => HistoryItem.fromJson(item as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      return [];
    }
  }

  Future<void> addHistoryItem(HistoryItem item) async {
    try {
      final history = await getHistory();
      
      // Remove duplicate if exists (same data and type)
      history.removeWhere((h) => h.data == item.data && h.type == item.type);
      
      // Add new item at the beginning
      history.insert(0, item);
      
      // Limit history size
      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }

      await _saveHistory(history);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> deleteHistoryItem(String id) async {
    try {
      final history = await getHistory();
      history.removeWhere((item) => item.id == id);
      await _saveHistory(history);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      final history = await getHistory();
      final index = history.indexWhere((item) => item.id == id);
      
      if (index != -1) {
        history[index] = history[index].copyWith(
          isFavorite: !history[index].isFavorite,
        );
        await _saveHistory(history);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _saveHistory(List<HistoryItem> history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = json.encode(
        history.map((item) => item.toJson()).toList(),
      );
      await prefs.setString(_historyKey, historyJson);
    } catch (e) {
      // Handle error silently
    }
  }

  List<HistoryItem> filterHistory(
    List<HistoryItem> history,
    String filter,
    String searchQuery,
  ) {
    var filtered = history;

    // Apply filter
    if (filter == 'Scanned') {
      filtered = filtered.where((item) => item.type == 'Scanned').toList();
    } else if (filter == 'Generated') {
      filtered = filtered.where((item) => item.type == 'Generated').toList();
    } else if (filter == 'Favorites' || filter == 'Favc') {
      filtered = filtered.where((item) => item.isFavorite).toList();
    }

    // Apply search
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((item) {
        return item.data.toLowerCase().contains(query) ||
            item.displayTitle.toLowerCase().contains(query) ||
            item.category.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }
}

