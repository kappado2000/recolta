/// Datele fermentației mustului pentru un sezon.
class FermentatieSezon {
  DateTime? dataInceput;
  DateTime? dataFinalTumultos;
  DateTime? dataFinalFermentatie;
  String observatii;

  FermentatieSezon({
    this.dataInceput,
    this.dataFinalTumultos,
    this.dataFinalFermentatie,
    this.observatii = '',
  });

  /// Zile trecute de la prima zi de fermentație (până la finalizare, sau
  /// până azi dacă nu s-a încheiat încă).
  int? zileDeLaInceput(DateTime azi) {
    final inceput = dataInceput;
    if (inceput == null) return null;
    final sfarsit = dataFinalFermentatie ?? azi;
    return _zile(inceput, sfarsit);
  }

  /// Zile de fermentare tumultuoasă (de la început până la finalul ei).
  int? get zileTumultoasa {
    final inceput = dataInceput;
    final tumultos = dataFinalTumultos;
    if (inceput == null || tumultos == null) return null;
    return _zile(inceput, tumultos);
  }

  static int _zile(DateTime a, DateTime b) {
    final da = DateTime(a.year, a.month, a.day);
    final db = DateTime(b.year, b.month, b.day);
    return db.difference(da).inDays;
  }

  Map<String, dynamic> toMap() => {
    'dataInceput': dataInceput?.toIso8601String(),
    'dataFinalTumultos': dataFinalTumultos?.toIso8601String(),
    'dataFinalFermentatie': dataFinalFermentatie?.toIso8601String(),
    'observatii': observatii,
  };

  factory FermentatieSezon.fromMap(Map map) => FermentatieSezon(
    dataInceput: _parse(map['dataInceput']),
    dataFinalTumultos: _parse(map['dataFinalTumultos']),
    dataFinalFermentatie: _parse(map['dataFinalFermentatie']),
    observatii: map['observatii'] as String? ?? '',
  );

  static DateTime? _parse(Object? v) => v is String ? DateTime.parse(v) : null;
}
