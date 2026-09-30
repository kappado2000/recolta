import 'package:flutter/material.dart';

import '../models/cumparator.dart';
import '../providers/wine_provider.dart';

/// Dialogul de creare/editare a unui cumpărător (nume + Kg pe fiecare
/// sortiment) — reutilizat din ecranul Cumpărători și din fiecare grup.
Future<void> editCumparatorDialog(
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

  // Eticheta rămâne mereu deasupra câmpului (nu doar la focus/completare),
  // identică pentru toate cele 3 sortimente, chiar și fără valoare.
  const labelBehavior = FloatingLabelBehavior.always;

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
              decoration: const InputDecoration(
                labelText: 'Nume',
                floatingLabelBehavior: labelBehavior,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: feteascaController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Fetească (Kg)',
                floatingLabelBehavior: labelBehavior,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: savignionController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Savignion (Kg)',
                floatingLabelBehavior: labelBehavior,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: rozeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Roze (Kg)',
                floatingLabelBehavior: labelBehavior,
              ),
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
  final kgRoze = double.tryParse(rozeController.text.replaceAll(',', '.')) ?? 0;

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
