import 'package:firebase_database/firebase_database.dart';

/// Typed access to one Realtime Database collection. Errors reach the caller.
class RecordService<T> {
  RecordService({
    required FirebaseDatabase database,
    required String collection,
    required this.fromMap,
    required this.toMap,
    required this.idOf,
  }) : records = database.ref(collection);
  final DatabaseReference records;
  final T Function(String, Map<String, dynamic>) fromMap;
  final Map<String, dynamic> Function(T) toMap;
  final String Function(T) idOf;
  String newId() => records.push().key!;
  T decode(DataSnapshot snapshot) =>
      fromMap(snapshot.key!, Map<String, dynamic>.from(snapshot.value as Map));
  Future<T?> read(String id) async {
    final snapshot = await records.child(id).get();
    return snapshot.exists ? decode(snapshot) : null;
  }

  Future<void> create(T record) async {
    final result = await records.child(idOf(record)).runTransaction((value) {
      return value == null
          ? Transaction.success(toMap(record))
          : Transaction.abort();
    }, applyLocally: false);
    if (!result.committed) throw StateError('Record already exists.');
  }

  Future<void> update(String id, Map<String, dynamic> fields) async {
    final result = await records.child(id).runTransaction((value) {
      // A cold local cache may be null even when the server has a record.
      // A no-op success lets the server return its current value for retry.
      if (value == null) return Transaction.success(null);
      return Transaction.success({
        ...Map<String, dynamic>.from(value as Map),
        ...fields,
      });
    }, applyLocally: false);
    if (!result.committed || !result.snapshot.exists) {
      throw StateError('Record does not exist.');
    }
  }

  Future<void> delete(String id) => records.child(id).remove();
  Stream<List<T>> watch({String? field, Object? isEqualTo}) {
    final Query query = field == null
        ? records
        : records.orderByChild(field).equalTo(isEqualTo);
    return query.onValue.map(
      (event) => event.snapshot.children.map(decode).toList(),
    );
  }
}
