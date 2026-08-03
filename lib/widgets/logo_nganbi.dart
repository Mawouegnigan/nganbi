import 'package:flutter/material.dart';

/// Logo NganBi : goutte stylisée avec un repère de localisation en négatif.
/// Dessiné en code (CustomPainter) pour rester net à toutes les tailles,
/// sans dépendre d'un fichier image.
class LogoNganBi extends StatelessWidget {
  final double hauteur;
  final Color couleurGoutte;
  final Color couleurRepere;

  const LogoNganBi({
    super.key,
    this.hauteur = 32,
    this.couleurGoutte = Colors.white,
    required this.couleurRepere,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(hauteur * 100 / 138, hauteur),
      painter: _LogoPainter(couleurGoutte: couleurGoutte, couleurRepere: couleurRepere),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color couleurGoutte;
  final Color couleurRepere;

  _LogoPainter({required this.couleurGoutte, required this.couleurRepere});

  @override
  void paint(Canvas canvas, Size size) {
    final ex = size.width / 100;
    final ey = size.height / 138;

    final goutte = Path()
      ..moveTo(50 * ex, 10 * ey)
      ..cubicTo(78 * ex, 45 * ey, 95 * ex, 72 * ey, 95 * ex, 95 * ey)
      ..cubicTo(95 * ex, 118 * ey, 75 * ex, 138 * ey, 50 * ex, 138 * ey)
      ..cubicTo(25 * ex, 138 * ey, 5 * ex, 118 * ey, 5 * ex, 95 * ey)
      ..cubicTo(5 * ex, 72 * ey, 22 * ex, 45 * ey, 50 * ex, 10 * ey)
      ..close();
    canvas.drawPath(goutte, Paint()..color = couleurGoutte);

    canvas.drawCircle(Offset(50 * ex, 95 * ey), 15 * ey, Paint()..color = couleurRepere);

    final pointeRepere = Path()
      ..moveTo(38 * ex, 105 * ey)
      ..lineTo(50 * ex, 130 * ey)
      ..lineTo(62 * ex, 105 * ey)
      ..close();
    canvas.drawPath(pointeRepere, Paint()..color = couleurRepere);
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) =>
      oldDelegate.couleurGoutte != couleurGoutte || oldDelegate.couleurRepere != couleurRepere;
}