import 'package:flutter/material.dart';

import '../utils/card_styles.dart';
import 'amount_text.dart';

/// Un chip colorat cu o etichetă și o valoare — folosit pentru rubricile de
/// total (pe sortiment, drojdie, damigene etc.).
class TotalChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const TotalChip({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: cardGradientFor(color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 2),
          AmountText(
            value,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
