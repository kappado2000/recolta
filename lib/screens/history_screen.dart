import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/wine_provider.dart';
import '../utils/formatters.dart';
import 'season_history_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WineProvider>();
    final ani = provider.aniIstoric;

    return Scaffold(
      appBar: AppBar(title: const Text('Istoric sezoane')),
      body: ani.isEmpty
          ? const Center(child: Text('Niciun sezon anterior salvat'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ani.length,
              itemBuilder: (context, index) {
                final an = ani[index];
                final sezon = provider.sezonPentruAn(an)!;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: Text('Sezon $an'),
                    subtitle: Text(
                      '${sezon.cumparatori.length} cumpărători · '
                      '${formatNumber(provider.totalKg(sezon))} Kg',
                    ),
                    trailing: Text(
                      formatLei(provider.totalValoare(sezon)),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SeasonHistoryDetailScreen(an: an),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
