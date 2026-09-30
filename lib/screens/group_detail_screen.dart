import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/wine_provider.dart';
import '../utils/card_styles.dart';
import '../utils/cumparator_actions.dart';
import '../widgets/cumparator_card.dart';
import '../widgets/season_summary.dart';

class GroupDetailScreen extends StatelessWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WineProvider>();
    final sezon = provider.sezonCurent;
    final grup = sezon.grupuri.where((g) => g.id == groupId).firstOrNull;

    if (grup == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Grup')),
        body: const Center(child: Text('Acest grup a fost șters.')),
      );
    }

    final membri = provider.ordonatiDupaAchizitie(
      provider.membriiGrupului(sezon, groupId),
    );
    final culoareGrup = groupColor(grup.colorIndex);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: culoareGrup.withValues(alpha: 0.85),
        foregroundColor: Colors.white,
        title: Text(grup.nume),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Redenumește',
            onPressed: () =>
                _renameDialog(context, provider, groupId, grup.nume),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Șterge grupul',
            onPressed: () async {
              final confirmed = await _confirmDelete(context, grup.nume);
              if (confirmed && context.mounted) {
                provider.deleteGrup(groupId);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            child: SeasonTotalsGridForGroup(
              sezon: sezon,
              provider: provider,
              groupId: groupId,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Membri', style: Theme.of(context).textTheme.titleMedium),
              TextButton.icon(
                onPressed: () => _selectMembers(context, provider, groupId),
                icon: const Icon(Icons.person_add_alt),
                label: const Text('Adaugă membri'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (membri.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Niciun membru în acest grup încă'),
            )
          else
            ...membri.indexed.map(
              (entry) => CumparatorCard(
                cumparator: entry.$2,
                pricePerKg: sezon.pricePerKg,
                pricePerKgRoze: sezon.pricePerKgRoze,
                index: entry.$1 + 1,
                accentColor: culoareGrup,
                onTap: () =>
                    editCumparatorDialog(context, provider, existing: entry.$2),
                onToggleAchizitionat: () =>
                    provider.toggleMustAchizitionat(entry.$2.id),
              ),
            ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String nume) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Șterge grupul?'),
        content: Text('Vrei să ștergi grupul "$nume"? Cumpărătorii rămân.'),
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

  Future<void> _renameDialog(
    BuildContext context,
    WineProvider provider,
    String groupId,
    String currentName,
  ) async {
    final controller = TextEditingController(text: currentName);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Redenumește grupul'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anulează'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Salvează'),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty) {
      provider.renameGrup(groupId, newName);
    }
  }

  Future<void> _selectMembers(
    BuildContext context,
    WineProvider provider,
    String groupId,
  ) async {
    final sezon = provider.sezonCurent;
    final selected = {
      for (final c in sezon.cumparatori) c.id: c.groupIds.contains(groupId),
    };

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Selectează membrii'),
          content: SizedBox(
            width: double.maxFinite,
            child: sezon.cumparatori.isEmpty
                ? const Text('Nu există cumpărători încă.')
                : ListView(
                    shrinkWrap: true,
                    children: sezon.cumparatori
                        .map(
                          (c) => CheckboxListTile(
                            title: Text(c.nume),
                            value: selected[c.id] ?? false,
                            onChanged: (v) {
                              setState(() => selected[c.id] = v ?? false);
                              provider.setMembership(c.id, groupId, v ?? false);
                            },
                          ),
                        )
                        .toList(),
                  ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Gata'),
            ),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
