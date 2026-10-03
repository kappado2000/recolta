import 'package:flutter/material.dart';

import '../models/sezon.dart';
import 'fermentatie_icon.dart';

/// Cardul de fermentație: zilele trecute de la început, iconița fermentației
/// și zilele de fermentare tumultuoasă.
class FermentatieCard extends StatelessWidget {
  final Sezon sezon;

  const FermentatieCard({super.key, required this.sezon});

  @override
  Widget build(BuildContext context) {
    final f = sezon.fermentatie;
    final zile = f.zileDeLaInceput(DateTime.now());
    final tumultos = f.zileTumultoasa;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF81C784), Color(0xFF1B5E20)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Fermentație',
            style: textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          Text(
            zile == null ? 'Nesetată' : '$zile zile',
            style: textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const FermentatieIcon(color: Colors.white, size: 40),
          const SizedBox(height: 4),
          Text(
            tumultos == null ? '' : 'Tumultuoasă: $tumultos zile',
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
