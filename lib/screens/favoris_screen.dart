import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/etablissement.dart';
import '../theme/app_colors.dart';
import '../widgets/etablissement_card.dart';
import '../widgets/en_tete_nganbi.dart';

class FavorisScreen extends StatelessWidget {
  final Set<String> idsFavoris;
  final double latitudeUtilisateur;
  final double longitudeUtilisateur;
  final void Function(String id) onToggleFavori;
  final void Function(Etablissement etablissement) onOuvrirFiche;

  const FavorisScreen({
    super.key,
    required this.idsFavoris,
    required this.latitudeUtilisateur,
    required this.longitudeUtilisateur,
    required this.onToggleFavori,
    required this.onOuvrirFiche,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.fondEcran,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EnTetePetite(titre: 'Favoris'),
            Expanded(
              child: idsFavoris.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Aucun favori pour le moment.\nAjoutez des établissements depuis la recherche.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.texteSecondaire),
                        ),
                      ),
                    )
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('etablissements').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final favoris = snapshot.data!.docs
                            .map(Etablissement.fromFirestore)
                            .where((e) => idsFavoris.contains(e.id))
                            .toList();

                        return ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 16),
                          itemCount: favoris.length,
                          itemBuilder: (context, index) {
                            final etablissement = favoris[index];
                            final distance =
                                etablissement.distanceDepuis(latitudeUtilisateur, longitudeUtilisateur);
                            return EtablissementCard(
                              etablissement: etablissement,
                              distanceKm: distance,
                              estFavori: true,
                              onToggleFavori: () => onToggleFavori(etablissement.id),
                              onTap: () => onOuvrirFiche(etablissement),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}