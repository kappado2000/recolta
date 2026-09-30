import 'package:flutter/material.dart';

import '../models/sortiment.dart';

/// Gradient "hero" — folosit pentru cardul de totaluri al sezonului, în
/// tonuri de vin (violet-purpuriu), la fel peste tot pentru consistență.
const heroCardGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF6A1B58), Color(0xFF9C2B7A)],
);

BoxDecoration heroCardDecoration({double radius = 20}) => BoxDecoration(
  gradient: heroCardGradient,
  borderRadius: BorderRadius.circular(radius),
  boxShadow: [
    BoxShadow(
      color: const Color(0xFF6A1B58).withValues(alpha: 0.28),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ],
);

/// Culoare distinctă per sortiment, folosită consecvent în toată aplicația
/// (chip-uri de total, iconițe, grafice).
Color sortimentColor(Sortiment s) {
  switch (s) {
    case Sortiment.feteasca:
      return const Color(0xFFF3D34A); // galben deschis
    case Sortiment.savignion:
      return const Color(0xFFB8860B); // galben închis
    case Sortiment.roze:
      return const Color(0xFFE0729B); // roz
  }
}

LinearGradient cardGradientFor(Color color) => LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [color.withValues(alpha: 0.85), color],
);

/// Culoarea implicită a cardurilor de cumpărător, în lista generală
/// (neasociată niciunui grup).
const Color memberAccentColor = Color(0xFF6A1B58);

/// Paletă de culori distincte pentru grupuri — atribuite în ordinea creării
/// (stocată pe [Grup.colorIndex]) ca fiecare grup să-și păstreze aceeași
/// culoare indiferent câte alte grupuri sunt șterse ulterior.
const List<Color> groupColorPalette = [
  Color(0xFF6A1B58), // violet-vin
  Color(0xFF00897B), // teal
  Color(0xFFEF6C00), // portocaliu
  Color(0xFF3949AB), // indigo
  Color(0xFFC2185B), // roz-închis
  Color(0xFF2E7D32), // verde
  Color(0xFF6D4C41), // maro
];

Color groupColor(int colorIndex) =>
    groupColorPalette[colorIndex % groupColorPalette.length];
