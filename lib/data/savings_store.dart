import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/savings_book.dart';

abstract class SavingsStore {
  Future<SavingsBook> load();

  Future<void> save(SavingsBook book);
}

class SharedPreferencesSavingsStore implements SavingsStore {
  SharedPreferencesSavingsStore(this._prefs);

  final SharedPreferences _prefs;

  /// v3 starts blank. Earlier keys held sample processes and contributions.
  static const storageKey = 'arescare.savings.v3';

  @override
  Future<SavingsBook> load() async {
    final raw = _prefs.getString(storageKey);
    if (raw == null) {
      return SavingsBook.empty;
    }
    return SavingsBook.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(SavingsBook book) async {
    await _prefs.setString(storageKey, jsonEncode(book.toJson()));
  }
}

class MemorySavingsStore implements SavingsStore {
  MemorySavingsStore([SavingsBook? initial])
    : _book = initial ?? SavingsBook.empty;

  SavingsBook _book;

  @override
  Future<SavingsBook> load() async => _book;

  @override
  Future<void> save(SavingsBook book) async {
    _book = book;
  }
}
