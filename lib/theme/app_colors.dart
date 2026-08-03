import 'package:flutter/material.dart';
import '../models/etablissement.dart';

/// Palette NganBi : une extension AppColorsX sur BuildContext qui expose
/// les bonnes teintes selon le thème clair/sombre, pour ne jamais coder
/// une couleur en dur dans les écrans.
extension AppColorsX on BuildContext {
  bool get _estSombre => Theme.of(this).brightness == Brightness.dark;

  // Couleur de marque - vert NganBi, jamais utilisée pour autre chose que
  // l'identité (header, boutons d'action, wordmark).
  Color get vertPrincipal => _estSombre ? const Color(0xFF3FA873) : const Color(0xFF0F7A4C);
  Color get vertClair => _estSombre ? const Color(0xFF1B5E3F) : const Color(0xFFEAF7F0);
  Color get vertMoyen => const Color(0xFF2E9563);

  Color get fondEcran => _estSombre ? const Color(0xFF121212) : Colors.white;
  Color get fondCarte => _estSombre ? const Color(0xFF1E1E1E) : Colors.white;
  Color get texteSecondaire => _estSombre ? Colors.grey[400]! : Colors.grey[600]!;

  // Rouge d'urgence - réservé exclusivement au bouton d'appel 112.
  Color get rougeUrgence => const Color(0xFFD32F2F);

  // Couleurs sémantiques de disponibilité - réservées exclusivement aux badges.
  Color couleurNiveau(NiveauDisponibilite niveau) {
    switch (niveau) {
      case NiveauDisponibilite.eleve:
        return const Color(0xFF2E7D32);
      case NiveauDisponibilite.moyenne:
        return const Color(0xFFF9A825);
      case NiveauDisponibilite.faible:
        return const Color(0xFFEF6C00);
      case NiveauDisponibilite.sature:
        return const Color(0xFFC62828);
    }
  }

  String libelleNiveau(NiveauDisponibilite niveau) {
    switch (niveau) {
      case NiveauDisponibilite.eleve:
        return 'Élevé';
      case NiveauDisponibilite.moyenne:
        return 'Moyenne';
      case NiveauDisponibilite.faible:
        return 'Faible';
      case NiveauDisponibilite.sature:
        return 'Saturé';
    }
  }

  Color couleurStatutPharmacie(StatutPharmacie statut) {
    switch (statut) {
      case StatutPharmacie.ouvert:
        return const Color(0xFF2E7D32);
      case StatutPharmacie.deGarde:
        return vertPrincipal;
      case StatutPharmacie.ferme:
        return Colors.grey;
    }
  }

  String libelleStatutPharmacie(StatutPharmacie statut) {
    switch (statut) {
      case StatutPharmacie.ouvert:
        return 'Ouvert';
      case StatutPharmacie.deGarde:
        return 'De garde';
      case StatutPharmacie.ferme:
        return 'Fermé';
    }
  }
}

ThemeData themeClairNganBi() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF0F7A4C),
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0F7A4C),
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );
}

ThemeData themeSombreNganBi() {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF3FA873),
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0F7A4C),
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}