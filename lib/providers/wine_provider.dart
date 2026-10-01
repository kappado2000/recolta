import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/cumparator.dart';
import '../models/grup.dart';
import '../models/sezon.dart';
import '../models/sortiment.dart';

class WineProvider extends ChangeNotifier {
  static const _boxName = 'sezoane';
  static const _seedDoneKey = '_istoricPreluat';
  static const _anActivKey = '_anActiv';
  final _uuid = const Uuid();

  Box? _box;
  final Map<int, Sezon> _sezoane = {};
  late int _anActiv;

  /// Anul sezonului activ — implicit anul calendaristic curent, dar poate fi
  /// avansat manual prin [arhiveazaSezonCurent].
  int get anCurent => _anActiv;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    for (final key in _box!.keys) {
      final an = key is int ? key : int.tryParse(key.toString());
      if (an == null) continue;
      final raw = _box!.get(key);
      if (raw is Map) {
        _sezoane[an] = Sezon.fromMap(Map<String, dynamic>.from(raw));
      }
    }
    // La prima pornire pe un dispozitiv nou, preia o singură dată istoricul
    // real (2017-2024 + 2026) din vin.xlsx, salvat ca asset la construirea
    // aplicației — altfel fiecare instalare nouă ar porni complet goală.
    if (_box!.get(_seedDoneKey) != true) {
      await _preiaIstoric();
      await _box!.put(_seedDoneKey, true);
    }
    _anActiv = (_box!.get(_anActivKey) as int?) ?? DateTime.now().year;
    _sezoane.putIfAbsent(_anActiv, () => Sezon(an: _anActiv));
    notifyListeners();
  }

  Future<void> _preiaIstoric() async {
    final raw = await rootBundle.loadString('assets/istoric_vin.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    for (final entry in data.entries) {
      final an = int.parse(entry.key);
      // Nu suprascrie un an pe care userul l-a modificat deja manual.
      if (_sezoane.containsKey(an)) continue;
      final yearData = entry.value as Map<String, dynamic>;
      final cumparatori = (yearData['cumparatori'] as List)
          .map(
            (c) => Cumparator(
              id: _uuid.v4(),
              nume: c['nume'] as String,
              kgFeteasca: (c['kgFeteasca'] as num).toDouble(),
              kgSavignion: (c['kgSavignion'] as num).toDouble(),
              kgRoze: (c['kgRoze'] as num).toDouble(),
            ),
          )
          .toList();
      final sezon = Sezon(
        an: an,
        pricePerKg: (yearData['pricePerKg'] as num).toDouble(),
        cumparatori: cumparatori,
      );
      _sezoane[an] = sezon;
      await _box!.put(an, sezon.toMap());
    }
  }

  /// Sezonul activ (vezi [anCurent]) — singurul cu acțiuni rapide din Home,
  /// dar istoricul rămâne la fel de editabil prin aceleași metode.
  Sezon get sezonCurent => _sezoane[anCurent]!;

  /// Anii din istoric (alții decât cel curent), cei mai recenți primii.
  List<int> get aniIstoric =>
      _sezoane.keys.where((a) => a != anCurent).toList()
        ..sort((a, b) => b.compareTo(a));

  Sezon? sezonPentruAn(int an) => _sezoane[an];

  /// Arhivează sezonul activ (rămâne disponibil, editabil, în istoric) și
  /// activează un sezon nou, gol, pentru anul următor.
  Future<void> arhiveazaSezonCurent() async {
    final urmatorul = anCurent + 1;
    _anActiv = urmatorul;
    await _box!.put(_anActivKey, _anActiv);
    _sezoane.putIfAbsent(urmatorul, () => Sezon(an: urmatorul));
    notifyListeners();
  }

  void _persist(Sezon sezon) {
    _box?.put(sezon.an, sezon.toMap());
  }

  void setPricePerKg(Sezon sezon, double value) {
    sezon.pricePerKg = value;
    _persist(sezon);
    notifyListeners();
  }

  void setPricePerKgRoze(Sezon sezon, double value) {
    sezon.pricePerKgRoze = value;
    _persist(sezon);
    notifyListeners();
  }

  // ---- Cumpărători ----

  void addCumparator(Sezon sezon, String nume) {
    sezon.cumparatori.add(Cumparator(id: _uuid.v4(), nume: nume));
    _persist(sezon);
    notifyListeners();
  }

  void updateCumparator(
    Sezon sezon,
    String id, {
    String? nume,
    double? kgFeteasca,
    double? kgSavignion,
    double? kgRoze,
  }) {
    final c = sezon.cumparatori.firstWhere((c) => c.id == id);
    if (nume != null) c.nume = nume;
    if (kgFeteasca != null) c.kgFeteasca = kgFeteasca;
    if (kgSavignion != null) c.kgSavignion = kgSavignion;
    if (kgRoze != null) c.kgRoze = kgRoze;
    _persist(sezon);
    notifyListeners();
  }

  void deleteCumparator(Sezon sezon, String id) {
    sezon.cumparatori.removeWhere((c) => c.id == id);
    _persist(sezon);
    notifyListeners();
  }

  void toggleMustAchizitionat(Sezon sezon, String id) {
    final c = sezon.cumparatori.firstWhere((c) => c.id == id);
    c.mustAchizitionat = !c.mustAchizitionat;
    _persist(sezon);
    notifyListeners();
  }

  /// O listă de cumpărători, cu cei care și-au ridicat mustul mutați la
  /// final — folosită atât pentru lista generală, cât și pentru listele de
  /// membri ai unui grup.
  List<Cumparator> ordonatiDupaAchizitie(List<Cumparator> cumparatori) {
    final neridicati = cumparatori.where((c) => !c.mustAchizitionat);
    final ridicati = cumparatori.where((c) => c.mustAchizitionat);
    return [...neridicati, ...ridicati];
  }

  // ---- Grupuri ----

  Grup addGrup(Sezon sezon, String nume) {
    final grup = Grup(
      id: _uuid.v4(),
      nume: nume,
      colorIndex: sezon.grupuri.length,
    );
    sezon.grupuri.add(grup);
    _persist(sezon);
    notifyListeners();
    return grup;
  }

  void renameGrup(Sezon sezon, String id, String nume) {
    sezon.grupuri.firstWhere((g) => g.id == id).nume = nume;
    _persist(sezon);
    notifyListeners();
  }

  void deleteGrup(Sezon sezon, String id) {
    sezon.grupuri.removeWhere((g) => g.id == id);
    for (final c in sezon.cumparatori) {
      c.groupIds.remove(id);
    }
    _persist(sezon);
    notifyListeners();
  }

  void setMembership(
    Sezon sezon,
    String cumparatorId,
    String groupId,
    bool isMember,
  ) {
    final c = sezon.cumparatori.firstWhere((c) => c.id == cumparatorId);
    if (isMember) {
      if (!c.groupIds.contains(groupId)) c.groupIds.add(groupId);
    } else {
      c.groupIds.remove(groupId);
    }
    _persist(sezon);
    notifyListeners();
  }

  List<Cumparator> membriiGrupului(Sezon sezon, String groupId) =>
      sezon.cumparatori.where((c) => c.groupIds.contains(groupId)).toList();

  // ---- Totaluri (calculabile pentru orice sezon — curent sau istoric) ----

  double totalKgSortiment(Sezon sezon, Sortiment s) =>
      sezon.cumparatori.fold(0, (sum, c) => sum + c.kgPentru(s));

  double totalKg(Sezon sezon) =>
      sezon.cumparatori.fold(0, (sum, c) => sum + c.totalKg);

  double totalValoare(Sezon sezon) => sezon.cumparatori.fold(
    0,
    (sum, c) => sum + c.valoare(sezon.pricePerKg, sezon.pricePerKgRoze),
  );

  double totalDrojdie(Sezon sezon) => totalKg(sezon) * 0.2;

  double totalDamigene(Sezon sezon) => totalKg(sezon) / 50;

  double totalKgGrup(Sezon sezon, String groupId, {Sortiment? sortiment}) {
    final membri = membriiGrupului(sezon, groupId);
    if (sortiment != null) {
      return membri.fold(0, (sum, c) => sum + c.kgPentru(sortiment));
    }
    return membri.fold(0, (sum, c) => sum + c.totalKg);
  }

  double totalValoareGrup(Sezon sezon, String groupId) =>
      membriiGrupului(sezon, groupId).fold(
        0,
        (sum, c) => sum + c.valoare(sezon.pricePerKg, sezon.pricePerKgRoze),
      );

  /// Valoarea deja încasată — suma comenzilor membrilor care au ridicat
  /// mustul (cei cu cardul închis la culoare, mutați la finalul listei).
  double totalValoareIncasataGrup(Sezon sezon, String groupId) =>
      membriiGrupului(sezon, groupId)
          .where((c) => c.mustAchizitionat)
          .fold(
            0,
            (sum, c) => sum + c.valoare(sezon.pricePerKg, sezon.pricePerKgRoze),
          );
}
