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
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        final zaharMust =
            double.tryParse(densitateController.text.replaceAll(',', '.')) ?? 0;
        final zaharAdaugat =
            double.tryParse(zaharController.text.replaceAll(',', '.')) ?? 0;
        final tarie = (zaharMust + zaharAdaugat) / 17;

        return AlertDialog(
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
                    labelText: 'Zahăr în must (g/litru)',
                    floatingLabelBehavior: labelBehavior,
                  ),
                  onChanged: (_) => setState(() {}),
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
                  onChanged: (_) => setState(() {}),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      'Tărie estimată: ${tarie.toStringAsFixed(1)}% alcool '
                      '(zahăr must + adăugat, 17 g/L ≈ 1°)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
        );
      },
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
