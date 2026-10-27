import 'package:cloud_firestore/cloud_firestore.dart';

import 'shopping_repository.dart';

/// Los datos de la pareja viven en `couples/{código}/shopping`.
class FirestoreShoppingRepository implements ShoppingRepository {
  FirestoreShoppingRepository(this.coupleCode)
      : _col = FirebaseFirestore.instance
            .collection('couples')
            .doc(coupleCode)
            .collection('shopping');

  final String coupleCode;
  final CollectionReference<Map<String, dynamic>> _col;

  @override
  Stream<List<ShoppingItem>> watchItems() {
    return _col.orderBy('createdAt').snapshots().map((snap) => snap.docs
        .map((d) => ShoppingItem(
              id: d.id,
              name: (d.data()['name'] as String?) ?? '',
              checked: (d.data()['checked'] as bool?) ?? false,
            ))
        .toList());
  }

  @override
  Future<void> add(String name) => _col.add({
        'name': name,
        'checked': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

  @override
  Future<void> setChecked(String id, bool checked) =>
      _col.doc(id).update({'checked': checked});

  @override
  Future<void> remove(String id) => _col.doc(id).delete();

  @override
  Future<void> clearChecked() async {
    final snap = await _col.where('checked', isEqualTo: true).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final d in snap.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }
}
