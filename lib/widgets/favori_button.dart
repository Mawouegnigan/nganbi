import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Bouton favori réutilisable.
/// L'état estFavori et le callback sont fournis par l'écran parent,
/// qui gère la persistance (SharedPreferences ou sous-collection Firestore
/// selon le mécanisme retenu pour l'app).
class FavoriButton extends StatelessWidget {
  final bool estFavori;
  final VoidCallback onToggle;

  const FavoriButton({
    super.key,
    required this.estFavori,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        estFavori ? Icons.favorite : Icons.favorite_border,
        color: estFavori ? context.rougeUrgence : context.texteSecondaire,
      ),
      onPressed: onToggle,
      tooltip: estFavori ? 'Retirer des favoris' : 'Ajouter aux favoris',
    );
  }
}