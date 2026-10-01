import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/wine_provider.dart';
import '../utils/card_styles.dart';
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
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    gradient: cardGradientFor(memberAccentColor),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SeasonHistoryDetailScreen(an: an),
                        ),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.white,
                        ),
                        title: Text(
                          'Sezon $an',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${sezon.cumparatori.length} cumpărători · '
                          '${formatNumber(provider.totalKg(sezon))} Kg',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        trailing: Text(
                          formatLei(provider.totalValoare(sezon)),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
