import 'package:flutter/material.dart';

import '../models/grup.dart';
import '../models/sezon.dart';
import '../providers/wine_provider.dart';
import '../utils/card_styles.dart';
import '../utils/formatters.dart';
import 'amount_text.dart';

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
    final incasat = provider.totalValoareIncasataGrup(sezon, grup.id);
    final restDeIncasat = valoare - incasat;
    final culoare = groupColor(grup.colorIndex);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: cardGradientFor(culoare),
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
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.groups_outlined, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        grup.nume,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${membri.length} membri',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: AmountText(
                    formatLei(valoare),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Center(
                  child: Text(
                    'Total ${formatNumber(totalKg)} Kg',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Încasat: ${formatLei(incasat)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Center(
                  child: Text(
                    'Rest de încasat: ${formatLei(restDeIncasat)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
