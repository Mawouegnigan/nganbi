import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'theme/app_colors.dart';
import 'models/etablissement.dart';
import 'services/localisation_service.dart';
import 'screens/accueil_screen.dart';
import 'screens/recherche_screen.dart';
import 'screens/favoris_screen.dart';
import 'screens/profil_screen.dart';
import 'screens/fiche_detail_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const NganBiApp());
}

class NganBiApp extends StatefulWidget {
  const NganBiApp({super.key});

  @override
  State<NganBiApp> createState() => _NganBiAppState();
}

class _NganBiAppState extends State<NganBiApp> {
  bool _modeSombre = false;
  int _ongletActif = 0;
  TypeEtablissement _filtreRechercheInitial = TypeEtablissement.centreHospitalier;
  final Set<String> _idsFavoris = {};

  User? _utilisateur;
  bool _estAdmin = false;

  double _latitudeUtilisateur = LocalisationService.latitudeParDefaut;
  double _longitudeUtilisateur = LocalisationService.longitudeParDefaut;

  @override
  void initState() {
    super.initState();
    _chargerPreferences();
    _chargerPosition();
    FirebaseAuth.instance.authStateChanges().listen(_gererChangementAuth);
  }

  Future<void> _chargerPosition() async {
    final (latitude, longitude) = await LocalisationService.obtenirPosition();
    if (mounted) {
      setState(() {
        _latitudeUtilisateur = latitude;
        _longitudeUtilisateur = longitude;
      });
    }
  }

  Future<void> _gererChangementAuth(User? utilisateur) async {
    bool estAdmin = false;
    if (utilisateur != null) {
      final resultat = await utilisateur.getIdTokenResult(true);
      estAdmin = resultat.claims?['admin'] == true;
    }
    if (mounted) {
      setState(() {
        _utilisateur = utilisateur;
        _estAdmin = estAdmin;
      });
    }
  }

  Future<void> _chargerPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _modeSombre = prefs.getBool('mode_sombre') ?? false;
      _idsFavoris.addAll(prefs.getStringList('favoris') ?? []);
    });
  }

  Future<void> _changerModeSombre(bool valeur) async {
    setState(() => _modeSombre = valeur);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mode_sombre', valeur);
  }

  Future<void> _basculerFavori(String id) async {
    setState(() {
      if (_idsFavoris.contains(id)) {
        _idsFavoris.remove(id);
      } else {
        _idsFavoris.add(id);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoris', _idsFavoris.toList());
  }

  void _ouvrirFiche(BuildContext context, Etablissement etablissement) {
    final distance = etablissement.distanceDepuis(_latitudeUtilisateur, _longitudeUtilisateur);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FicheDetailScreen(
          etablissement: etablissement,
          distanceKm: distance,
          estFavori: _idsFavoris.contains(etablissement.id),
          onToggleFavori: () => _basculerFavori(etablissement.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NganBi',
      debugShowCheckedModeBanner: false,
      theme: themeClairNganBi(),
      darkTheme: themeSombreNganBi(),
      themeMode: _modeSombre ? ThemeMode.dark : ThemeMode.light,
      home: Builder(
        builder: (context) {
          final ecrans = [
            AccueilScreen(
              onVoirHopitaux: () => setState(() {
                _ongletActif = 1;
                _filtreRechercheInitial = TypeEtablissement.centreHospitalier;
              }),
              onVoirPharmaciesGarde: () => setState(() {
                _ongletActif = 1;
                _filtreRechercheInitial = TypeEtablissement.pharmacie;
              }),
            ),
            RechercheScreen(
              key: ValueKey(_filtreRechercheInitial),
              latitudeUtilisateur: _latitudeUtilisateur,
              longitudeUtilisateur: _longitudeUtilisateur,
              idsFavoris: _idsFavoris,
              onToggleFavori: _basculerFavori,
              onOuvrirFiche: (etablissement) => _ouvrirFiche(context, etablissement),
              filtreInitial: _filtreRechercheInitial,
            ),
            FavorisScreen(
              idsFavoris: _idsFavoris,
              latitudeUtilisateur: _latitudeUtilisateur,
              longitudeUtilisateur: _longitudeUtilisateur,
              onToggleFavori: _basculerFavori,
              onOuvrirFiche: (etablissement) => _ouvrirFiche(context, etablissement),
            ),
            ProfilScreen(
              modeSombre: _modeSombre,
              onChangerModeSombre: _changerModeSombre,
              estConnecte: _utilisateur != null,
              estAdmin: _estAdmin,
              emailUtilisateur: _utilisateur?.email,
              onSeDeconnecter: () => FirebaseAuth.instance.signOut(),
            ),
          ];

          return Scaffold(
            body: ecrans[_ongletActif],
            bottomNavigationBar: NavigationBar(
              selectedIndex: _ongletActif,
              onDestinationSelected: (index) => setState(() => _ongletActif = index),
              backgroundColor: context.fondCarte,
              indicatorColor: context.vertClair,
              destinations: [
                NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: context.vertPrincipal), label: 'Accueil'),
                NavigationDestination(icon: const Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search, color: context.vertPrincipal), label: 'Recherche'),
                NavigationDestination(icon: const Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite, color: context.vertPrincipal), label: 'Favoris'),
                NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: context.vertPrincipal), label: 'Profil'),
              ],
            ),
          );
        },
      ),
    );
  }
}