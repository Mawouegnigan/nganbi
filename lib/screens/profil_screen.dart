import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/en_tete_nganbi.dart';
import 'donner_avis_screen.dart';
import 'admin_screen.dart';
import 'connexion_screen.dart';

class ProfilScreen extends StatelessWidget {
  final bool modeSombre;
  final ValueChanged<bool> onChangerModeSombre;
  final bool estConnecte;
  final bool estAdmin;
  final String? emailUtilisateur;
  final VoidCallback onSeDeconnecter;

  const ProfilScreen({
    super.key,
    required this.modeSombre,
    required this.onChangerModeSombre,
    required this.estConnecte,
    required this.estAdmin,
    required this.emailUtilisateur,
    required this.onSeDeconnecter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.fondEcran,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EnTetePetite(titre: 'Profil'),
            Expanded(
              child: ListView(
                children: [
                  if (!estConnecte)
                    ListTile(
                      leading: Icon(Icons.login, color: context.vertPrincipal),
                      title: const Text('Connexion administrateur'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ConnexionScreen()),
                      ),
                    )
                  else ...[
                    ListTile(
                      leading: Icon(Icons.account_circle_outlined, color: context.vertPrincipal),
                      title: Text(emailUtilisateur ?? 'Connecté'),
                      subtitle: Text(estAdmin ? 'Compte administrateur' : 'Connecté'),
                    ),
                    ListTile(
                      leading: Icon(Icons.logout, color: context.rougeUrgence),
                      title: const Text('Se déconnecter'),
                      onTap: onSeDeconnecter,
                    ),
                  ],
                  const Divider(height: 24),
                  SwitchListTile(
                    title: const Text('Mode sombre'),
                    value: modeSombre,
                    activeColor: context.vertPrincipal,
                    onChanged: onChangerModeSombre,
                  ),
                  ListTile(
                    leading: Icon(Icons.language_outlined, color: context.vertPrincipal),
                    title: const Text('Langue'),
                    subtitle: const Text('Français'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Sélecteur fr / en / yo / guw à brancher sur intl.
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.rate_review_outlined, color: context.vertPrincipal),
                    title: const Text('Donner mon avis'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DonnerAvisScreen()),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.privacy_tip_outlined, color: context.vertPrincipal),
                    title: const Text('Politique de confidentialité'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  if (estAdmin) ...[
                    const Divider(height: 32),
                    ListTile(
                      leading: Icon(Icons.admin_panel_settings_outlined, color: context.vertPrincipal),
                      title: const Text('Espace administrateur'),
                      subtitle: const Text('Mise à jour des disponibilités'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminScreen()),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}