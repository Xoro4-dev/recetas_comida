import 'dart:async';

class ShoppingItem {
  const ShoppingItem({
    required this.id,
    required this.name,
    required this.checked,
  });

  final String id;
  final String name;
  final bool checked;
}

abstract class ShoppingRepository {
  Stream<List<ShoppingItem>> watchItems();
  Future<void> add(String name);
  Future<void> setChecked(String id, bool checked);
  Future<void> remove(String id);
  Future<void> clearChecked();
}

/// Implementación local, usada cuando Firebase no está configurado y en tests.
class InMemoryShoppingRepository implements ShoppingRepository {
  final List<ShoppingItem> _items = [];
  final _controller = StreamController<List<ShoppingItem>>.broadcast();
  var _nextId = 0;

  void _emit() => _controller.add(List.unmodifiable(_items));

  @override
  Stream<List<ShoppingItem>> watchItems() async* {
    yield List.unmodifiable(_items);
    yield* _controller.stream;
  }

  @override
  Future<void> add(String name) async {
    _items.add(ShoppingItem(id: '${_nextId++}', name: name, checked: false));
    _emit();
  }

  @override
  Future<void> setChecked(String id, bool checked) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) return;
    _items[i] = ShoppingItem(id: id, name: _items[i].name, checked: checked);
    _emit();
  }

  @override
  Future<void> remove(String id) async {
    _items.removeWhere((e) => e.id == id);
    _emit();
  }

  @override
  Future<void> clearChecked() async {
    _items.removeWhere((e) => e.checked);
    _emit();
  }
}
