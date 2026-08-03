import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

enum TypeEtablissement { centreHospitalier, pharmacie }

enum NiveauDisponibilite { sature, faible, moyenne, eleve }

enum StatutPharmacie { ouvert, ferme, deGarde }

class Etablissement {
  final String id;
  final TypeEtablissement type;
  final String nom;
  final String ville;
  final String quartier;
  final double latitude;
  final double longitude;
  final String contact;

  // Champs centre hospitalier (null si type == pharmacie)
  final int? capaciteTotaleUrgences;
  final int? placesDisponibles;
  final DateTime? dateDerniereMiseAJour;
  final Map<String, String>? stocksParGroupe;

  // Champs pharmacie (null si type == centreHospitalier)
  final String? horaireOuverture;
  final String? horaireFermeture;
  final bool? estDeGarde;

  const Etablissement({
    required this.id,
    required this.type,
    required this.nom,
    required this.ville,
    required this.quartier,
    required this.latitude,
    required this.longitude,
    required this.contact,
    this.capaciteTotaleUrgences,
    this.placesDisponibles,
    this.dateDerniereMiseAJour,
    this.stocksParGroupe,
    this.horaireOuverture,
    this.horaireFermeture,
    this.estDeGarde,
  });

  factory Etablissement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final typeStr = data['type'] as String;

    return Etablissement(
      id: doc.id,
      type: typeStr == 'centre_hospitalier'
          ? TypeEtablissement.centreHospitalier
          : TypeEtablissement.pharmacie,
      nom: data['nom'] ?? '',
      ville: data['ville'] ?? '',
      quartier: data['quartier'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      contact: data['contact'] ?? '',
      capaciteTotaleUrgences: data['capaciteTotaleUrgences'],
      placesDisponibles: data['placesDisponibles'],
      dateDerniereMiseAJour: data['dateDerniereMiseAJour'] != null
          ? _versDateTime(data['dateDerniereMiseAJour'])
          : null,
      stocksParGroupe: data['stocksParGroupe'] != null
          ? Map<String, String>.from(data['stocksParGroupe'])
          : null,
      horaireOuverture: data['horaireOuverture'],
      horaireFermeture: data['horaireFermeture'],
      estDeGarde: data['estDeGarde'],
    );
  }
static DateTime? _versDateTime(dynamic valeur) {
    if (valeur is Timestamp) return valeur.toDate();
    if (valeur is String) return DateTime.tryParse(valeur);
    return null;
  }
  /// Niveau de disponibilité calculé - jamais stocké en base.
  /// Seuils actés au cahier des charges : Saturé (0%), Faible (1-24%),
  /// Moyenne (25-49%), Élevé (50%+).
  NiveauDisponibilite get niveauDisponibilite {
    if (capaciteTotaleUrgences == null ||
        capaciteTotaleUrgences == 0 ||
        placesDisponibles == null) {
      return NiveauDisponibilite.sature;
    }
    final pourcentage = placesDisponibles! / capaciteTotaleUrgences!;
    if (pourcentage <= 0) return NiveauDisponibilite.sature;
    if (pourcentage < 0.25) return NiveauDisponibilite.faible;
    if (pourcentage < 0.50) return NiveauDisponibilite.moyenne;
    return NiveauDisponibilite.eleve;
  }

  /// Statut calculé pour une pharmacie - estDeGarde est prioritaire
  /// sur le statut ouvert/fermé déduit des horaires.
  StatutPharmacie get statutPharmacie {
    if (estDeGarde == true) return StatutPharmacie.deGarde;
    if (horaireOuverture == null || horaireFermeture == null) {
      return StatutPharmacie.ferme;
    }
    final maintenant = TimeOfDayMinutes.now();
    final ouverture = TimeOfDayMinutes.parse(horaireOuverture!);
    final fermeture = TimeOfDayMinutes.parse(horaireFermeture!);
    final estOuvert = maintenant >= ouverture && maintenant <= fermeture;
    return estOuvert ? StatutPharmacie.ouvert : StatutPharmacie.ferme;
  }

  bool get aBanqueDeSang => stocksParGroupe != null && stocksParGroupe!.isNotEmpty;

  /// Distance en kilomètres depuis une position donnée (formule de Haversine).
  double distanceDepuis(double latUser, double lngUser) {
    const rayonTerre = 6371.0;
    final dLat = _versRadians(latitude - latUser);
    final dLng = _versRadians(longitude - lngUser);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_versRadians(latUser)) *
            cos(_versRadians(latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return rayonTerre * c;
  }

  double _versRadians(double degres) => degres * pi / 180;
}

/// Petit utilitaire pour comparer des horaires "HH:mm" sans dépendance externe.
class TimeOfDayMinutes {
  static int now() {
    final n = DateTime.now();
    return n.hour * 60 + n.minute;
  }

  static int parse(String hhmm) {
    final parts = hhmm.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}