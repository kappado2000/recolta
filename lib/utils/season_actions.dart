import 'package:flutter/material.dart';

import '../models/sezon.dart';
import '../providers/wine_provider.dart';
import 'formatters.dart';

/// Dialogul de editare a prețului/Kg (separat pe Fetească+Savignion și pe
/// Roze) — reutilizat din Home și din detaliul oricărui sezon din istoric.
Future<void> editPriceDialog(
  BuildContext context,
  WineProvider provider,
  Sezon sezon,
) async {
  final controller = TextEditingController(
    text: formatNumber(sezon.pricePerKg),
  );
  final rozeController = TextEditingController(
    text: formatNumber(sezon.pricePerKgRoze),
  );
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Preț/Kg'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Fetească / Savignion (Lei/Kg)',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: rozeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Roze (Lei/Kg)',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
        ],
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
  if (result == true) {
    final value = double.tryParse(controller.text.replaceAll(',', '.'));
    if (value != null && value >= 0) {
      provider.setPricePerKg(sezon, value);
    }
    final valueRoze = double.tryParse(rozeController.text.replaceAll(',', '.'));
    if (valueRoze != null && valueRoze >= 0) {
      provider.setPricePerKgRoze(sezon, valueRoze);
    }
  }
}

/// Confirmă și arhivează sezonul activ, deschizând unul nou pentru anul
/// următor.
Future<void> archiveSeasonDialog(
  BuildContext context,
  WineProvider provider,
) async {
  final anCurent = provider.anCurent;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Arhivează sezonul?'),
      content: Text(
        'Sezonul $anCurent va rămâne disponibil (editabil) în istoric, iar '
        'sezonul ${anCurent + 1} va deveni activ.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Anulează'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Arhivează'),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    await provider.arhiveazaSezonCurent();
  }
}
