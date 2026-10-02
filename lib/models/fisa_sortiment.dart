/// Fișa de producție a unui sortiment, pentru un sezon — densitatea de
/// zahăr a mustului, dozajele de zahăr/drojdie și observații libere.
class FisaSortiment {
  /// Cantitatea de zahăr din must, în grame/litru.
  double densitateZahar;
  double zaharLaLitru;
  double drojdieDamigeana50L;
  String observatii;

  FisaSortiment({
    this.densitateZahar = 0,
    this.zaharLaLitru = 0,
    this.drojdieDamigeana50L = 0,
    this.observatii = '',
  });

  /// Tăria alcoolică estimată (%), după regula uzuală în vinificația de
  /// casă: 17 g zahăr/litru de must produc 1 grad de alcool (ex. 170 g/L
  /// → 10% alcool).
  double get tarieAlcoolica => densitateZahar / 17;

  Map<String, dynamic> toMap() => {
    'densitateZahar': densitateZahar,
    'zaharLaLitru': zaharLaLitru,
    'drojdieDamigeana50L': drojdieDamigeana50L,
    'observatii': observatii,
  };

  factory FisaSortiment.fromMap(Map map) => FisaSortiment(
    densitateZahar: (map['densitateZahar'] as num?)?.toDouble() ?? 0,
    zaharLaLitru: (map['zaharLaLitru'] as num?)?.toDouble() ?? 0,
    drojdieDamigeana50L: (map['drojdieDamigeana50L'] as num?)?.toDouble() ?? 0,
    observatii: map['observatii'] as String? ?? '',
  );
}
