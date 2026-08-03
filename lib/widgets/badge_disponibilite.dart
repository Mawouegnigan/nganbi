import 'package:flutter/material.dart';
import '../models/etablissement.dart';
import '../theme/app_colors.dart';

class BadgeDisponibilite extends StatelessWidget {
  final NiveauDisponibilite niveau;

  const BadgeDisponibilite({super.key, required this.niveau});

  @override
  Widget build(BuildContext context) {
    final couleur = context.couleurNiveau(niveau);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: couleur.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: couleur, width: 1),
      ),
      child: Text(
        context.libelleNiveau(niveau),
        style: TextStyle(color: couleur, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}

class BadgeStatutPharmacie extends StatelessWidget {
  final StatutPharmacie statut;

  const BadgeStatutPharmacie({super.key, required this.statut});

  @override
  Widget build(BuildContext context) {
    final couleur = context.couleurStatutPharmacie(statut);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: couleur.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: couleur, width: 1),
      ),
      child: Text(
        context.libelleStatutPharmacie(statut),
        style: TextStyle(color: couleur, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}

class BadgeBanqueDeSang extends StatelessWidget {
  const BadgeBanqueDeSang({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 140),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: context.vertClair,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.water_drop_outlined, size: 14, color: context.vertPrincipal),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                'Banque de sang',
                style: TextStyle(color: context.vertPrincipal, fontWeight: FontWeight.w600, fontSize: 11),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}