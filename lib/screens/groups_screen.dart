import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/wine_provider.dart';
import '../widgets/grup_card.dart';
import 'group_detail_screen.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WineProvider>();
    final sezon = provider.sezonCurent;

    return Scaffold(
      appBar: AppBar(title: const Text('Grupuri')),
      body: sezon.grupuri.isEmpty
          ? const Center(child: Text('Niciun grup creat încă'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sezon.grupuri.length,
              itemBuilder: (context, index) {
                final grup = sezon.grupuri[index];
                return GrupCard(
                  grup: grup,
                  sezon: sezon,
                  provider: provider,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupDetailScreen(groupId: grup.id),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addDialog(context, provider),
        child: const Icon(Icons.group_add_outlined),
      ),
    );
  }

  Future<void> _addDialog(BuildContext context, WineProvider provider) async {
    final controller = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Grup nou'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Nume grup'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Anulează'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Creează'),
          ),
        ],
      ),
    );
    final nume = controller.text.trim();
    if (saved == true && nume.isNotEmpty) {
      provider.addGrup(nume);
    }
  }
}
