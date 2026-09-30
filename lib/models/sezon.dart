import 'cumparator.dart';
import 'grup.dart';

/// Un sezon (an) complet și independent: propriul preț/Kg, propria listă de
/// cumpărători și propriile grupuri. Fiecare an salvat rămâne în istoric.
class Sezon {
  final int an;
  double pricePerKg;
  List<Cumparator> cumparatori;
  List<Grup> grupuri;

  Sezon({
    required this.an,
    this.pricePerKg = 0,
    List<Cumparator>? cumparatori,
    List<Grup>? grupuri,
  }) : cumparatori = cumparatori ?? [],
       grupuri = grupuri ?? [];

  Map<String, dynamic> toMap() => {
    'an': an,
    'pricePerKg': pricePerKg,
    'cumparatori': cumparatori.map((c) => c.toMap()).toList(),
    'grupuri': grupuri.map((g) => g.toMap()).toList(),
  };

  factory Sezon.fromMap(Map map) => Sezon(
    an: map['an'] as int,
    pricePerKg: (map['pricePerKg'] as num?)?.toDouble() ?? 0,
    cumparatori: (map['cumparatori'] as List? ?? [])
        .map((e) => Cumparator.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList(),
    grupuri: (map['grupuri'] as List? ?? [])
        .map((e) => Grup.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList(),
  );
}
