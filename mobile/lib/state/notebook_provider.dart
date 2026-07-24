import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotebookEntry {
  final String id;
  final String cropId;
  final String date;
  final String observationType; // flowering | disease-score | yield | height | general
  final String value;
  final String notes;
  final String? imagePath;

  NotebookEntry({
    required this.id,
    required this.cropId,
    required this.date,
    required this.observationType,
    required this.value,
    required this.notes,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'cropId': cropId,
        'date': date,
        'observationType': observationType,
        'value': value,
        'notes': notes,
        'imagePath': imagePath,
      };

  factory NotebookEntry.fromJson(Map<String, dynamic> json) => NotebookEntry(
        id: json['id'],
        cropId: json['cropId'],
        date: json['date'],
        observationType: json['observationType'],
        value: json['value'],
        notes: json['notes'] ?? '',
        imagePath: json['imagePath'],
      );
}

/// Mirrors the web app's `notebookStore` — field observation logging persisted locally.
class NotebookProvider extends ChangeNotifier {
  static const _prefsKey = 'genebreed_ai_notebook_v1';

  List<NotebookEntry> entries = [];
  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      entries = list.map((e) => NotebookEntry.fromJson(e)).toList();
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(entries.map((e) => e.toJson()).toList()));
  }

  void addEntry({
    required String cropId,
    required String date,
    required String observationType,
    required String value,
    required String notes,
    String? imagePath,
  }) {
    final entry = NotebookEntry(
      id: 'note-${DateTime.now().millisecondsSinceEpoch}',
      cropId: cropId,
      date: date,
      observationType: observationType,
      value: value,
      notes: notes,
      imagePath: imagePath,
    );
    entries = [entry, ...entries];
    notifyListeners();
    _persist();
  }

  void removeEntry(String id) {
    entries = entries.where((e) => e.id != id).toList();
    notifyListeners();
    _persist();
  }
}
