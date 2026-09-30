import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cumparator.dart';
import '../providers/wine_provider.dart';
import '../widgets/cumparator_card.dart';

class BuyersScreen extends StatelessWidget {
  const BuyersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WineProvider>();
    final sezon = provider.sezonCurent;
    final cumparatori = provider.ordonatiDupaAchizitie(sezon.cumparatori);

    return Scaffold(
      appBar: AppBar(title: const Text('Cumpărători')),
      body: cumparatori.isEmpty
          ? const Center(child: Text('Niciun cumpărător încă'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cumparatori.length,
              itemBuilder: (context, index) {
                final c = cumparatori[index];
                return Dismissible(
                  key: ValueKey(c.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) => _confirmDelete(context, c.nume),
                  onDismissed: (_) => provider.deleteCumparator(c.id),
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: CumparatorCard(
                    cumparator: c,
                    pricePerKg: sezon.pricePerKg,
                    onTap: () => _editDialog(context, provider, existing: c),
                    onToggleAchizitionat: () =>
                        provider.toggleMustAchizitionat(c.id),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editDialog(context, provider),
        child: const Icon(Icons.person_add_alt),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String nume) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Șterge cumpărătorul?'),
        content: Text('Vrei să ștergi comanda lui "$nume"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Anulează'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Șterge'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _editDialog(
    BuildContext context,
    WineProvider provider, {
    Cumparator? existing,
  }) async {
    final nameController = TextEditingController(text: existing?.nume ?? '');
    final feteascaController = TextEditingController(
      text: existing == null || existing.kgFeteasca == 0
          ? ''
          : existing.kgFeteasca.toString(),
    );
    final savignionController = TextEditingController(
      text: existing == null || existing.kgSavignion == 0
          ? ''
          : existing.kgSavignion.toString(),
    );
    final rozeController = TextEditingController(
      text: existing == null || existing.kgRoze == 0
          ? ''
          : existing.kgRoze.toString(),
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Cumpărător nou' : 'Editează comanda'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Nume'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: feteascaController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Fetească (Kg)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: savignionController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Savignion (Kg)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: rozeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Roze (Kg)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Anulează'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Salvează'),
          ),
        ],
      ),
    );

    if (saved != true) return;
    final nume = nameController.text.trim();
    if (nume.isEmpty) return;
    final kgFeteasca =
        double.tryParse(feteascaController.text.replaceAll(',', '.')) ?? 0;
    final kgSavignion =
        double.tryParse(savignionController.text.replaceAll(',', '.')) ?? 0;
    final kgRoze =
        double.tryParse(rozeController.text.replaceAll(',', '.')) ?? 0;

    if (existing == null) {
      provider.addCumparator(nume);
      final created = provider.sezonCurent.cumparatori.last;
      provider.updateCumparator(
        created.id,
        kgFeteasca: kgFeteasca,
        kgSavignion: kgSavignion,
        kgRoze: kgRoze,
      );
    } else {
      provider.updateCumparator(
        existing.id,
        nume: nume,
        kgFeteasca: kgFeteasca,
        kgSavignion: kgSavignion,
        kgRoze: kgRoze,
      );
    }
  }
}
