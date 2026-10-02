import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sortiment.dart';
import '../providers/wine_provider.dart';
import '../utils/card_styles.dart';
import '../utils/export_actions.dart';
import '../utils/fisa_actions.dart';
import '../utils/season_actions.dart';
import '../widgets/grape_bunch.dart';
import '../widgets/nav_card.dart';
import '../widgets/season_summary.dart';
import 'buyers_screen.dart';
import 'groups_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WineProvider>();
    final sezon = provider.sezonCurent;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.grass_outlined),
            SizedBox(width: 8),
            Text('Recolta'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'Exportă documente',
            onPressed: () => showExportMenu(context, provider, sezon),
          ),
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            tooltip: 'Arhivează sezonul',
            onPressed: () => archiveSeasonDialog(context, provider),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Istoric',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final s in Sortiment.values)
                GestureDetector(
                  onTap: () => editFisaDialog(context, provider, sezon, s),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: sortimentColor(s)
                            .withValues(alpha: 0.15),
                        child: GrapeBunchIcon(
                          color: sortimentColor(s),
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.label,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          NavCard(
            icon: Icons.people_outline,
            title: 'Cumpărători',
            subtitle: '${sezon.cumparatori.length} înregistrați',
            color: memberAccentColor,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BuyersScreen(an: sezon.an)),
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
              MaterialPageRoute(builder: (_) => GroupsScreen(an: sezon.an)),
            ),
          ),
        ],
      ),
    );
  }
}
