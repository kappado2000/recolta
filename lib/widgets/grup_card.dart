import 'package:flutter/material.dart';

import '../models/grup.dart';
import '../models/sezon.dart';
import '../providers/wine_provider.dart';
import '../utils/card_styles.dart';
import '../utils/formatters.dart';

class GrupCard extends StatelessWidget {
  final Grup grup;
  final Sezon sezon;
  final WineProvider provider;
  final VoidCallback? onTap;

  const GrupCard({
    super.key,
    required this.grup,
    required this.sezon,
    required this.provider,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final membri = provider.membriiGrupului(sezon, grup.id);
    final totalKg = provider.totalKgGrup(sezon, grup.id);
    final valoare = provider.totalValoareGrup(sezon, grup.id);
    final culoare = groupColor(grup.colorIndex);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: culoare.withValues(alpha: 0.14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: culoare.withValues(alpha: 0.4)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: culoare,
          child: const Icon(Icons.groups_outlined, color: Colors.white),
        ),
        title: Text(
          grup.nume,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${membri.length} membri  ·  Total ${formatNumber(totalKg)} Kg',
        ),
        trailing: Text(
          formatLei(valoare),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
