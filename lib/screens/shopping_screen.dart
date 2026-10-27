import 'package:flutter/material.dart';

import '../data/app_scope.dart';
import '../data/shopping_repository.dart';
import '../theme/pixel_theme.dart';
import '../widgets/pixel_button.dart';
import '../widgets/pixel_text_field.dart';
import 'section_screen.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final _controller = TextEditingController();
  late final ShoppingRepository _repo;
  late final Stream<List<ShoppingItem>> _stream;
  var _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _repo = AppScope.of(context).shopping;
    _stream = _repo.watchItems();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add(ShoppingRepository repo) async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    _controller.clear();
    await repo.add(name);
  }

  @override
  Widget build(BuildContext context) {
    final repo = _repo;
    return SectionScreen(
      title: 'LISTA DE LA COMPRA',
      color: PixelColors.green,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: PixelTextField(
                    controller: _controller,
                    hint: 'añadir producto',
                    onSubmitted: (_) => _add(repo),
                  ),
                ),
                const SizedBox(width: 8),
                PixelButton(
                  label: '+',
                  color: PixelColors.orange,
                  fontSize: 16,
                  onPressed: () => _add(repo),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<List<ShoppingItem>>(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error al cargar la lista',
                        style: pixelText(10, color: PixelColors.red)),
                  );
                }
                final items = snapshot.data ?? const <ShoppingItem>[];
                if (items.isEmpty) {
                  return Center(
                    child: Text('La lista está vacía',
                        style: pixelText(10, color: PixelColors.yellow)),
                  );
                }
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: items.length,
                        itemBuilder: (_, i) => _ItemRow(item: items[i]),
                      ),
                    ),
                    if (items.any((e) => e.checked))
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: PixelButton(
                          label: 'BORRAR MARCADOS',
                          color: PixelColors.red,
                          fontSize: 11,
                          onPressed: repo.clearChecked,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final ShoppingItem item;

  @override
  Widget build(BuildContext context) {
    final repo = AppScope.of(context).shopping;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        border: Border.all(color: PixelColors.outline, width: 3),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => repo.setChecked(item.id, !item.checked),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Text(item.checked ? '✅' : '⬜',
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.name,
                        style: pixelText(11, color: PixelColors.outline).copyWith(
                          shadows: [],
                          decoration: item.checked
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Eliminar',
            icon: const Text('🗑️', style: TextStyle(fontSize: 20)),
            onPressed: () => repo.remove(item.id),
          ),
        ],
      ),
    );
  }
}
