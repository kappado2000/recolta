import 'package:flutter/material.dart';

import '../models/sezon.dart';
import '../models/sortiment.dart';
import '../models/fisa_sortiment.dart';
import '../providers/wine_provider.dart';

/// Fișa de producție a unui sortiment — densitatea de zahăr a mustului,
/// zahărul adăugat la litru, drojdia pusă în damigeana de 50L și observații.
Future<void> editFisaDialog(
  BuildContext context,
  WineProvider provider,
  Sezon sezon,
  Sortiment sortiment,
) async {
  final fisa = provider.fisaPentru(sezon, sortiment);
  const labelBehavior = FloatingLabelBehavior.always;

  final densitateController = TextEditingController(
    text: fisa.densitateZahar == 0 ? '' : fisa.densitateZahar.toString(),
  );
  final zaharController = TextEditingController(
    text: fisa.zaharLaLitru == 0 ? '' : fisa.zaharLaLitru.toString(),
  );
  final drojdieController = TextEditingController(
    text: fisa.drojdieDamigeana50L == 0
        ? ''
        : fisa.drojdieDamigeana50L.toString(),
  );
  final observatiiController = TextEditingController(text: fisa.observatii);

  final saved = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Fișă ${sortiment.label}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: densitateController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Densitate zahăr must (°Oe)',
                floatingLabelBehavior: labelBehavior,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: zaharController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Zahăr adăugat (g/litru)',
                floatingLabelBehavior: labelBehavior,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: drojdieController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Drojdie / damigeană 50L (g)',
                floatingLabelBehavior: labelBehavior,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: observatiiController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observații',
                floatingLabelBehavior: labelBehavior,
                alignLabelWithHint: true,
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
  provider.setFisaSortiment(
    sezon,
    sortiment,
    FisaSortiment(
      densitateZahar:
          double.tryParse(densitateController.text.replaceAll(',', '.')) ?? 0,
      zaharLaLitru:
          double.tryParse(zaharController.text.replaceAll(',', '.')) ?? 0,
      drojdieDamigeana50L:
          double.tryParse(drojdieController.text.replaceAll(',', '.')) ?? 0,
      observatii: observatiiController.text.trim(),
    ),
  );
}
