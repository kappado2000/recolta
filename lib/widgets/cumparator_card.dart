import 'package:flutter/material.dart';

import '../models/cumparator.dart';
import '../models/sortiment.dart';
import '../utils/formatters.dart';

class CumparatorCard extends StatelessWidget {
  final Cumparator cumparator;
  final double pricePerKg;
  final VoidCallback? onTap;
  final VoidCallback? onToggleAchizitionat;

  const CumparatorCard({
    super.key,
    required this.cumparator,
    required this.pricePerKg,
    this.onTap,
    this.onToggleAchizitionat,
  });

  @override
  Widget build(BuildContext context) {
    final sortimente = Sortiment.values
        .where((s) => cumparator.kgPentru(s) > 0)
        .map((s) => '${s.label} ${formatNumber(cumparator.kgPentru(s))} Kg')
        .join(' · ');
    final achizitionat = cumparator.mustAchizitionat;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: achizitionat ? Colors.green.withValues(alpha: 0.12) : null,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF6A1B58).withValues(alpha: 0.15),
          child: Text(
            cumparator.nume.isNotEmpty ? cumparator.nume[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Color(0xFF6A1B58),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(cumparator.nume),
        subtitle: Text(
          sortimente.isEmpty
              ? 'Nicio comandă încă'
              : '$sortimente  ·  Total ${formatNumber(cumparator.totalKg)} Kg',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatLei(cumparator.valoare(pricePerKg)),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              tooltip: achizitionat
                  ? 'Must ridicat — apasă pentru a anula'
                  : 'Marchează mustul ca ridicat',
              icon: Icon(
                achizitionat ? Icons.check_circle : Icons.check_circle_outline,
                color: achizitionat ? Colors.green.shade700 : Colors.grey,
              ),
              onPressed: onToggleAchizitionat,
            ),
          ],
        ),
      ),
    );
  }
}
