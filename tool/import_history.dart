// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

/// Import unic al istoricului din vin.xlsx (tool/istoric_vin.json) în cutia
/// Hive reală a aplicației. Rulare: `dart run tool/import_history.dart`.
Future<void> main() async {
  final jsonFile = File('tool/istoric_vin.json');
  final data =
      jsonDecode(await jsonFile.readAsString()) as Map<String, dynamic>;

  Hive.init(r'C:\Users\kappa\Documents');
  final box = await Hive.openBox('sezoane');
  const uuid = Uuid();

  for (final entry in data.entries) {
    final an = int.parse(entry.key);
    final yearData = entry.value as Map<String, dynamic>;
    final cumparatori = (yearData['cumparatori'] as List).map((c) {
      final m = c as Map<String, dynamic>;
      return {
        'id': uuid.v4(),
        'nume': m['nume'],
        'kgFeteasca': m['kgFeteasca'],
        'kgSavignion': m['kgSavignion'],
        'kgRoze': m['kgRoze'],
        'groupIds': <String>[],
        'mustAchizitionat': false,
      };
    }).toList();

    await box.put(an, {
      'an': an,
      'pricePerKg': yearData['pricePerKg'],
      'cumparatori': cumparatori,
      'grupuri': <Map<String, dynamic>>[],
    });
    print('Importat $an: ${cumparatori.length} cumpărători');
  }

  await box.close();
  print('Gata.');
}
