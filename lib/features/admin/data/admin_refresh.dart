import 'package:flutter/foundation.dart';

import '../../../core/storage/screen_cache.dart';

/// Broadcasts organisation changes (teams, teachers, user links) so every
/// open admin screen reloads from one source of truth instead of keeping its
/// own stale snapshot.
class AdminRefresh extends ChangeNotifier {
  AdminRefresh._();

  static final AdminRefresh instance = AdminRefresh._();

  int _revision = 0;

  /// Increases on every organisation mutation; listeners can skip rebuilds.
  int get revision => _revision;

  /// Called after assigning/removing a teacher, unlinking a team, deleting a
  /// teacher record, or changing team membership.
  void teamsChanged() {
    ScreenCache.instance
      ..remove('admin-teams')
      ..removeWhere((key) => key.startsWith('admin-teacher-'));
    _revision++;
    notifyListeners();
  }
}
