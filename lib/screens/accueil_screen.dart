import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../widgets/en_tete_nganbi.dart';

class AccueilScreen extends StatelessWidget {
  final VoidCallback onVoirHopitaux;
  final VoidCallback onVoirPharmaciesGarde;

  const AccueilScreen({
    super.key,
    required this.onVoirHopitaux,
    required this.onVoirPharmaciesGarde,
  });

  Future<void> _appeler(String numero) async {
    final uri = Uri(scheme: 'tel', path: numero);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dégradé de rouge du plus soutenu (priorité 1) au plus clair (priorité 3).
    final couleurBase = context.rougeUrgence;
    final couleurs = [
      couleurBase,
      Color.lerp(couleurBase, Colors.white, 0.28)!,
      Color.lerp(couleurBase, Colors.white, 0.52)!,
    ];

    return Scaffold(
      backgroundColor: context.fondEcran,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EnTeteGrande(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Numéros d\'urgence',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.texteSecondaire),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _BoutonUrgence(
                            numero: '112',
                            libelle: 'SAMU',
                            couleur: couleurs[0],
                            onTap: () => _appeler('112'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _BoutonUrgence(
                            numero: '117',
                            libelle: 'Police',
                            couleur: couleurs[1],
                            onTap: () => _appeler('117'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _BoutonUrgence(
                            numero: '118',
                            libelle: 'Pompiers',
                            couleur: couleurs[2],
                            onTap: () => _appeler('118'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Accès rapide',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.texteSecondaire),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _CarteAccesRapide(
                            icone: Icons.local_hospital_outlined,
                            libelle: 'Centres hospitaliers',
                            onTap: onVoirHopitaux,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CarteAccesRapide(
                            icone: Icons.medication_outlined,
                            libelle: 'Pharmacies de garde',
                            onTap: onVoirPharmaciesGarde,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoutonUrgence extends StatelessWidget {
  final String numero;
  final String libelle;
  final Color couleur;
  final VoidCallback onTap;

  const _BoutonUrgence({
    required this.numero,
    required this.libelle,
    required this.couleur,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          color: couleur,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.call, color: Colors.white, size: 18),
            const SizedBox(height: 4),
            Text(
              numero,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(
              libelle,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _CarteAccesRapide extends StatelessWidget {
  final IconData icone;
  final String libelle;
  final VoidCallback onTap;

  const _CarteAccesRapide({
    required this.icone,
    required this.libelle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: context.vertClair,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icone, color: context.vertPrincipal, size: 28),
            const SizedBox(height: 8),
            Text(
              libelle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.vertPrincipal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}