/// Un grup de cumpărători, format prin selecție din comanda sezonului — folosit
/// doar pentru a centraliza (totaliza) sortimentele/valoarea membrilor lui.
/// Un cumpărător poate face parte din mai multe grupuri simultan.
class Grup {
  final String id;
  String nume;

  Grup({required this.id, required this.nume});

  Map<String, dynamic> toMap() => {'id': id, 'nume': nume};

  factory Grup.fromMap(Map map) =>
      Grup(id: map['id'] as String, nume: map['nume'] as String);
}
