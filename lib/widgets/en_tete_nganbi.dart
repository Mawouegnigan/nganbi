import 'package:flutter/material.dart';
import 'logo_nganbi.dart';

const Color _vertEnTete = Color(0xFF0F7A4C);

/// En-tête grand format pour l'écran Accueil : logo + wordmark + slogan.
class EnTeteGrande extends StatelessWidget {
  const EnTeteGrande({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        color: _vertEnTete,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LogoNganBi(hauteur: 30, couleurRepere: _vertEnTete),
              const SizedBox(width: 10),
              const Text(
                'NganBi',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Trouvez rapidement un établissement de santé à Cotonou',
            style: TextStyle(color: Color(0xFFEAF7F0), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// En-tête compact pour les écrans Recherche, Favoris et Profil : logo + titre.
class EnTetePetite extends StatelessWidget {
  final String titre;
  final Widget? actionDroite;

  const EnTetePetite({super.key, required this.titre, this.actionDroite});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 22),
      decoration: const BoxDecoration(
        color: _vertEnTete,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          const LogoNganBi(hauteur: 22, couleurRepere: _vertEnTete),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              titre,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actionDroite != null) actionDroite!,
        ],
      ),
    );
  }
}