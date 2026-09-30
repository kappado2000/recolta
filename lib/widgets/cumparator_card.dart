import 'package:flutter/material.dart';

import '../models/cumparator.dart';
import '../models/sortiment.dart';
import '../utils/card_styles.dart';
import '../utils/formatters.dart';

class CumparatorCard extends StatelessWidget {
  final Cumparator cumparator;
  final double pricePerKg;

  /// Numărul curent afișat în cerc — poziția lui în lista în care apare
  /// (globală, în Cumpărători; sau locală, în lista fiecărui grup).
  final int index;

  /// Culoarea de accent a cardului — implicit cea generală, sau culoarea
  /// grupului, când cardul e afișat în lista unui grup.
  final Color accentColor;
  final VoidCallback? onTap;
  final VoidCallback? onToggleAchizitionat;

  const CumparatorCard({
    super.key,
    required this.cumparator,
    required this.pricePerKg,
    required this.index,
    this.accentColor = memberAccentColor,
    this.onTap,
    this.onToggleAchizitionat,
  });

  @override
  Widget build(BuildContext context) {
    final achizitionat = cumparator.mustAchizitionat;
    final cardColor = achizitionat
        ? Colors.green.withValues(alpha: 0.16)
        : accentColor.withValues(alpha: 0.16);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: (achizitionat ? Colors.green : accentColor).withValues(
            alpha: 0.4,
          ),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: achizitionat ? Colors.green.shade700 : accentColor,
          child: Text(
            '$index',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          cumparator.nume,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final s in Sortiment.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 72,
                        child: Text(
                          s.label,
                          style: TextStyle(
                            fontSize: 11,
                            color: sortimentColor(s),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${formatNumber(cumparator.kgPentru(s))} Kg',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 72,
                      child: Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${formatNumber(cumparator.totalKg)} Kg',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
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
