import 'package:flutter/material.dart';

import '../models/sezon.dart';
import '../models/sortiment.dart';
import '../providers/wine_provider.dart';
import '../utils/card_styles.dart';
import '../utils/fisa_actions.dart';
import 'grape_bunch.dart';

/// Cei trei ciorchini (Fetească, Savignion, Roze) — la apăsare deschid fișa
/// de producție a sortimentului, pentru sezonul respectiv.
class SortimentFiseRow extends StatelessWidget {
  final Sezon sezon;
  final WineProvider provider;

  const SortimentFiseRow({
    super.key,
    required this.sezon,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final s in Sortiment.values)
          GestureDetector(
            onTap: () => editFisaDialog(context, provider, sezon, s),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: sortimentColor(s).withValues(alpha: 0.15),
                  child: GrapeBunchIcon(color: sortimentColor(s), size: 40),
                ),
                const SizedBox(height: 4),
                Text(s.label, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
      ],
    );
  }
}
