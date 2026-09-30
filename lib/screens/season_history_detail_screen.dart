import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/wine_provider.dart';
import '../widgets/cumparator_card.dart';
import '../widgets/grup_card.dart';
import '../widgets/season_summary.dart';

/// Vizualizare needitabilă a unui sezon din istoric — an închis, doar de
/// consultat, fără butoane de adăugare/ștergere/marcare.
class SeasonHistoryDetailScreen extends StatelessWidget {
  final int an;

  const SeasonHistoryDetailScreen({super.key, required this.an});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WineProvider>();
    final sezon = provider.sezonPentruAn(an);

    if (sezon == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Sezon $an')),
        body: const Center(child: Text('Sezonul nu a fost găsit.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Sezon $an')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SeasonHeroCard(sezon: sezon, provider: provider),
          const SizedBox(height: 16),
          SeasonTotalsGrid(sezon: sezon, provider: provider),
          if (sezon.grupuri.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Grupuri', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...sezon.grupuri.map(
              (g) => GrupCard(grup: g, sezon: sezon, provider: provider),
            ),
          ],
          const SizedBox(height: 24),
          Text('Cumpărători', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (sezon.cumparatori.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Niciun cumpărător'),
            )
          else
            ...sezon.cumparatori.indexed.map(
              (entry) => CumparatorCard(
                cumparator: entry.$2,
                pricePerKg: sezon.pricePerKg,
                index: entry.$1 + 1,
              ),
            ),
        ],
      ),
    );
  }
}
