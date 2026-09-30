/// Un grup de cumpărători, format prin selecție din comanda sezonului — folosit
/// doar pentru a centraliza (totaliza) sortimentele/valoarea membrilor lui.
/// Un cumpărător poate face parte din mai multe grupuri simultan.
class Grup {
  final String id;
  String nume;

  /// Index în paleta de culori (vezi `groupColor` din utils/card_styles.dart)
  /// — fixat la creare, ca grupul să-și păstreze mereu aceeași culoare.
  final int colorIndex;

  Grup({required this.id, required this.nume, this.colorIndex = 0});

  Map<String, dynamic> toMap() => {
    'id': id,
    'nume': nume,
    'colorIndex': colorIndex,
  };

  factory Grup.fromMap(Map map) => Grup(
    id: map['id'] as String,
    nume: map['nume'] as String,
    colorIndex: (map['colorIndex'] as num?)?.toInt() ?? 0,
  );
}
