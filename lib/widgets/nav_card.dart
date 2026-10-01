import 'package:flutter/material.dart';

import '../utils/card_styles.dart';

/// Card de navigare cu fundal degrade — folosit pe Home și în detaliul
/// fiecărui sezon din istoric pentru a deschide Cumpărători/Grupuri.
class NavCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const NavCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: cardGradientFor(color),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: ListTile(
            leading: Icon(icon, color: Colors.white),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
