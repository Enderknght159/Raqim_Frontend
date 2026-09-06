import 'package:drift/drift.dart';

import 'app_database.dart';

/// Repository over the [ChangeQueueEntries] table — the offline write queue.
///
/// Policy (BR-713): every write is enqueued here first, then flushed to the
/// server immediately when online, otherwise kept pending.
class ChangeQueue {
  ChangeQueue(this._db);

  final AppDatabase _db;

  Stream<List<ChangeQueueEntry>> watch() =>
      (_db.select(_db.changeQueueEntries)
            ..orderBy([
              (t) => OrderingTerm.asc(t.clientTs),
            ]))
          .watch();

  Future<List<ChangeQueueEntry>> pending() => (_db.select(_db.changeQueueEntries)
        ..where((t) => t.status.equals('pending'))
        ..orderBy([
          (t) => OrderingTerm.asc(t.clientTs),
        ]))
      .get();

  Future<ChangeQueueEntry> enqueue({
    required String entity,
    required int objectId,
    required String field,
    required String value,
  }) async {
    final id = await _db.into(_db.changeQueueEntries).insert(
          ChangeQueueEntriesCompanion.insert(
            entity: entity,
            objectId: objectId,
            field: field,
            value: value,
          ),
        );
    final row = await (_db.select(_db.changeQueueEntries)
          ..where((t) => t.changeId.equals(id)))
        .getSingle();
    return row;
  }

  Future<void> markSynced(int changeId, {required bool accepted, String? message}) async {
    await _db.into(_db.syncLogEntries).insert(
          SyncLogEntriesCompanion.insert(
            changeId: Value(changeId),
            entity: '',
            objectId: 0,
            status: accepted ? 'accepted' : 'rejected',
            message: Value(message),
          ),
        );
    await (_db.delete(_db.changeQueueEntries)
          ..where((t) => t.changeId.equals(changeId)))
        .go();
  }

  Future<void> markPending(int changeId) async {
    await (_db.update(_db.changeQueueEntries)
          ..where((t) => t.changeId.equals(changeId)))
        .write(ChangeQueueEntriesCompanion(status: const Value('pending')));
  }

  Future<int> pendingCount() async => (await pending()).length;

  Future<void> clear() => _db.delete(_db.changeQueueEntries).go();
}