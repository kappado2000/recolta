import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:recolta/models/cumparator.dart';
import 'package:recolta/models/sezon.dart';
import 'package:recolta/models/sortiment.dart';
import 'package:recolta/providers/wine_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late WineProvider wine;

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('recolta_test');
    Hive.init(dir.path);
    wine = WineProvider();
    await wine.init();
  });

  tearDown(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  /// Un sezon de test, separat de cele preluate din istoric.
  Sezon sezonNou() => Sezon(an: 1999, pricePerKg: 6, pricePerKgRoze: 8);

  group('prima pornire', () {
    test('preia istoricul din vin.xlsx, cu totalurile lui', () {
      expect(wine.sezonPentruAn(2017)!.cumparatori, hasLength(18));
      expect(wine.totalKg(wine.sezonPentruAn(2017)!), 3000);
      expect(wine.sezonPentruAn(2024)!.pricePerKg, 7.0);
      expect(wine.sezonPentruAn(2022)!.cumparatori, hasLength(26));
    });

    test('sezoanele din istoric au același preț și pe Roze', () {
      final s = wine.sezonPentruAn(2023)!;
      expect(s.pricePerKgRoze, s.pricePerKg);
    });

    test('sezonul activ e anul curent și nu apare în istoric', () {
      expect(wine.anCurent, DateTime.now().year);
      expect(wine.aniIstoric, isNot(contains(wine.anCurent)));
      expect(wine.aniIstoric.first, greaterThan(wine.aniIstoric.last));
    });

    test('istoricul nu se mai preia a doua oară peste modificări', () async {
      final s2017 = wine.sezonPentruAn(2017)!;
      wine.setPricePerKg(s2017, 9);
      wine.deleteCumparator(s2017, s2017.cumparatori.first.id);
      await Hive.close();

      final reluat = WineProvider();
      await reluat.init();
      expect(reluat.sezonPentruAn(2017)!.pricePerKg, 9);
      expect(reluat.sezonPentruAn(2017)!.cumparatori, hasLength(17));
    });
  });

  test('valoarea folosește prețul separat pentru Roze', () {
    final s = sezonNou();
    s.cumparatori.add(
      Cumparator(
        id: 'a',
        nume: 'Ion',
        kgFeteasca: 100,
        kgSavignion: 50,
        kgRoze: 20,
      ),
    );

    expect(wine.totalKg(s), 170);
    expect(wine.totalKgSortiment(s, Sortiment.roze), 20);
    expect(wine.totalValoare(s), 150 * 6 + 20 * 8);
    expect(wine.totalDrojdie(s), closeTo(34, 1e-9));
    expect(wine.totalDamigene(s), closeTo(3.4, 1e-9));
  });

  test('grupuri: totaluri, încasat și ștergere fără membri orfani', () {
    final s = sezonNou();
    wine.addCumparator(s, 'Ana');
    wine.addCumparator(s, 'Dan');
    final ana = s.cumparatori[0].id;
    final dan = s.cumparatori[1].id;
    wine.updateCumparator(s, ana, kgFeteasca: 100);
    wine.updateCumparator(s, dan, kgRoze: 50);

    final g = wine.addGrup(s, 'Vecini');
    wine.setMembership(s, ana, g.id, true);
    wine.setMembership(s, dan, g.id, true);
    wine.setMembership(s, dan, g.id, true); // de două ori: rămâne o dată
    wine.toggleMustAchizitionat(s, dan);

    expect(wine.membriiGrupului(s, g.id), hasLength(2));
    expect(wine.totalKgGrup(s, g.id), 150);
    expect(wine.totalKgGrup(s, g.id, sortiment: Sortiment.roze), 50);
    expect(wine.totalValoareGrup(s, g.id), 100 * 6 + 50 * 8);
    expect(wine.totalValoareIncasataGrup(s, g.id), 50 * 8);

    wine.deleteGrup(s, g.id);
    expect(s.grupuri, isEmpty);
    expect(s.cumparatori.every((c) => c.groupIds.isEmpty), isTrue);
  });

  test('cei care au ridicat mustul ajung la final, în ordinea lor', () {
    final s = sezonNou();
    for (final n in ['A', 'B', 'C', 'D']) {
      wine.addCumparator(s, n);
    }
    wine.toggleMustAchizitionat(s, s.cumparatori[0].id);
    wine.toggleMustAchizitionat(s, s.cumparatori[2].id);

    expect(wine.ordonatiDupaAchizitie(s.cumparatori).map((c) => c.nume), [
      'B',
      'D',
      'A',
      'C',
    ]);
  });

  test('arhivarea pornește un sezon gol pentru anul următor', () async {
    final an = wine.anCurent;
    wine.addCumparator(wine.sezonCurent, 'Ultimul');

    await wine.arhiveazaSezonCurent();

    expect(wine.anCurent, an + 1);
    expect(wine.sezonCurent.cumparatori, isEmpty);
    expect(wine.aniIstoric, contains(an));
    expect(wine.sezonPentruAn(an)!.cumparatori.last.nume, 'Ultimul');
  });

  test('sezonul trece prin salvare fără pierderi', () {
    final s = sezonNou();
    wine.addCumparator(s, 'Ion');
    final g = wine.addGrup(s, 'G');
    wine.setMembership(s, s.cumparatori.single.id, g.id, true);

    final copie = Sezon.fromMap(s.toMap());
    expect(copie.pricePerKgRoze, 8);
    expect(copie.cumparatori.single.groupIds, [g.id]);
    expect(copie.grupuri.single.nume, 'G');
  });
}
