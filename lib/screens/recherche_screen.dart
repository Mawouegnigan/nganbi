import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/etablissement.dart';
import '../theme/app_colors.dart';
import '../widgets/etablissement_card.dart';
import '../widgets/en_tete_nganbi.dart';

class RechercheScreen extends StatefulWidget {
  // Position de l'utilisateur - à alimenter depuis geolocator dans l'écran parent.
  final double latitudeUtilisateur;
  final double longitudeUtilisateur;
  final Set<String> idsFavoris;
  final void Function(String id) onToggleFavori;
  final void Function(Etablissement etablissement) onOuvrirFiche;
  final TypeEtablissement? filtreInitial;

  const RechercheScreen({
    super.key,
    required this.latitudeUtilisateur,
    required this.longitudeUtilisateur,
    required this.idsFavoris,
    required this.onToggleFavori,
    required this.onOuvrirFiche,
    this.filtreInitial,
  });

  @override
  State<RechercheScreen> createState() => _RechercheScreenState();
}

class _RechercheScreenState extends State<RechercheScreen> {
  late TypeEtablissement _typeSelectionne;
  String _texteRecherche = '';

  @override
  void initState() {
    super.initState();
    _typeSelectionne = widget.filtreInitial ?? TypeEtablissement.centreHospitalier;
  }

  // Ordre décroissant du niveau de disponibilité pour le tri (Élevé -> Saturé).
  static const _ordreNiveau = {
    NiveauDisponibilite.eleve: 0,
    NiveauDisponibilite.moyenne: 1,
    NiveauDisponibilite.faible: 2,
    NiveauDisponibilite.sature: 3,
  };

  List<Etablissement> _filtrerEtTrier(List<Etablissement> tous) {
    var resultats = tous.where((e) {
      final bonType = e.type == _typeSelectionne;
      final correspondNom =
          _texteRecherche.isEmpty || e.nom.toLowerCase().contains(_texteRecherche.toLowerCase());
      return bonType && correspondNom;
    }).toList();

    if (_typeSelectionne == TypeEtablissement.centreHospitalier) {
      // Tri à deux niveaux : disponibilité décroissante, puis distance croissante.
      resultats.sort((a, b) {
        final ordreA = _ordreNiveau[a.niveauDisponibilite]!;
        final ordreB = _ordreNiveau[b.niveauDisponibilite]!;
        if (ordreA != ordreB) return ordreA.compareTo(ordreB);
        final distA = a.distanceDepuis(widget.latitudeUtilisateur, widget.longitudeUtilisateur);
        final distB = b.distanceDepuis(widget.latitudeUtilisateur, widget.longitudeUtilisateur);
        return distA.compareTo(distB);
      });
    } else {
      // Pharmacies : tri par distance, garde mise en avant.
      resultats.sort((a, b) {
        if (a.estDeGarde == true && b.estDeGarde != true) return -1;
        if (b.estDeGarde == true && a.estDeGarde != true) return 1;
        final distA = a.distanceDepuis(widget.latitudeUtilisateur, widget.longitudeUtilisateur);
        final distB = b.distanceDepuis(widget.latitudeUtilisateur, widget.longitudeUtilisateur);
        return distA.compareTo(distB);
      });
    }

    return resultats;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.fondEcran,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EnTetePetite(titre: 'Recherche'),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (valeur) => setState(() => _texteRecherche = valeur),
                decoration: InputDecoration(
                  hintText: 'Nom de l\'établissement',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: context.vertClair,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _ChoixType(
                      libelle: 'Centre hospitalier',
                      selectionne: _typeSelectionne == TypeEtablissement.centreHospitalier,
                      onTap: () => setState(() => _typeSelectionne = TypeEtablissement.centreHospitalier),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ChoixType(
                      libelle: 'Pharmacie',
                      selectionne: _typeSelectionne == TypeEtablissement.pharmacie,
                      onTap: () => setState(() => _typeSelectionne = TypeEtablissement.pharmacie),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('etablissements').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final tous = snapshot.data!.docs.map(Etablissement.fromFirestore).toList();
                  final resultats = _filtrerEtTrier(tous);

                  if (resultats.isEmpty) {
                    return Center(
                      child: Text('Aucun établissement trouvé', style: TextStyle(color: context.texteSecondaire)),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 16),
                    itemCount: resultats.length,
                    itemBuilder: (context, index) {
                      final etablissement = resultats[index];
                      final distance = etablissement.distanceDepuis(
                        widget.latitudeUtilisateur,
                        widget.longitudeUtilisateur,
                      );
                      return EtablissementCard(
                        etablissement: etablissement,
                        distanceKm: distance,
                        estFavori: widget.idsFavoris.contains(etablissement.id),
                        onToggleFavori: () => widget.onToggleFavori(etablissement.id),
                        onTap: () => widget.onOuvrirFiche(etablissement),
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

class _ChoixType extends StatelessWidget {
  final String libelle;
  final bool selectionne;
  final VoidCallback onTap;

  const _ChoixType({required this.libelle, required this.selectionne, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selectionne ? context.vertPrincipal : context.vertClair,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          libelle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selectionne ? Colors.white : context.vertPrincipal,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}