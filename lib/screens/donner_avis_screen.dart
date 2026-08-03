import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';

class DonnerAvisScreen extends StatefulWidget {
  const DonnerAvisScreen({super.key});

  @override
  State<DonnerAvisScreen> createState() => _DonnerAvisScreenState();
}

class _DonnerAvisScreenState extends State<DonnerAvisScreen> {
  int _note = 5;
  final _messageController = TextEditingController();
  final _contactController = TextEditingController();
  bool _envoiEnCours = false;

  Future<void> _envoyer() async {
    if (_messageController.text.trim().isEmpty) return;
    setState(() => _envoiEnCours = true);
    try {
      await FirebaseFirestore.instance.collection('avis').add({
        'note': _note,
        'message': _messageController.text.trim(),
        'contact': _contactController.text.trim().isEmpty ? null : _contactController.text.trim(),
        'dateEnvoi': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        _messageController.clear();
        _contactController.clear();
        setState(() => _note = 5);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Merci pour votre avis')),
        );
      }
    } finally {
      if (mounted) setState(() => _envoiEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.fondEcran,
      appBar: AppBar(
        title: const Text('Donner mon avis'),
        backgroundColor: context.fondEcran,
        elevation: 0,
        foregroundColor: context.vertPrincipal,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Votre note', style: TextStyle(fontWeight: FontWeight.w600, color: context.texteSecondaire)),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              final valeur = index + 1;
              return IconButton(
                icon: Icon(
                  valeur <= _note ? Icons.star : Icons.star_border,
                  color: context.vertPrincipal,
                  size: 30,
                ),
                onPressed: () => setState(() => _note = valeur),
              );
            }),
          ),
          const SizedBox(height: 16),
          Text('Votre message', style: TextStyle(fontWeight: FontWeight.w600, color: context.texteSecondaire)),
          const SizedBox(height: 8),
          TextField(
            controller: _messageController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Partagez votre expérience...',
              filled: true,
              fillColor: context.vertClair,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          Text('Contact (optionnel)', style: TextStyle(fontWeight: FontWeight.w600, color: context.texteSecondaire)),
          const SizedBox(height: 8),
          TextField(
            controller: _contactController,
            decoration: InputDecoration(
              hintText: 'Téléphone ou email',
              filled: true,
              fillColor: context.vertClair,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _envoiEnCours ? null : _envoyer,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.vertPrincipal,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _envoiEnCours
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Envoyer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}