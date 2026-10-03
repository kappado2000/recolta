import 'package:flutter/material.dart';

import '../models/fermentatie_sezon.dart';
import '../models/sezon.dart';
import '../providers/wine_provider.dart';
import 'formatters.dart';

/// Fișa cu procedura de preparare a drojdiei (maia).
Future<void> showDrojdieInfo(BuildContext context) => showDialog<void>(
  context: context,
  builder: (ctx) => AlertDialog(
    title: const Text('Drojdie necesară'),
    content: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '20 g drojdie / 100 litri must.',
            style: Theme.of(ctx).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Se pun 200 ml de must și 25 g zahăr la încălzit (36–38 °C), după '
            'care se introduce drojdia în masa mustului pentru hidratare, '
            '30–40 de minute.',
          ),
          const SizedBox(height: 8),
          const Text(
            'După hidratare, treptat, se introduce în maia câte 100 ml de must, '
            'până la 1000 ml, pentru acomodare cu temperatura mustului.',
          ),
          const SizedBox(height: 8),
          const Text(
            'După perioada de acomodare, maiaua se împarte la numărul de '
            'damigene, corespunzător cantității de must ce le conțin.',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade700),
            ),
            child: const Text(
              'Atenție! Nu trebuie să fie o diferență de temperatură mai mare '
              'de 10 °C între maia și mustul din damigene.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ),
    actions: [
      FilledButton(
        onPressed: () => Navigator.pop(ctx),
        child: const Text('Închide'),
      ),
    ],
  ),
);

/// Calculator pentru damigene: bifezi membrii, iar fișa calculează cantitatea
/// de must, numărul de damigene, drojdia și volumele pentru maia.
Future<void> showDamigeneCalculator(
  BuildContext context,
  WineProvider provider,
  Sezon sezon,
) async {
  final selectati = <String>{};

  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        final must = sezon.cumparatori
            .where((c) => selectati.contains(c.id))
            .fold<double>(0, (s, c) => s + c.totalKg);
        final damigene = (must / 50).floor();
        final restDamigeana = must - damigene * 50;
        final drojdie = must * 0.2;
        final mustInitial = must * 2;
        final mustTreptat = must * 8;

        return AlertDialog(
          title: const Text('Damigene'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _linieCalcul(ctx, 'Must total', '${formatNumber(must)} L'),
                _linieCalcul(
                  ctx,
                  'Damigene complete (50 L)',
                  '$damigene'
                      '${restDamigeana > 0 ? ' (+ ${formatNumber(restDamigeana)} L rest)' : ''}',
                ),
                _linieCalcul(
                  ctx,
                  'Drojdie necesară',
                  '${formatNumber(drojdie)} g',
                ),
                _linieCalcul(
                  ctx,
                  'Must în maia — fază inițială',
                  '${formatNumber(mustInitial)} ml',
                ),
                _linieCalcul(
                  ctx,
                  'Must adăugat treptat în maia',
                  '${formatNumber(mustTreptat)} ml',
                ),
                const Divider(height: 24),
                Text(
                  'Bifează membrii a căror must intră în calcul:',
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                if (sezon.cumparatori.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Nu există cumpărători în acest sezon.'),
                  )
                else
                  SizedBox(
                    height: 260,
                    child: ListView(
                      shrinkWrap: true,
                      children: sezon.cumparatori.map((c) {
                        final numeGrupuri = sezon.grupuri
                            .where((g) => c.groupIds.contains(g.id))
                            .map((g) => g.nume)
                            .join(', ');
                        return CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(c.nume),
                          subtitle: Text(
                            '${formatNumber(c.totalKg)} Kg'
                            '${numeGrupuri.isEmpty ? '' : ' · $numeGrupuri'}',
                          ),
                          value: selectati.contains(c.id),
                          onChanged: (v) => setState(() {
                            if (v == true) {
                              selectati.add(c.id);
                            } else {
                              selectati.remove(c.id);
                            }
                          }),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Închide'),
            ),
          ],
        );
      },
    ),
  );
}

Widget _linieCalcul(BuildContext context, String eticheta, String valoare) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(eticheta)),
          Text(valoare, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );

/// Fișa de fermentație: datele de început și de final, observații. Cardul
/// afișează automat zilele trecute de la început și zilele de fermentare
/// tumultuoasă.
Future<void> editFermentatieDialog(
  BuildContext context,
  WineProvider provider,
  Sezon sezon,
) async {
  final f = sezon.fermentatie;
  DateTime? inceput = f.dataInceput;
  DateTime? tumultos = f.dataFinalTumultos;
  DateTime? finalFerment = f.dataFinalFermentatie;
  final observatiiController = TextEditingController(text: f.observatii);

  final saved = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        Widget dataField(
          String eticheta,
          DateTime? valoare,
          ValueChanged<DateTime?> onChanged,
        ) => ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(eticheta),
          subtitle: Text(
            valoare == null ? 'Nesetată' : dateFormat.format(valoare),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (valoare != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => onChanged(null)),
                ),
              const Icon(Icons.calendar_today_outlined),
            ],
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: ctx,
              initialDate: valoare ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) setState(() => onChanged(picked));
          },
        );

        return AlertDialog(
          title: const Text('Fermentație'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                dataField('Data începerii fermentației', inceput, (d) {
                  inceput = d;
                }),
                dataField('Sfârșit fermentație tumultuoasă', tumultos, (d) {
                  tumultos = d;
                }),
                dataField('Data finalizării fermentației', finalFerment, (d) {
                  finalFerment = d;
                }),
                const SizedBox(height: 8),
                TextField(
                  controller: observatiiController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Observații',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
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
  provider.setFermentatie(
    sezon,
    FermentatieSezon(
      dataInceput: inceput,
      dataFinalTumultos: tumultos,
      dataFinalFermentatie: finalFerment,
      observatii: observatiiController.text.trim(),
    ),
  );
}
