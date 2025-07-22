import 'package:flutter/material.dart';

class MustacheLogo extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? letterColor;
  final Color? mustacheColor;

  const MustacheLogo({
    super.key,
    this.size = 48,
    this.backgroundColor,
    this.letterColor,
    this.mustacheColor,
  });

  @override
  Widget build(BuildContext context) {
    // Use the exact colors from the provided logo
    final bgColor = backgroundColor ?? Colors.transparent;
    final mColor = letterColor ?? Colors.black;
    final mustColor = mustacheColor ?? const Color(0xFF4CAF50); // Green from the logo

    return Container(
      width: size,
      height: size,
      decoration: bgColor != Colors.transparent ? BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size * 0.15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ) : null,
      child: CustomPaint(
        size: Size(size, size),
        painter: MustacheLogoPainter(
          letterColor: mColor,
          mustacheColor: mustColor,
        ),
      ),
    );
  }
}

class MustacheLogoPainter extends CustomPainter {
  final Color letterColor;
  final Color mustacheColor;

  MustacheLogoPainter({
    required this.letterColor,
    required this.mustacheColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the purple circular background first
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF8B5CF6), // Purple
          const Color(0xFF7C3AED), // Darker purple
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Draw full circle background
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      backgroundPaint,
    );

    final letterPaint = Paint()
      ..color = letterColor
      ..style = PaintingStyle.fill;

    final mustachePaint = Paint()
      ..color = mustacheColor
      ..style = PaintingStyle.fill;

    // Draw white outline for mustache
    final mustacheOutlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw the letter "M" - bold, serif-style like in the logo
    final mPath = Path();
    
    // Left vertical stroke
    mPath.moveTo(size.width * 0.15, size.height * 0.2);
    mPath.lineTo(size.width * 0.15, size.height * 0.8);
    mPath.lineTo(size.width * 0.28, size.height * 0.8);
    mPath.lineTo(size.width * 0.28, size.height * 0.4);
    
    // Left diagonal to center
    mPath.lineTo(size.width * 0.42, size.height * 0.65);
    mPath.lineTo(size.width * 0.5, size.height * 0.45);
    
    // Right diagonal from center
    mPath.lineTo(size.width * 0.58, size.height * 0.65);
    mPath.lineTo(size.width * 0.72, size.height * 0.4);
    
    // Right vertical stroke
    mPath.lineTo(size.width * 0.72, size.height * 0.8);
    mPath.lineTo(size.width * 0.85, size.height * 0.8);
    mPath.lineTo(size.width * 0.85, size.height * 0.2);
    mPath.lineTo(size.width * 0.72, size.height * 0.2);
    mPath.lineTo(size.width * 0.72, size.height * 0.3);
    
    // Inner right diagonal
    mPath.lineTo(size.width * 0.58, size.height * 0.55);
    mPath.lineTo(size.width * 0.5, size.height * 0.35);
    
    // Inner left diagonal
    mPath.lineTo(size.width * 0.42, size.height * 0.55);
    mPath.lineTo(size.width * 0.28, size.height * 0.3);
    mPath.lineTo(size.width * 0.28, size.height * 0.2);
    mPath.close();

    canvas.drawPath(mPath, letterPaint);

    // Draw the mustache with white outline first (slightly larger)
    final mustacheOutlinePath = Path();
    
    // Left side of mustache with white outline
    mustacheOutlinePath.moveTo(size.width * 0.18, size.height * 0.52);
    
    // Left curl
    mustacheOutlinePath.quadraticBezierTo(
      size.width * 0.15, size.height * 0.48,
      size.width * 0.18, size.height * 0.44,
    );
    
    mustacheOutlinePath.quadraticBezierTo(
      size.width * 0.22, size.height * 0.40,
      size.width * 0.28, size.height * 0.42,
    );
    
    // Left side flowing to center
    mustacheOutlinePath.quadraticBezierTo(
      size.width * 0.38, size.height * 0.44,
      size.width * 0.47, size.height * 0.48,
    );
    
    // Center dip
    mustacheOutlinePath.quadraticBezierTo(
      size.width * 0.49, size.height * 0.50,
      size.width * 0.5, size.height * 0.52,
    );
    
    mustacheOutlinePath.quadraticBezierTo(
      size.width * 0.51, size.height * 0.50,
      size.width * 0.53, size.height * 0.48,
    );
    
    // Right side flowing from center
    mustacheOutlinePath.quadraticBezierTo(
      size.width * 0.62, size.height * 0.44,
      size.width * 0.72, size.height * 0.42,
    );
    
    // Right curl
    mustacheOutlinePath.quadraticBezierTo(
      size.width * 0.78, size.height * 0.40,
      size.width * 0.82, size.height * 0.44,
    );
    
    mustacheOutlinePath.quadraticBezierTo(
      size.width * 0.85, size.height * 0.48,
      size.width * 0.82, size.height * 0.52,
    );
    
    // Bottom outline
    mustacheOutlinePath.quadraticBezierTo(
      size.width * 0.78, size.height * 0.56,
      size.width * 0.72, size.height * 0.54,
    );
    
    mustacheOutlinePath.quadraticBezierTo(
      size.width * 0.62, size.height * 0.52,
      size.width * 0.53, size.height * 0.56,
    );
    
    mustacheOutlinePath.quadraticBezierTo(
      size.width * 0.51, size.height * 0.58,
      size.width * 0.5, size.height * 0.60,
    );
    
    mustacheOutlinePath.quadraticBezierTo(
      size.width * 0.49, size.height * 0.58,
      size.width * 0.47, size.height * 0.56,
    );
    
    mustacheOutlinePath.quadraticBezierTo(
      size.width * 0.38, size.height * 0.52,
      size.width * 0.28, size.height * 0.54,
    );
    
    mustacheOutlinePath.quadraticBezierTo(
      size.width * 0.22, size.height * 0.56,
      size.width * 0.18, size.height * 0.52,
    );
    
    mustacheOutlinePath.close();

    // Draw white outline
    canvas.drawPath(mustacheOutlinePath, mustacheOutlinePaint);

    // Draw the green mustache (slightly smaller, centered)
    final mustachePath = Path();
    
    // Left side of mustache
    mustachePath.moveTo(size.width * 0.19, size.height * 0.52);
    
    // Left curl
    mustachePath.quadraticBezierTo(
      size.width * 0.16, size.height * 0.48,
      size.width * 0.19, size.height * 0.45,
    );
    
    mustachePath.quadraticBezierTo(
      size.width * 0.22, size.height * 0.42,
      size.width * 0.28, size.height * 0.43,
    );
    
    // Left side flowing to center
    mustachePath.quadraticBezierTo(
      size.width * 0.38, size.height * 0.45,
      size.width * 0.47, size.height * 0.49,
    );
    
    // Center dip
    mustachePath.quadraticBezierTo(
      size.width * 0.49, size.height * 0.51,
      size.width * 0.5, size.height * 0.53,
    );
    
    mustachePath.quadraticBezierTo(
      size.width * 0.51, size.height * 0.51,
      size.width * 0.53, size.height * 0.49,
    );
    
    // Right side flowing from center
    mustachePath.quadraticBezierTo(
      size.width * 0.62, size.height * 0.45,
      size.width * 0.72, size.height * 0.43,
    );
    
    // Right curl
    mustachePath.quadraticBezierTo(
      size.width * 0.78, size.height * 0.42,
      size.width * 0.81, size.height * 0.45,
    );
    
    mustachePath.quadraticBezierTo(
      size.width * 0.84, size.height * 0.48,
      size.width * 0.81, size.height * 0.52,
    );
    
    // Bottom
    mustachePath.quadraticBezierTo(
      size.width * 0.78, size.height * 0.55,
      size.width * 0.72, size.height * 0.53,
    );
    
    mustachePath.quadraticBezierTo(
      size.width * 0.62, size.height * 0.51,
      size.width * 0.53, size.height * 0.55,
    );
    
    mustachePath.quadraticBezierTo(
      size.width * 0.51, size.height * 0.57,
      size.width * 0.5, size.height * 0.58,
    );
    
    mustachePath.quadraticBezierTo(
      size.width * 0.49, size.height * 0.57,
      size.width * 0.47, size.height * 0.55,
    );
    
    mustachePath.quadraticBezierTo(
      size.width * 0.38, size.height * 0.51,
      size.width * 0.28, size.height * 0.53,
    );
    
    mustachePath.quadraticBezierTo(
      size.width * 0.22, size.height * 0.55,
      size.width * 0.19, size.height * 0.52,
    );
    
    mustachePath.close();

    canvas.drawPath(mustachePath, mustachePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}