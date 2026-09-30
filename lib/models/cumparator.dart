import 'sortiment.dart';

/// Un cumpărător cu comanda lui pentru sezonul curent (Kg pe fiecare
/// sortiment) și grupurile din care face parte (poate fi în mai multe).
class Cumparator {
  final String id;
  String nume;
  double kgFeteasca;
  double kgSavignion;
  double kgRoze;
  List<String> groupIds;

  /// Marchează faptul că acest cumpărător și-a ridicat/achiziționat mustul
  /// comandat — mută vizual rândul la finalul listei (grup sau general).
  bool mustAchizitionat;

  Cumparator({
    required this.id,
    required this.nume,
    this.kgFeteasca = 0,
    this.kgSavignion = 0,
    this.kgRoze = 0,
    List<String>? groupIds,
    this.mustAchizitionat = false,
  }) : groupIds = groupIds ?? [];

  double kgPentru(Sortiment s) {
    switch (s) {
      case Sortiment.feteasca:
        return kgFeteasca;
      case Sortiment.savignion:
        return kgSavignion;
      case Sortiment.roze:
        return kgRoze;
    }
  }

  double get totalKg => kgFeteasca + kgSavignion + kgRoze;

  double valoare(double pricePerKg) => totalKg * pricePerKg;

  /// Drojdie necesară (grame), pe baza rețetei: 40g drojdie la fiecare 200 Kg
  /// de must (echivalentul a 0,2 g/Kg), fără pasul de conversie în litri.
  double get drojdieGrame => totalKg * 0.2;

  /// Nr. de damigene (containere standard de 50 Kg).
  double get damigene => totalKg / 50;

  Map<String, dynamic> toMap() => {
    'id': id,
    'nume': nume,
    'kgFeteasca': kgFeteasca,
    'kgSavignion': kgSavignion,
    'kgRoze': kgRoze,
    'groupIds': groupIds,
    'mustAchizitionat': mustAchizitionat,
  };

  factory Cumparator.fromMap(Map map) => Cumparator(
    id: map['id'] as String,
    nume: map['nume'] as String,
    kgFeteasca: (map['kgFeteasca'] as num?)?.toDouble() ?? 0,
    kgSavignion: (map['kgSavignion'] as num?)?.toDouble() ?? 0,
    kgRoze: (map['kgRoze'] as num?)?.toDouble() ?? 0,
    groupIds:
        (map['groupIds'] as List?)?.map((e) => e as String).toList() ?? [],
    mustAchizitionat: map['mustAchizitionat'] as bool? ?? false,
  );
}
