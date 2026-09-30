import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/wine_provider.dart';
import '../utils/formatters.dart';
import '../widgets/season_summary.dart';
import 'buyers_screen.dart';
import 'groups_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WineProvider>();
    final sezon = provider.sezonCurent;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.grass_outlined),
            SizedBox(width: 8),
            Text('Recolta'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Istoric',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SeasonHeroCard(
            sezon: sezon,
            provider: provider,
            onEditPrice: () => _editPrice(context, provider),
          ),
          const SizedBox(height: 16),
          SeasonTotalsGrid(sezon: sezon, provider: provider),
          const SizedBox(height: 24),
          _NavCard(
            icon: Icons.people_outline,
            title: 'Cumpărători',
            subtitle: '${sezon.cumparatori.length} înregistrați',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BuyersScreen()),
            ),
          ),
          const SizedBox(height: 8),
          _NavCard(
            icon: Icons.groups_outlined,
            title: 'Grupuri',
            subtitle: '${sezon.grupuri.length} create',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GroupsScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editPrice(BuildContext context, WineProvider provider) async {
    final controller = TextEditingController(
      text: formatNumber(provider.sezonCurent.pricePerKg),
    );
    final rozeController = TextEditingController(
      text: formatNumber(provider.sezonCurent.pricePerKgRoze),
    );
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Preț/Kg'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Fetească / Savignion (Lei/Kg)',
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: rozeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Roze (Lei/Kg)',
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Anulează'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Salvează'),
          ),
        ],
      ),
    );
    if (result == true) {
      final value = double.tryParse(controller.text.replaceAll(',', '.'));
      if (value != null && value >= 0) {
        provider.setPricePerKg(value);
      }
      final valueRoze = double.tryParse(
        rozeController.text.replaceAll(',', '.'),
      );
      if (valueRoze != null && valueRoze >= 0) {
        provider.setPricePerKgRoze(valueRoze);
      }
    }
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF6A1B58)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
