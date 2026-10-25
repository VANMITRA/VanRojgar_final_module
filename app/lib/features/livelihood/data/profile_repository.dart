import '../models/profile.dart';
import 'livelihood_api.dart';
import 'livelihood_cache.dart';

abstract class ProfileRepository {
  /// His saved details, or null if he has none.
  Future<LivelihoodProfile?> load();

  /// Throws when the server refuses the details; nothing is kept then.
  Future<void> save(LivelihoodProfile profile);

  /// Delete his answers everywhere (rule L8).
  Future<void> delete();

  /// True while something is saved on the phone but has not reached the server yet.
  bool get pendingSync;
}

/// Offline first: every change is kept on the phone at once and sent to the server when there is a connection. A
/// refusal from the server (for example a place outside Maharashtra) is not kept. A delete that could not be sent is
/// remembered and retried, and while it waits the old answers are never fetched back.
class OfflineFirstProfileRepository implements ProfileRepository {
  OfflineFirstProfileRepository(this._api, this._cache);

  final LivelihoodApi _api;
  final LivelihoodCache _cache;
  bool _pending = false;

  static const _path = '/livelihood/profile';

  @override
  bool get pendingSync => _pending;

  Future<void> _refreshPending() async {
    _pending = await _cache.flag(LivelihoodCache.profileDirtyKey) ||
        await _cache.flag(LivelihoodCache.deletePendingKey);
  }

  @override
  Future<void> save(LivelihoodProfile profile) async {
    final previous = await _cache.readJson(LivelihoodCache.profileKey);
    final previousDirty = await _cache.flag(LivelihoodCache.profileDirtyKey);
    await _cache.setFlag(LivelihoodCache.deletePendingKey, false); // saving again cancels a waiting delete
    await _cache.writeJson(LivelihoodCache.profileKey, profile.toJson());
    await _cache.setFlag(LivelihoodCache.profileDirtyKey, true);
    try {
      await _api.put(_path, body: profile.toJson());
      await _cache.setFlag(LivelihoodCache.profileDirtyKey, false);
    } on NetworkException {
      // kept on the phone, sent on the next load
    } on ApiException {
      if (previous == null) {
        await _cache.remove(LivelihoodCache.profileKey);
      } else {
        await _cache.writeJson(LivelihoodCache.profileKey, previous);
      }
      await _cache.setFlag(LivelihoodCache.profileDirtyKey, previousDirty);
      await _refreshPending();
      rethrow;
    }
    await _refreshPending();
  }

  @override
  Future<LivelihoodProfile?> load() async {
    if (await _cache.flag(LivelihoodCache.deletePendingKey)) {
      try {
        await _api.delete(_path);
        await _cache.setFlag(LivelihoodCache.deletePendingKey, false);
        await _cache.clearPersonal();
      } on NetworkException {
        // still offline: nothing is shown, the delete stays promised
      } on ApiException catch (e) {
        if (e.statusCode == 404) {
          await _cache.setFlag(LivelihoodCache.deletePendingKey, false);
        } else {
          await _refreshPending();
          rethrow;
        }
      }
      await _refreshPending();
      return null;
    }

    if (await _cache.flag(LivelihoodCache.profileDirtyKey)) {
      final local = await _cache.readJson(LivelihoodCache.profileKey);
      if (local != null) {
        try {
          await _api.put(_path, body: local);
          await _cache.setFlag(LivelihoodCache.profileDirtyKey, false);
        } on NetworkException {
          // keep it for next time
        } on ApiException {
          // the server will not take it: do not keep trying forever
          await _cache.setFlag(LivelihoodCache.profileDirtyKey, false);
        }
      }
    }

    try {
      final out = await _api.get(_path) as Map<String, dynamic>;
      final profileJson = Map<String, dynamic>.from(out['profile'] as Map);
      final profile = LivelihoodProfile.fromJson(profileJson);
      await _cache.writeJson(LivelihoodCache.profileKey, profile.toJson());
      await _refreshPending();
      return profile;
    } on NetworkException {
      await _refreshPending();
      return _local();
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        await _cache.clearPersonal(); // nothing on the server means nothing here either
        await _refreshPending();
        return null;
      }
      rethrow;
    }
  }

  Future<LivelihoodProfile?> _local() async {
    final json = await _cache.readJson(LivelihoodCache.profileKey);
    if (json == null) return null;
    try {
      return LivelihoodProfile.fromJson(json);
    } catch (_) {
      await _cache.remove(LivelihoodCache.profileKey);
      return null;
    }
  }

  @override
  Future<void> delete() async {
    await _cache.clearPersonal(); // gone from the phone at once
    await _cache.setFlag(LivelihoodCache.deletePendingKey, true);
    try {
      await _api.delete(_path);
      await _cache.setFlag(LivelihoodCache.deletePendingKey, false);
    } on NetworkException {
      // the delete is retried on the next load
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        await _cache.setFlag(LivelihoodCache.deletePendingKey, false);
      } else {
        await _refreshPending();
        rethrow;
      }
    }
    await _refreshPending();
  }
}

/// Keeps his details in memory only (the standalone demo and tests).
class MemoryProfileRepository implements ProfileRepository {
  MemoryProfileRepository([this._profile]);

  LivelihoodProfile? _profile;

  @override
  Future<LivelihoodProfile?> load() async => _profile;

  @override
  Future<void> save(LivelihoodProfile profile) async => _profile = profile;

  @override
  Future<void> delete() async => _profile = null;

  @override
  bool get pendingSync => false;
}
