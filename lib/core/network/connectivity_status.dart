import 'dart:async';

import 'package:flutter/foundation.dart';

/// App-wide online/offline signal driven by API responses.
///
/// A single network failure never flips the app to offline. Instead failures
/// are collected in a short window and the status only becomes offline when
/// the outage is sustained:
///
///  * [failureThreshold] failures within [failureWindow], or
///  * [offlineAfter] elapses after the first failure with no success.
///
/// Any successful response clears the pending failures and restores online.
class ConnectivityStatus {
  ConnectivityStatus._({
    this.failureThreshold = 3,
    this.failureWindow = const Duration(seconds: 8),
    this.offlineAfter = const Duration(milliseconds: 2500),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// Creates an isolated instance with tunable timings for tests.
  @visibleForTesting
  factory ConnectivityStatus.forTest({
    int failureThreshold = 3,
    Duration failureWindow = const Duration(seconds: 8),
    Duration offlineAfter = const Duration(milliseconds: 2500),
    DateTime Function()? clock,
  }) {
    return ConnectivityStatus._(
      failureThreshold: failureThreshold,
      failureWindow: failureWindow,
      offlineAfter: offlineAfter,
      clock: clock,
    );
  }

  static final ConnectivityStatus instance = ConnectivityStatus._();

  /// `true` while the app should be considered online.
  final ValueNotifier<bool> online = ValueNotifier<bool>(true);

  final int failureThreshold;
  final Duration failureWindow;
  final Duration offlineAfter;
  final DateTime Function() _clock;

  final List<DateTime> _failures = <DateTime>[];
  Timer? _offlineTimer;

  void markOnline() {
    _failures.clear();
    _offlineTimer?.cancel();
    _offlineTimer = null;
    if (!online.value) online.value = true;
  }

  void markOffline() {
    final now = _clock();
    _failures.removeWhere(
      (timestamp) => now.difference(timestamp) > failureWindow,
    );
    _failures.add(now);

    if (!online.value) return;

    if (_failures.length >= failureThreshold) {
      _goOffline();
      return;
    }

    // Start the grace period from the first failure; it is not reset by
    // subsequent failures so a slow outage still surfaces.
    _offlineTimer ??= Timer(offlineAfter, _goOffline);
  }

  void _goOffline() {
    _offlineTimer?.cancel();
    _offlineTimer = null;
    _failures.clear();
    if (online.value) online.value = false;
  }

  /// Restores the initial online state and cancels any pending timer.
  @visibleForTesting
  void reset() {
    _failures.clear();
    _offlineTimer?.cancel();
    _offlineTimer = null;
    online.value = true;
  }

  @visibleForTesting
  int get pendingFailureCount => _failures.length;

  @visibleForTesting
  bool get hasPendingTimer => _offlineTimer != null;
}
