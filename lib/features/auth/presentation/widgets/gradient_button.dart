import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.width,
    this.padding = const EdgeInsets.symmetric(vertical: 18),
    this.colors = const [Color(0xFFFF6A00), Color(0xFFFF3C4A)],
  });

  final VoidCallback? onPressed;
  final String text;
  final double? width;
  final EdgeInsets padding;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.4),
            blurRadius: 5,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: padding,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
} 