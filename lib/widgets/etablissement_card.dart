import 'package:flutter/material.dart';
import '../models/etablissement.dart';
import '../theme/app_colors.dart';
import 'badge_disponibilite.dart';
import 'favori_button.dart';

class EtablissementCard extends StatelessWidget {
  final Etablissement etablissement;
  final double distanceKm;
  final bool estFavori;
  final VoidCallback onToggleFavori;
  final VoidCallback onTap;

  const EtablissementCard({
    super.key,
    required this.etablissement,
    required this.distanceKm,
    required this.estFavori,
    required this.onToggleFavori,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final estCentreHospitalier = etablissement.type == TypeEtablissement.centreHospitalier;

    return Card(
      color: context.fondCarte,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      etablissement.nom,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  FavoriButton(estFavori: estFavori, onToggle: onToggleFavori),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${etablissement.quartier} · ${distanceKm.toStringAsFixed(1)} km',
                style: TextStyle(fontSize: 13, color: context.texteSecondaire),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (estCentreHospitalier) ...[
                    BadgeDisponibilite(niveau: etablissement.niveauDisponibilite),
                    if (etablissement.aBanqueDeSang) const BadgeBanqueDeSang(),
                  ] else
                    BadgeStatutPharmacie(statut: etablissement.statutPharmacie),
                ],
              ),
              if (estCentreHospitalier && etablissement.dateDerniereMiseAJour != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Mis à jour à ${_formatHeure(etablissement.dateDerniereMiseAJour!)}',
                  style: TextStyle(fontSize: 11, color: context.texteSecondaire),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatHeure(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}