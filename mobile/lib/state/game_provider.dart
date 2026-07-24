import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/gamification.dart';

class XpEvent {
  final int amount;
  final String reason;
  final int timestamp;
  XpEvent({required this.amount, required this.reason, required this.timestamp});

  Map<String, dynamic> toJson() => {'amount': amount, 'reason': reason, 'timestamp': timestamp};
  factory XpEvent.fromJson(Map<String, dynamic> json) =>
      XpEvent(amount: json['amount'], reason: json['reason'], timestamp: json['timestamp']);
}

/// Mirrors the web app's Zustand `gameStore` (XP/levels/badges/missions/career), persisted
/// locally via SharedPreferences instead of localStorage.
class GameProvider extends ChangeNotifier {
  static const _prefsKey = 'genebreed_ai_save_v1';

  int totalXp = 0;
  List<String> unlockedBadgeIds = [];
  List<XpEvent> xpLog = [];
  int publications = 0;
  int grants = 0;
  ThemeMode themeMode = ThemeMode.light;
  List<String> completedMissionIds = [];

  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      totalXp = json['totalXp'] ?? 0;
      unlockedBadgeIds = List<String>.from(json['unlockedBadgeIds'] ?? []);
      xpLog = (json['xpLog'] as List<dynamic>? ?? []).map((e) => XpEvent.fromJson(e)).toList();
      publications = json['publications'] ?? 0;
      grants = json['grants'] ?? 0;
      themeMode = (json['theme'] == 'dark') ? ThemeMode.dark : ThemeMode.light;
      completedMissionIds = List<String>.from(json['completedMissionIds'] ?? []);
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final json = {
      'totalXp': totalXp,
      'unlockedBadgeIds': unlockedBadgeIds,
      'xpLog': xpLog.take(50).map((e) => e.toJson()).toList(),
      'publications': publications,
      'grants': grants,
      'theme': themeMode == ThemeMode.dark ? 'dark' : 'light',
      'completedMissionIds': completedMissionIds,
    };
    await prefs.setString(_prefsKey, jsonEncode(json));
  }

  void addXp(int amount, String reason) {
    totalXp += amount;
    xpLog = [XpEvent(amount: amount, reason: reason, timestamp: DateTime.now().millisecondsSinceEpoch), ...xpLog].take(50).toList();
    notifyListeners();
    _persist();
  }

  void unlockBadge(String badgeId) {
    if (unlockedBadgeIds.contains(badgeId)) return;
    unlockedBadgeIds = [...unlockedBadgeIds, badgeId];
    notifyListeners();
    _persist();
  }

  void addPublication() {
    publications += 1;
    notifyListeners();
    _persist();
  }

  void addGrant() {
    grants += 1;
    notifyListeners();
    _persist();
  }

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    _persist();
  }

  void completeMission(String id) {
    if (completedMissionIds.contains(id)) return;
    completedMissionIds = [...completedMissionIds, id];
    notifyListeners();
    _persist();
  }

  LevelInfo get levelInfo => levelForTotalXp(totalXp);
  CareerRank get rank => rankForLevel(levelInfo.level);
}
