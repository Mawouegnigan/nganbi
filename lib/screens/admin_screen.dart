import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/etablissement.dart';
import '../theme/app_colors.dart';
import '../widgets/badge_disponibilite.dart';
import 'liste_avis_recus.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: context.fondEcran,
        appBar: AppBar(
          title: const Text('Espace administrateur'),
          backgroundColor: context.fondEcran,
          elevation: 0,
          foregroundColor: context.vertPrincipal,
          bottom: TabBar(
            labelColor: context.vertPrincipal,
            indicatorColor: context.vertPrincipal,
            tabs: const [
              Tab(text: 'Centres hospitaliers'),
              Tab(text: 'Pharmacies'),
              Tab(text: 'Avis'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ListeAdminHopitaux(),
            _ListeAdminPharmacies(),
            const ListeAvisRecus(),
          ],
        ),
      ),
    );
  }
}

class _ListeAdminHopitaux extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('etablissements')
          .where('type', isEqualTo: 'centre_hospitalier')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final hopitaux = snapshot.data!.docs.map(Etablissement.fromFirestore).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: hopitaux.length,
          itemBuilder: (context, index) => _CarteAdminHopital(etablissement: hopitaux[index]),
        );
      },
    );
  }
}

class _CarteAdminHopital extends StatefulWidget {
  final Etablissement etablissement;
  const _CarteAdminHopital({required this.etablissement});

  @override
  State<_CarteAdminHopital> createState() => _CarteAdminHopitalState();
}

class _CarteAdminHopitalState extends State<_CarteAdminHopital> {
  late TextEditingController _controleur;

  @override
  void initState() {
    super.initState();
    _controleur = TextEditingController(text: '${widget.etablissement.placesDisponibles ?? 0}');
  }

  Future<void> _mettreAJour(int nouvellesPlaces) async {
    final capacite = widget.etablissement.capaciteTotaleUrgences ?? 0;
    final valeurBornee = nouvellesPlaces.clamp(0, capacite);
    await FirebaseFirestore.instance.collection('etablissements').doc(widget.etablissement.id).update({
      'placesDisponibles': valeurBornee,
      'dateDerniereMiseAJour': FieldValue.serverTimestamp(),
    });
    _controleur.text = '$valeurBornee';
  }

  @override
  Widget build(BuildContext context) {
    final places = widget.etablissement.placesDisponibles ?? 0;
    final capacite = widget.etablissement.capaciteTotaleUrgences ?? 0;

    return Card(
      color: context.fondCarte,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(widget.etablissement.nom, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                BadgeDisponibilite(niveau: widget.etablissement.niveauDisponibilite),
              ],
            ),
            const SizedBox(height: 4),
            Text('Capacité totale : $capacite', style: TextStyle(fontSize: 12, color: context.texteSecondaire)),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: context.vertPrincipal,
                  onPressed: () => _mettreAJour(places - 1),
                ),
                Expanded(
                  child: TextField(
                    controller: _controleur,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                    onSubmitted: (valeur) => _mettreAJour(int.tryParse(valeur) ?? places),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: context.vertPrincipal,
                  onPressed: () => _mettreAJour(places + 1),
                ),
              ],
            ),
            if (widget.etablissement.aBanqueDeSang) ...[
              const SizedBox(height: 8),
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    'Stocks de sang par groupe',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.vertPrincipal),
                  ),
                  children: widget.etablissement.stocksParGroupe!.entries.map((entree) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entree.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                          DropdownButton<String>(
                            value: entree.value,
                            underline: const SizedBox(),
                            items: const ['Bon', 'Faible', 'Critique']
                                .map((niveau) => DropdownMenuItem(value: niveau, child: Text(niveau)))
                                .toList(),
                            onChanged: (nouvelleValeur) {
                              if (nouvelleValeur == null) return;
                              FirebaseFirestore.instance
                                  .collection('etablissements')
                                  .doc(widget.etablissement.id)
                                  .update({'stocksParGroupe.${entree.key}': nouvelleValeur});
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ListeAdminPharmacies extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('etablissements')
          .where('type', isEqualTo: 'pharmacie')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final pharmacies = snapshot.data!.docs.map(Etablissement.fromFirestore).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pharmacies.length,
          itemBuilder: (context, index) {
            final pharmacie = pharmacies[index];
            return Card(
              color: context.fondCarte,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: SwitchListTile(
                title: Text(pharmacie.nom, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${pharmacie.quartier} · de garde cette semaine'),
                value: pharmacie.estDeGarde ?? false,
                activeColor: context.vertPrincipal,
                onChanged: (valeur) {
                  FirebaseFirestore.instance.collection('etablissements').doc(pharmacie.id).update({
                    'estDeGarde': valeur,
                  });
                },
              ),
            );
          },
        );
      },
    );
  }
}