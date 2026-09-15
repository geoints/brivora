import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';

class SubscriptionService {
  SubscriptionService._internal();

  static final SubscriptionService instance = SubscriptionService._internal();

  final HttpsCallable _getStatusCallable =
      FirebaseFunctions.instanceFor(region: 'europe-west1')
          .httpsCallable('getSubscriptionStatus');

  static const int freeProjectLimit = 2;
  static const int freePhotoLimit = 5;

  bool? _cachedIsPro;
  DateTime? _cachedAt;
  final Duration _cacheTtl = const Duration(minutes: 5);

  bool _isFetching = false;
  Completer<void>? _fetchCompleter;

  Future<void> _fetchStatus({bool force = false}) async {
    if (!force && _cachedIsPro != null && _cachedAt != null) {
      if (DateTime.now().difference(_cachedAt!) < _cacheTtl) {
        return;
      }
    }

    if (_isFetching) {
      await _fetchCompleter?.future;
      return;
    }

    _isFetching = true;
    final completer = Completer<void>();
    _fetchCompleter = completer;

    try {
      final result = await _getStatusCallable.call();
      final data = result.data;

      _cachedIsPro = data is Map && data['isPro'] == true;
      _cachedAt = DateTime.now();
    } catch (_) {
      // A failed status request must never grant Pro access.
      _cachedIsPro = false;
      _cachedAt = DateTime.now();
    } finally {
      _isFetching = false;
      if (!completer.isCompleted) {
        completer.complete();
      }
      _fetchCompleter = null;
    }
  }

  Future<bool> isPro({bool forceRefresh = false}) async {
    await _fetchStatus(force: forceRefresh);
    return _cachedIsPro == true;
  }

  Future<void> refreshStatus() => _fetchStatus(force: true);

  int get projectLimit => freeProjectLimit;

  int get photoLimit => freePhotoLimit;

  Future<bool> canCreateProject(int currentActiveProjects) async {
    if (await isPro()) return true;
    return currentActiveProjects < projectLimit;
  }

  Future<bool> canAddPhotos(int currentPhotos, int photosToAdd) async {
    if (await isPro()) return true;
    return currentPhotos + photosToAdd <= photoLimit;
  }

  Future<int> remainingPhotos(int currentPhotos) async {
    if (await isPro()) return 999999;

    final remaining = photoLimit - currentPhotos;
    return remaining < 0 ? 0 : remaining;
  }
}
