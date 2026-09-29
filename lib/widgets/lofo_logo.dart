import 'package:flutter/material.dart';

class LofoLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isVertical;
  final bool isDarkText;

  const LofoLogo({
    super.key,
    this.size = 48,
    this.showText = true,
    this.isVertical = false,
    this.isDarkText = false,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBrown = Color(0xFFC87038);
    const darkBrown = Color(0xFF3D2115);

    final logoIcon = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryBrown, Color(0xFFE08244)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size * 0.12,
            child: Icon(
              Icons.location_on_rounded,
              color: Colors.white.withAlpha(90),
              size: size * 0.65,
            ),
          ),
          Icon(
            Icons.search_rounded,
            color: Colors.white,
            size: size * 0.52,
          ),
        ],
      ),
    );

    if (!showText) return logoIcon;

    final logoText = RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Lo',
            style: TextStyle(
              fontSize: size * 0.55,
              fontWeight: FontWeight.w900,
              color: isDarkText ? darkBrown : Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          TextSpan(
            text: 'Fo',
            style: TextStyle(
              fontSize: size * 0.55,
              fontWeight: FontWeight.w900,
              color: primaryBrown,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );

    if (isVertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          logoIcon,
          SizedBox(height: size * 0.2),
          logoText,
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logoIcon,
        SizedBox(width: size * 0.25),
        logoText,
      ],
    );
  }
}