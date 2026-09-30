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
      return const Color(0xFFD4A017); // auriu, ca strugurii albi
    case Sortiment.savignion:
      return const Color(0xFF6A1B58); // violet-vin
    case Sortiment.roze:
      return const Color(0xFFE0729B); // roz
  }
}

LinearGradient cardGradientFor(Color color) => LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [color.withValues(alpha: 0.85), color],
);
