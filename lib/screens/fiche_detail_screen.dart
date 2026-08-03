import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../models/etablissement.dart';
import '../theme/app_colors.dart';
import '../widgets/badge_disponibilite.dart';
import '../widgets/favori_button.dart';

class FicheDetailScreen extends StatelessWidget {
  final Etablissement etablissement;
  final double distanceKm;
  final bool estFavori;
  final VoidCallback onToggleFavori;

  const FicheDetailScreen({
    super.key,
    required this.etablissement,
    required this.distanceKm,
    required this.estFavori,
    required this.onToggleFavori,
  });

  Future<void> _ouvrirItineraire() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${etablissement.latitude},${etablissement.longitude}',
    );
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _appeler() async {
    final uri = Uri(scheme: 'tel', path: etablissement.contact.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _partager() {
    Share.share(
      '${etablissement.nom} - ${etablissement.quartier}, ${etablissement.ville}\n'
      'Retrouvez cet établissement sur NganBi.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final estCentreHospitalier = etablissement.type == TypeEtablissement.centreHospitalier;

    return Scaffold(
      backgroundColor: context.fondEcran,
      appBar: AppBar(
        backgroundColor: context.fondEcran,
        elevation: 0,
        foregroundColor: context.vertPrincipal,
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: _partager),
          FavoriButton(estFavori: estFavori, onToggle: onToggleFavori),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Text(
            etablissement.nom,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            '${etablissement.quartier}, ${etablissement.ville} · ${distanceKm.toStringAsFixed(1)} km',
            style: TextStyle(fontSize: 14, color: context.texteSecondaire),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (estCentreHospitalier) ...[
                BadgeDisponibilite(niveau: etablissement.niveauDisponibilite),
                if (etablissement.aBanqueDeSang) const BadgeBanqueDeSang(),
              ] else
                BadgeStatutPharmacie(statut: etablissement.statutPharmacie),
            ],
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _BoutonAction(
                  icone: Icons.directions_outlined,
                  libelle: 'Itinéraire',
                  onTap: _ouvrirItineraire,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BoutonAction(
                  icone: Icons.call_outlined,
                  libelle: 'Appeler',
                  onTap: _appeler,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          if (estCentreHospitalier) ...[
            _SectionTitre('Places disponibles'),
            const SizedBox(height: 8),
            _LigneInfo(
              libelle: 'Capacité totale aux urgences',
              valeur: '${etablissement.capaciteTotaleUrgences ?? '-'}',
            ),
            _LigneInfo(
              libelle: 'Places disponibles',
              valeur: '${etablissement.placesDisponibles ?? '-'}',
            ),
            if (etablissement.dateDerniereMiseAJour != null)
              _LigneInfo(
                libelle: 'Dernière mise à jour',
                valeur: _formatDateHeure(etablissement.dateDerniereMiseAJour!),
              ),
            if (etablissement.aBanqueDeSang) ...[
              const SizedBox(height: 24),
              _SectionTitre('Stocks de sang par groupe'),
              const SizedBox(height: 8),
              ...etablissement.stocksParGroupe!.entries.map(
                (entree) => _LigneInfo(libelle: entree.key, valeur: entree.value),
              ),
              const SizedBox(height: 4),
              Text(
                'Affichage informatif uniquement.',
                style: TextStyle(fontSize: 12, color: context.texteSecondaire, fontStyle: FontStyle.italic),
              ),
            ],
          ] else ...[
            _SectionTitre('Horaires'),
            const SizedBox(height: 8),
            _LigneInfo(
              libelle: 'Ouverture',
              valeur: '${etablissement.horaireOuverture} - ${etablissement.horaireFermeture}',
            ),
            _LigneInfo(
              libelle: 'De garde cette semaine',
              valeur: etablissement.estDeGarde == true ? 'Oui' : 'Non',
            ),
          ],

          const SizedBox(height: 28),
          _SectionTitre('Contact'),
          const SizedBox(height: 8),
          _LigneInfo(libelle: 'Téléphone', valeur: etablissement.contact),
        ],
      ),
    );
  }

  String _formatDateHeure(DateTime date) {
    final j = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$j/$m à $h:$min';
  }
}

class _SectionTitre extends StatelessWidget {
  final String texte;
  const _SectionTitre(this.texte);

  @override
  Widget build(BuildContext context) {
    return Text(
      texte,
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.vertPrincipal),
    );
  }
}

class _LigneInfo extends StatelessWidget {
  final String libelle;
  final String valeur;
  const _LigneInfo({required this.libelle, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(libelle, style: TextStyle(color: context.texteSecondaire)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              valeur,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _BoutonAction extends StatelessWidget {
  final IconData icone;
  final String libelle;
  final VoidCallback onTap;

  const _BoutonAction({required this.icone, required this.libelle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: context.vertClair,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icone, color: context.vertPrincipal),
            const SizedBox(height: 4),
            Text(libelle, style: TextStyle(color: context.vertPrincipal, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}