import 'package:flutter/material.dart';

import '../utils/card_styles.dart';
import 'amount_text.dart';

/// Un chip colorat cu o etichetă și o valoare — folosit pentru rubricile de
/// total (pe sortiment, drojdie, damigene etc.).
class TotalChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  /// Culoarea textului — implicit alb, dar poate fi schimbată pentru
  /// fundaluri deschise (ex. galben) unde albul nu se distinge.
  final Color textColor;

  /// Rânduri suplimentare, mai mici, afișate sub valoarea principală (ex.
  /// "Încasat: ...", "Rest de încasat: ...").
  final List<String> extraLines;

  const TotalChip({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.textColor = Colors.white,
    this.extraLines = const [],
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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: textColor.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 2),
          AmountText(
            value,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: textColor, fontWeight: FontWeight.bold),
          ),
          for (final line in extraLines) ...[
            const SizedBox(height: 2),
            Text(
              line,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: textColor.withValues(alpha: 0.85)),
            ),
          ],
        ],
      ),
    );
  }
}
