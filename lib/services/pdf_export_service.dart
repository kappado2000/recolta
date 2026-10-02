import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart' show Rect;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/sezon.dart';
import '../models/sortiment.dart';
import '../providers/wine_provider.dart';
import '../utils/formatters.dart';

class PdfExportService {
  static Future<pw.Document> _buildDocument(
    Sezon sezon,
    WineProvider provider,
  ) async {
    final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);
    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: ttf, bold: ttf),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Recolta — Sezon ${sezon.an}',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Generat la: ${dateTimeFormat.format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 12),
          ],
        ),
        build: (ctx) => [
          _summary(sezon, provider),
          pw.SizedBox(height: 16),
          pw.Text(
            'Cumpărători (${sezon.cumparatori.length})',
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          _cumparatoriTable(sezon, provider),
          if (sezon.grupuri.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text(
              'Grupuri (${sezon.grupuri.length})',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            _grupuriTable(sezon, provider),
          ],
          if (sezon.fise.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text(
              'Fișe de producție',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            _fiseTable(sezon),
          ],
        ],
      ),
    );

    return doc;
  }

  /// Deschide fluxul nativ de imprimare (alegere imprimantă / AirPrint).
  static Future<void> printSezon(Sezon sezon, WineProvider provider) async {
    final doc = await _buildDocument(sezon, provider);
    await Printing.layoutPdf(onLayout: (_) => doc.save());
  }

  /// Partajează/salvează fișierul PDF (meniul de share al sistemului).
  static Future<void> sharePdf(
    Sezon sezon,
    WineProvider provider, {
    Rect? sharePositionOrigin,
  }) async {
    final doc = await _buildDocument(sezon, provider);
    final bytes = await doc.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'recolta_sezon_${sezon.an}.pdf',
      bounds: sharePositionOrigin,
    );
  }

  static pw.Widget _summary(Sezon sezon, WineProvider provider) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      children: [
        _row(['Preț/Kg (Fetească/Savignion)', formatLei(sezon.pricePerKg)]),
        _row(['Preț/Kg (Roze)', formatLei(sezon.pricePerKgRoze)]),
        _row(['Total Kg', formatNumber(provider.totalKg(sezon))]),
        _row(['Valoare totală', formatLei(provider.totalValoare(sezon))]),
        _row([
          'Drojdie necesară',
          '${formatNumber(provider.totalDrojdie(sezon))} g',
        ]),
        _row(['Damigene', formatNumber(provider.totalDamigene(sezon))]),
      ],
    );
  }

  static pw.TableRow _row(List<String> cells) =>
      pw.TableRow(children: [_cell(cells[0], bold: true), _cell(cells[1])]);

  static pw.Widget _cumparatoriTable(Sezon sezon, WineProvider provider) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(0.6),
        1: pw.FlexColumnWidth(2.2),
        2: pw.FlexColumnWidth(1.2),
        3: pw.FlexColumnWidth(1.2),
        4: pw.FlexColumnWidth(1.2),
        5: pw.FlexColumnWidth(1.2),
        6: pw.FlexColumnWidth(1.6),
        7: pw.FlexColumnWidth(1.2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _cell('Nr', bold: true),
            _cell('Nume', bold: true),
            _cell('Fetească', bold: true),
            _cell('Savignion', bold: true),
            _cell('Roze', bold: true),
            _cell('Total Kg', bold: true),
            _cell('Valoare', bold: true),
            _cell('Ridicat', bold: true),
          ],
        ),
        ...sezon.cumparatori.indexed.map(
          (e) => pw.TableRow(
            children: [
              _cell('${e.$1 + 1}'),
              _cell(e.$2.nume),
              _cell(formatNumber(e.$2.kgFeteasca)),
              _cell(formatNumber(e.$2.kgSavignion)),
              _cell(formatNumber(e.$2.kgRoze)),
              _cell(formatNumber(e.$2.totalKg)),
              _cell(
                formatLei(e.$2.valoare(sezon.pricePerKg, sezon.pricePerKgRoze)),
              ),
              _cell(e.$2.mustAchizitionat ? 'Da' : 'Nu'),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _grupuriTable(Sezon sezon, WineProvider provider) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _cell('Grup', bold: true),
            _cell('Membri', bold: true),
            _cell('Total Kg', bold: true),
            _cell('Valoare', bold: true),
            _cell('Încasat', bold: true),
            _cell('Rest', bold: true),
          ],
        ),
        ...sezon.grupuri.map((g) {
          final membri = provider.membriiGrupului(sezon, g.id);
          final valoare = provider.totalValoareGrup(sezon, g.id);
          final incasat = provider.totalValoareIncasataGrup(sezon, g.id);
          return pw.TableRow(
            children: [
              _cell(g.nume),
              _cell('${membri.length}'),
              _cell(formatNumber(provider.totalKgGrup(sezon, g.id))),
              _cell(formatLei(valoare)),
              _cell(formatLei(incasat)),
              _cell(formatLei(valoare - incasat)),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _fiseTable(Sezon sezon) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _cell('Sortiment', bold: true),
            _cell('Zahăr must (g/L)', bold: true),
            _cell('Zahăr adăugat (g/L)', bold: true),
            _cell('Tărie est.', bold: true),
            _cell('Drojdie/50L (g)', bold: true),
            _cell('Observații', bold: true),
          ],
        ),
        ...Sortiment.values.where((s) => sezon.fise.containsKey(s)).map((s) {
          final f = sezon.fise[s]!;
          return pw.TableRow(
            children: [
              _cell(s.label),
              _cell(formatNumber(f.densitateZahar)),
              _cell(formatNumber(f.zaharLaLitru)),
              _cell('${f.tarieAlcoolica.toStringAsFixed(1)}%'),
              _cell(formatNumber(f.drojdieDamigeana50L)),
              _cell(f.observatii),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _cell(String text, {bool bold = false}) => pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 9,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    ),
  );
}
