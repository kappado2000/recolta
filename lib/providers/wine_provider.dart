import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/cumparator.dart';
import '../models/grup.dart';
import '../models/sezon.dart';
import '../models/sortiment.dart';

class WineProvider extends ChangeNotifier {
  static const _boxName = 'sezoane';
  final _uuid = const Uuid();

  Box? _box;
  final Map<int, Sezon> _sezoane = {};

  int get anCurent => DateTime.now().year;

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
    _sezoane.putIfAbsent(anCurent, () => Sezon(an: anCurent));
    notifyListeners();
  }

  /// Sezonul activ, mereu al anului calendaristic curent — singurul editabil.
  Sezon get sezonCurent => _sezoane[anCurent]!;

  /// Anii din istoric (alții decât cel curent), cei mai recenți primii —
  /// doar pentru vizualizare, fără editare.
  List<int> get aniIstoric =>
      _sezoane.keys.where((a) => a != anCurent).toList()
        ..sort((a, b) => b.compareTo(a));

  Sezon? sezonPentruAn(int an) => _sezoane[an];

  void _persist() {
    _box?.put(sezonCurent.an, sezonCurent.toMap());
  }

  void setPricePerKg(double value) {
    sezonCurent.pricePerKg = value;
    _persist();
    notifyListeners();
  }

  // ---- Cumpărători ----

  void addCumparator(String nume) {
    sezonCurent.cumparatori.add(Cumparator(id: _uuid.v4(), nume: nume));
    _persist();
    notifyListeners();
  }

  void updateCumparator(
    String id, {
    String? nume,
    double? kgFeteasca,
    double? kgSavignion,
    double? kgRoze,
  }) {
    final c = sezonCurent.cumparatori.firstWhere((c) => c.id == id);
    if (nume != null) c.nume = nume;
    if (kgFeteasca != null) c.kgFeteasca = kgFeteasca;
    if (kgSavignion != null) c.kgSavignion = kgSavignion;
    if (kgRoze != null) c.kgRoze = kgRoze;
    _persist();
    notifyListeners();
  }

  void deleteCumparator(String id) {
    sezonCurent.cumparatori.removeWhere((c) => c.id == id);
    _persist();
    notifyListeners();
  }

  Cumparator? cumparatorById(String id) =>
      sezonCurent.cumparatori.where((c) => c.id == id).firstOrNull;

  void toggleMustAchizitionat(String id) {
    final c = sezonCurent.cumparatori.firstWhere((c) => c.id == id);
    c.mustAchizitionat = !c.mustAchizitionat;
    _persist();
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

  Grup addGrup(String nume) {
    final grup = Grup(id: _uuid.v4(), nume: nume);
    sezonCurent.grupuri.add(grup);
    _persist();
    notifyListeners();
    return grup;
  }

  void renameGrup(String id, String nume) {
    sezonCurent.grupuri.firstWhere((g) => g.id == id).nume = nume;
    _persist();
    notifyListeners();
  }

  void deleteGrup(String id) {
    sezonCurent.grupuri.removeWhere((g) => g.id == id);
    for (final c in sezonCurent.cumparatori) {
      c.groupIds.remove(id);
    }
    _persist();
    notifyListeners();
  }

  void setMembership(String cumparatorId, String groupId, bool isMember) {
    final c = sezonCurent.cumparatori.firstWhere((c) => c.id == cumparatorId);
    if (isMember) {
      if (!c.groupIds.contains(groupId)) c.groupIds.add(groupId);
    } else {
      c.groupIds.remove(groupId);
    }
    _persist();
    notifyListeners();
  }

  List<Cumparator> membriiGrupului(Sezon sezon, String groupId) =>
      sezon.cumparatori.where((c) => c.groupIds.contains(groupId)).toList();

  // ---- Totaluri (calculabile pentru orice sezon — curent sau istoric) ----

  double totalKgSortiment(Sezon sezon, Sortiment s) =>
      sezon.cumparatori.fold(0, (sum, c) => sum + c.kgPentru(s));

  double totalKg(Sezon sezon) =>
      sezon.cumparatori.fold(0, (sum, c) => sum + c.totalKg);

  double totalValoare(Sezon sezon) => totalKg(sezon) * sezon.pricePerKg;

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
      totalKgGrup(sezon, groupId) * sezon.pricePerKg;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
