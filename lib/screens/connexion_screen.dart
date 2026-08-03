import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../widgets/en_tete_nganbi.dart';

class ConnexionScreen extends StatefulWidget {
  const ConnexionScreen({super.key});

  @override
  State<ConnexionScreen> createState() => _ConnexionScreenState();
}

class _ConnexionScreenState extends State<ConnexionScreen> {
  final _emailController = TextEditingController();
  final _motDePasseController = TextEditingController();
  bool _enCours = false;
  String? _messageErreur;

  Future<void> _seConnecter() async {
    setState(() {
      _enCours = true;
      _messageErreur = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _motDePasseController.text,
      );
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _messageErreur = switch (e.code) {
          'user-not-found' => 'Aucun compte avec cet e-mail.',
          'wrong-password' => 'Mot de passe incorrect.',
          'invalid-email' => 'Adresse e-mail invalide.',
          'invalid-credential' => 'E-mail ou mot de passe incorrect.',
          _ => 'Erreur de connexion : ${e.message}',
        };
      });
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.fondEcran,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EnTetePetite(titre: 'Connexion administrateur'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      filled: true,
                      fillColor: context.vertClair,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _motDePasseController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      filled: true,
                      fillColor: context.vertClair,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  if (_messageErreur != null) ...[
                    const SizedBox(height: 12),
                    Text(_messageErreur!, style: TextStyle(color: context.rougeUrgence, fontSize: 13)),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _enCours ? null : _seConnecter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.vertPrincipal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _enCours
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Se connecter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}