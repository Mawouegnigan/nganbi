import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';

class ListeAvisRecus extends StatelessWidget {
  const ListeAvisRecus({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('avis')
          .orderBy('dateEnvoi', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final avis = snapshot.data!.docs;

        if (avis.isEmpty) {
          return Center(
            child: Text('Aucun avis reçu pour le moment.', style: TextStyle(color: context.texteSecondaire)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: avis.length,
          itemBuilder: (context, index) {
            final data = avis[index].data() as Map<String, dynamic>;
            final note = (data['note'] ?? 0) as int;
            final message = data['message'] ?? '';
            final contact = data['contact'];
            final dateEnvoi = data['dateEnvoi'] as Timestamp?;

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
                      children: [
                        Row(
                          children: List.generate(5, (i) => Icon(
                                i < note ? Icons.star : Icons.star_border,
                                color: context.vertPrincipal,
                                size: 18,
                              )),
                        ),
                        const Spacer(),
                        if (dateEnvoi != null)
                          Text(
                            _formatDate(dateEnvoi.toDate()),
                            style: TextStyle(fontSize: 12, color: context.texteSecondaire),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(message, style: const TextStyle(fontSize: 14)),
                    if (contact != null && contact.toString().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Contact : $contact',
                        style: TextStyle(fontSize: 12, color: context.texteSecondaire, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final j = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$j/$m/${date.year}';
  }
}