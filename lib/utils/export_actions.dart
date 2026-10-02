import 'package:flutter/material.dart';

import '../models/sezon.dart';
import '../providers/wine_provider.dart';
import '../services/excel_export_service.dart';
import '../services/pdf_export_service.dart';

/// Meniul de export al unui sezon — imprimare, PDF sau Excel.
Future<void> showExportMenu(
  BuildContext context,
  WineProvider provider,
  Sezon sezon,
) async {
  final choice = await showModalBottomSheet<String>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.print_outlined),
            title: const Text('Imprimare'),
            onTap: () => Navigator.pop(ctx, 'print'),
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: const Text('Exportă PDF'),
            onTap: () => Navigator.pop(ctx, 'pdf'),
          ),
          ListTile(
            leading: const Icon(Icons.grid_on_outlined),
            title: const Text('Exportă Excel'),
            onTap: () => Navigator.pop(ctx, 'excel'),
          ),
        ],
      ),
    ),
  );
  if (choice == null || !context.mounted) return;

  try {
    switch (choice) {
      case 'print':
        await PdfExportService.printSezon(sezon, provider);
        break;
      case 'pdf':
        await PdfExportService.sharePdf(sezon, provider);
        break;
      case 'excel':
        await ExcelExportService.exportSezon(sezon, provider);
        break;
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Export eșuat: $e')));
    }
  }
}
