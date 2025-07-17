import 'package:flutter/material.dart';
import '../utils/theme.dart';

class MustacheLogo extends StatelessWidget {
  final double size;
  final Color backgroundColor;
  final Color letterColor;
  final Color mustacheColor;

  const MustacheLogo({
    super.key,
    this.size = 36.0,
    this.backgroundColor = Colors.white,
    this.letterColor = Colors.black,
    this.mustacheColor = AppTheme.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size / 10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Letter M
          Text(
            'M',
            style: TextStyle(
              fontSize: size * 0.6,
              fontWeight: FontWeight.bold,
              color: letterColor,
            ),
          ),
          // Mustache overlay
          Positioned(
            bottom: size * 0.25,
            child: Container(
              width: size * 0.7,
              height: size * 0.2,
              decoration: BoxDecoration(
                color: mustacheColor,
                borderRadius: BorderRadius.circular(size * 0.1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left curl
                  Container(
                    width: size * 0.2,
                    height: size * 0.2,
                    decoration: BoxDecoration(
                      color: mustacheColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(size * 0.1),
                        bottomLeft: Radius.circular(size * 0.1),
                      ),
                    ),
                  ),
                  // Right curl
                  Container(
                    width: size * 0.2,
                    height: size * 0.2,
                    decoration: BoxDecoration(
                      color: mustacheColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(size * 0.1),
                        bottomRight: Radius.circular(size * 0.1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}