import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/wine_provider.dart';
import '../utils/card_styles.dart';
import '../utils/export_actions.dart';
import '../utils/season_actions.dart';
import '../widgets/nav_card.dart';
import '../widgets/season_summary.dart';
import '../widgets/sortiment_fise_row.dart';
import 'buyers_screen.dart';
import 'groups_screen.dart';

/// Detaliul unui sezon din istoric — la fel de editabil ca sezonul activ:
/// preț, cumpărători și grupuri pot fi modificate sau șterse oricând.
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
      appBar: AppBar(
        title: Text('Sezon $an'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'Exportă documente',
            onPressed: () => showExportMenu(context, provider, sezon),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SeasonHeroCard(
            sezon: sezon,
            provider: provider,
            onEditPrice: () => editPriceDialog(context, provider, sezon),
          ),
          const SizedBox(height: 16),
          SeasonTotalsGrid(sezon: sezon, provider: provider),
          const SizedBox(height: 24),
          SortimentFiseRow(sezon: sezon, provider: provider),
          const SizedBox(height: 36),
          NavCard(
            icon: Icons.people_outline,
            title: 'Cumpărători',
            subtitle: '${sezon.cumparatori.length} înregistrați',
            color: memberAccentColor,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BuyersScreen(an: an)),
            ),
          ),
          const SizedBox(height: 8),
          NavCard(
            icon: Icons.groups_outlined,
            title: 'Grupuri',
            subtitle: '${sezon.grupuri.length} create',
            color: const Color(0xFF00897B),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => GroupsScreen(an: an)),
            ),
          ),
        ],
      ),
    );
  }
}
