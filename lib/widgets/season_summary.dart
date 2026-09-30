import 'package:flutter/material.dart';

import '../models/sezon.dart';
import '../models/sortiment.dart';
import '../providers/wine_provider.dart';
import '../utils/card_styles.dart';
import '../utils/formatters.dart';
import 'total_chip.dart';

/// Cardul principal cu totalurile sezonului (Kg, valoare, drojdie, damigene).
class SeasonHeroCard extends StatelessWidget {
  final Sezon sezon;
  final WineProvider provider;
  final VoidCallback? onEditPrice;

  const SeasonHeroCard({
    super.key,
    required this.sezon,
    required this.provider,
    this.onEditPrice,
  });

  @override
  Widget build(BuildContext context) {
    final totalKg = provider.totalKg(sezon);
    final valoare = provider.totalValoare(sezon);

    return Container(
      decoration: heroCardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sezon ${sezon.an}',
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
              ),
              if (onEditPrice != null)
                GestureDetector(
                  onTap: onEditPrice,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${formatNumber(sezon.pricePerKg)} lei/Kg',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit, size: 14, color: Colors.white70),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            formatLei(valoare),
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            'Total ${formatNumber(totalKg)} Kg',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
          ),
        ],
      ),
    );
  }
}

/// Rubricile de total pe fiecare sortiment + drojdie + damigene.
class SeasonTotalsGrid extends StatelessWidget {
  final Sezon sezon;
  final WineProvider provider;

  const SeasonTotalsGrid({
    super.key,
    required this.sezon,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            for (final s in Sortiment.values) ...[
              Expanded(
                child: TotalChip(
                  label: s.label,
                  value:
                      '${formatNumber(provider.totalKgSortiment(sezon, s))} Kg',
                  color: sortimentColor(s),
                ),
              ),
              if (s != Sortiment.values.last) const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TotalChip(
                label: 'Drojdie necesară',
                value: '${formatNumber(provider.totalDrojdie(sezon))} g',
                color: Colors.brown,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TotalChip(
                label: 'Damigene',
                value: formatNumber(provider.totalDamigene(sezon)),
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Rubricile de total pe sortiment + valoare, doar pentru membrii unui grup.
class SeasonTotalsGridForGroup extends StatelessWidget {
  final Sezon sezon;
  final WineProvider provider;
  final String groupId;

  const SeasonTotalsGridForGroup({
    super.key,
    required this.sezon,
    required this.provider,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    final totalKg = provider.totalKgGrup(sezon, groupId);
    final valoare = provider.totalValoareGrup(sezon, groupId);

    return Column(
      children: [
        Row(
          children: [
            for (final s in Sortiment.values) ...[
              Expanded(
                child: TotalChip(
                  label: s.label,
                  value:
                      '${formatNumber(provider.totalKgGrup(sezon, groupId, sortiment: s))} Kg',
                  color: sortimentColor(s),
                ),
              ),
              if (s != Sortiment.values.last) const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TotalChip(
                label: 'Total Kg',
                value: formatNumber(totalKg),
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TotalChip(
                label: 'Valoare',
                value: formatLei(valoare),
                color: const Color(0xFF6A1B58),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
