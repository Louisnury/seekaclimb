import 'package:flutter/material.dart';

class CwFloatingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color? iconColor;
  final double? size;
  final IconData icon;

  const CwFloatingButton({
    super.key,
    this.onPressed,
    required this.backgroundColor,
    this.iconColor,
    this.size = 56.0,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20.0,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: iconColor ?? Colors.white, size: 28),
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
        ),
      ),
    );
  }
}
