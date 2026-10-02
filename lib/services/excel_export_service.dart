import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/widgets.dart' show Rect;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/sezon.dart';
import '../models/sortiment.dart';
import '../providers/wine_provider.dart';

class ExcelExportService {
  static Future<void> exportSezon(
    Sezon sezon,
    WineProvider provider, {
    Rect? sharePositionOrigin,
  }) async {
    final workbook = Excel.createExcel();
    final defaultSheetName = workbook.getDefaultSheet();

    final sezonSheet = workbook['Sezon'];
    sezonSheet.appendRow([TextCellValue('An'), IntCellValue(sezon.an)]);
    sezonSheet.appendRow([
      TextCellValue('Preț/Kg (Fetească/Savignion)'),
      DoubleCellValue(sezon.pricePerKg),
    ]);
    sezonSheet.appendRow([
      TextCellValue('Preț/Kg (Roze)'),
      DoubleCellValue(sezon.pricePerKgRoze),
    ]);
    sezonSheet.appendRow([
      TextCellValue('Total Kg'),
      DoubleCellValue(provider.totalKg(sezon)),
    ]);
    sezonSheet.appendRow([
      TextCellValue('Valoare totală'),
      DoubleCellValue(provider.totalValoare(sezon)),
    ]);
    sezonSheet.appendRow([
      TextCellValue('Drojdie necesară (g)'),
      DoubleCellValue(provider.totalDrojdie(sezon)),
    ]);
    sezonSheet.appendRow([
      TextCellValue('Damigene'),
      DoubleCellValue(provider.totalDamigene(sezon)),
    ]);

    final cumparatoriSheet = workbook['Cumpărători'];
    cumparatoriSheet.appendRow([
      TextCellValue('Nr'),
      TextCellValue('Nume'),
      TextCellValue('Fetească (Kg)'),
      TextCellValue('Savignion (Kg)'),
      TextCellValue('Roze (Kg)'),
      TextCellValue('Total Kg'),
      TextCellValue('Valoare'),
      TextCellValue('Must ridicat'),
    ]);
    for (final (i, c) in sezon.cumparatori.indexed) {
      cumparatoriSheet.appendRow([
        IntCellValue(i + 1),
        TextCellValue(c.nume),
        DoubleCellValue(c.kgFeteasca),
        DoubleCellValue(c.kgSavignion),
        DoubleCellValue(c.kgRoze),
        DoubleCellValue(c.totalKg),
        DoubleCellValue(c.valoare(sezon.pricePerKg, sezon.pricePerKgRoze)),
        TextCellValue(c.mustAchizitionat ? 'Da' : 'Nu'),
      ]);
    }

    if (sezon.grupuri.isNotEmpty) {
      final grupuriSheet = workbook['Grupuri'];
      grupuriSheet.appendRow([
        TextCellValue('Grup'),
        TextCellValue('Membri'),
        TextCellValue('Total Kg'),
        TextCellValue('Valoare'),
        TextCellValue('Încasat'),
        TextCellValue('Rest'),
      ]);
      for (final g in sezon.grupuri) {
        final membri = provider.membriiGrupului(sezon, g.id);
        final valoare = provider.totalValoareGrup(sezon, g.id);
        final incasat = provider.totalValoareIncasataGrup(sezon, g.id);
        grupuriSheet.appendRow([
          TextCellValue(g.nume),
          IntCellValue(membri.length),
          DoubleCellValue(provider.totalKgGrup(sezon, g.id)),
          DoubleCellValue(valoare),
          DoubleCellValue(incasat),
          DoubleCellValue(valoare - incasat),
        ]);
      }
    }

    if (sezon.fise.isNotEmpty) {
      final fiseSheet = workbook['Fișe sortimente'];
      fiseSheet.appendRow([
        TextCellValue('Sortiment'),
        TextCellValue('Zahăr must (g/L)'),
        TextCellValue('Zahăr adăugat (g/L)'),
        TextCellValue('Tărie estimată (%)'),
        TextCellValue('Drojdie/damigeană 50L (g)'),
        TextCellValue('Observații'),
      ]);
      for (final s in Sortiment.values) {
        final f = sezon.fise[s];
        if (f == null) continue;
        fiseSheet.appendRow([
          TextCellValue(s.label),
          DoubleCellValue(f.densitateZahar),
          DoubleCellValue(f.zaharLaLitru),
          DoubleCellValue(f.tarieAlcoolica),
          DoubleCellValue(f.drojdieDamigeana50L),
          TextCellValue(f.observatii),
        ]);
      }
    }

    if (defaultSheetName != null &&
        defaultSheetName != 'Sezon' &&
        defaultSheetName != 'Cumpărători' &&
        defaultSheetName != 'Grupuri' &&
        defaultSheetName != 'Fișe sortimente') {
      workbook.delete(defaultSheetName);
    }

    final bytes = workbook.encode();
    if (bytes == null) return;

    final dir = await getTemporaryDirectory();
    final fileName = 'recolta_sezon_${sezon.an}.xlsx';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [
        XFile(
          file.path,
          mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ),
      ],
      subject: 'Export Recolta — Sezon ${sezon.an}',
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}
