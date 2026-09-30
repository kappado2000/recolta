import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/wine_provider.dart';
import '../utils/card_styles.dart';
import '../utils/cumparator_actions.dart';
import '../widgets/cumparator_card.dart';

class BuyersScreen extends StatelessWidget {
  const BuyersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WineProvider>();
    final sezon = provider.sezonCurent;
    final cumparatori = provider.ordonatiDupaAchizitie(sezon.cumparatori);

    return Scaffold(
      appBar: AppBar(title: const Text('Cumpărători')),
      body: cumparatori.isEmpty
          ? const Center(child: Text('Niciun cumpărător încă'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cumparatori.length,
              itemBuilder: (context, index) {
                final c = cumparatori[index];
                return Dismissible(
                  key: ValueKey(c.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) => _confirmDelete(context, c.nume),
                  onDismissed: (_) => provider.deleteCumparator(c.id),
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: CumparatorCard(
                    cumparator: c,
                    pricePerKg: sezon.pricePerKg,
                    index: index + 1,
                    accentColor: memberAccentColor,
                    onTap: () =>
                        editCumparatorDialog(context, provider, existing: c),
                    onToggleAchizitionat: () =>
                        provider.toggleMustAchizitionat(c.id),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => editCumparatorDialog(context, provider),
        child: const Icon(Icons.person_add_alt),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String nume) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Șterge cumpărătorul?'),
        content: Text('Vrei să ștergi comanda lui "$nume"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Anulează'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Șterge'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}
