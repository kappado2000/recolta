import 'cumparator.dart';
import 'fisa_sortiment.dart';
import 'grup.dart';
import 'sortiment.dart';

/// Un sezon (an) complet și independent: propriul preț/Kg, propria listă de
/// cumpărători și propriile grupuri. Fiecare an salvat rămâne în istoric.
class Sezon {
  final int an;

  /// Preț/Kg pentru Fetească și Savignion.
  double pricePerKg;

  /// Preț/Kg pentru Roze — separat, poate diferi de celelalte două sortimente.
  double pricePerKgRoze;
  List<Cumparator> cumparatori;
  List<Grup> grupuri;

  /// Fișa de producție (densitate zahăr, dozaje, observații) per sortiment.
  Map<Sortiment, FisaSortiment> fise;

  Sezon({
    required this.an,
    this.pricePerKg = 0,
    double? pricePerKgRoze,
    List<Cumparator>? cumparatori,
    List<Grup>? grupuri,
    Map<Sortiment, FisaSortiment>? fise,
  }) : pricePerKgRoze = pricePerKgRoze ?? pricePerKg,
       cumparatori = cumparatori ?? [],
       grupuri = grupuri ?? [],
       fise = fise ?? {};

  Map<String, dynamic> toMap() => {
    'an': an,
    'pricePerKg': pricePerKg,
    'pricePerKgRoze': pricePerKgRoze,
    'cumparatori': cumparatori.map((c) => c.toMap()).toList(),
    'grupuri': grupuri.map((g) => g.toMap()).toList(),
    'fise': fise.map((s, f) => MapEntry(s.name, f.toMap())),
  };

  factory Sezon.fromMap(Map map) => Sezon(
    an: map['an'] as int,
    pricePerKg: (map['pricePerKg'] as num?)?.toDouble() ?? 0,
    // Sezoanele mai vechi nu au preț separat pe Roze — moștenesc prețul
    // general, ca valorile deja calculate să nu se schimbe retroactiv.
    pricePerKgRoze: (map['pricePerKgRoze'] as num?)?.toDouble(),
    cumparatori: (map['cumparatori'] as List? ?? [])
        .map((e) => Cumparator.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList(),
    grupuri: (map['grupuri'] as List? ?? [])
        .map((e) => Grup.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList(),
    fise: (map['fise'] as Map? ?? {}).map(
      (key, value) => MapEntry(
        Sortiment.values.byName(key as String),
        FisaSortiment.fromMap(Map<String, dynamic>.from(value as Map)),
      ),
    ),
  );
}
