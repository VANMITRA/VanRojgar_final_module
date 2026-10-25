import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Where the phone keeps small text values. [HiveCacheStore] is the real one (encrypted); tests and the demo use
/// [MemoryCacheStore].
abstract class CacheStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class MemoryCacheStore implements CacheStore {
  final Map<String, String> _data = {};

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async => _data[key] = value;

  @override
  Future<void> delete(String key) async => _data.remove(key);
}

/// Opens the store the first time it is used, so starting the app never waits for it.
class LazyCacheStore implements CacheStore {
  LazyCacheStore(this._open);

  final Future<CacheStore> Function() _open;
  Future<CacheStore>? _store;

  Future<CacheStore> get _ready => _store ??= _open();

  @override
  Future<String?> read(String key) async => (await _ready).read(key);

  @override
  Future<void> write(String key, String value) async => (await _ready).write(key, value);

  @override
  Future<void> delete(String key) async => (await _ready).delete(key);
}

/// An encrypted Hive box. The key is made once and kept in the phone's secure storage. If the phone cannot give a
/// secure key, nothing personal is written to disk: the values are kept in memory for this run only.
class HiveCacheStore implements CacheStore {
  HiveCacheStore._(this._box);

  final Box<String> _box;

  static const _boxName = 'livelihood_cache';
  static const _keyName = 'livelihood_cache_key';

  static Future<CacheStore> open() async {
    try {
      await Hive.initFlutter();
      const secure = FlutterSecureStorage();
      var encoded = await secure.read(key: _keyName);
      if (encoded == null) {
        final random = Random.secure();
        encoded = base64UrlEncode(List<int>.generate(32, (_) => random.nextInt(256)));
        await secure.write(key: _keyName, value: encoded);
      }
      final box = await Hive.openBox<String>(_boxName, encryptionCipher: HiveAesCipher(base64Url.decode(encoded)));
      return HiveCacheStore._(box);
    } catch (_) {
      return MemoryCacheStore();
    }
  }

  @override
  Future<String?> read(String key) async => _box.get(key);

  @override
  Future<void> write(String key, String value) => _box.put(key, value);

  @override
  Future<void> delete(String key) => _box.delete(key);
}

/// JSON values and yes/no flags on top of a [CacheStore]. A damaged value is deleted and read as missing, never shown.
class LivelihoodCache {
  LivelihoodCache(this._store);

  final CacheStore _store;

  static const profileKey = 'profile';
  static const reportKey = 'report';
  static const profileDirtyKey = 'profile_dirty';
  static const deletePendingKey = 'delete_pending';

  Future<Map<String, dynamic>?> readJson(String key) async {
    final text = await _store.read(key);
    if (text == null) return null;
    try {
      final value = jsonDecode(text);
      if (value is Map<String, dynamic>) return value;
    } catch (_) {
      // fall through: damaged
    }
    await _store.delete(key);
    return null;
  }

  Future<void> writeJson(String key, Map<String, dynamic> value) => _store.write(key, jsonEncode(value));

  Future<void> remove(String key) => _store.delete(key);

  Future<bool> flag(String key) async => (await _store.read(key)) == '1';

  Future<void> setFlag(String key, bool value) =>
      value ? _store.write(key, '1') : _store.delete(key);

  /// His details and the report made from them are gone from the phone (rule L8). A promise to delete them on the
  /// server is kept: it is not personal data, it is what makes the delete finish later.
  Future<void> clearPersonal() async {
    await _store.delete(profileKey);
    await _store.delete(reportKey);
    await _store.delete(profileDirtyKey);
  }
}
