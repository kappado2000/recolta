import 'package:flutter/material.dart';

import '../models/cumparator.dart';
import '../models/sortiment.dart';
import '../utils/card_styles.dart';
import '../utils/formatters.dart';

class CumparatorCard extends StatelessWidget {
  final Cumparator cumparator;
  final double pricePerKg;
  final double pricePerKgRoze;

  /// Numărul curent afișat în cerc — poziția lui în lista în care apare
  /// (globală, în Cumpărători; sau locală, în lista fiecărui grup).
  final int index;

  /// Culoarea de accent pentru cercul cu numărul curent — implicit cea
  /// generală, sau culoarea grupului, când cardul e afișat în lista unui grup.
  /// Fundalul cardului însă reflectă starea comenzii (verde/gri), nu grupul.
  final Color accentColor;
  final VoidCallback? onTap;
  final VoidCallback? onToggleAchizitionat;

  const CumparatorCard({
    super.key,
    required this.cumparator,
    required this.pricePerKg,
    required this.pricePerKgRoze,
    required this.index,
    this.accentColor = memberAccentColor,
    this.onTap,
    this.onToggleAchizitionat,
  });

  @override
  Widget build(BuildContext context) {
    final achizitionat = cumparator.mustAchizitionat;
    // Verde degrade = comandă neridicată încă (atenție, de bifat); gri
    // degrade = deja ridicată (rezolvată, nu mai atrage atenția).
    final gradient = achizitionat
        ? [Colors.grey.shade400, Colors.grey.shade800]
        : [Colors.green.shade300, Colors.green.shade800];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
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
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: ListTile(
            leading: CircleAvatar(
              // Galben (mai deschis) doar cât timp mustul nu a fost ridicat —
              // odată bifat, cercul trece la gri, ca restul cardului.
              backgroundColor: achizitionat
                  ? Colors.grey.shade300
                  : const Color(0xFFF7E17F),
              child: Text(
                '$index',
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              cumparator.nume,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doar sortimentele cu cantitate apar, unul sub altul,
                  // fără rânduri goale între ele.
                  for (final s in Sortiment.values)
                    if (cumparator.kgPentru(s) > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 72,
                              child: Text(
                                s.label,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              '${formatNumber(cumparator.kgPentru(s))} Kg',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                              ),
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
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Text(
                          '${formatNumber(cumparator.totalKg)} Kg',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
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
                  formatLei(cumparator.valoare(pricePerKg, pricePerKgRoze)),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    tooltip: achizitionat
                        ? 'Must ridicat — apasă pentru a anula'
                        : 'Marchează mustul ca ridicat',
                    icon: Icon(
                      achizitionat
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      color: Colors.white,
                    ),
                    onPressed: onToggleAchizitionat,
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
