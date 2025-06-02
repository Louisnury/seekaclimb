import 'package:flutter/material.dart';
import 'package:commun/commun.dart';

class CwBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final IconData? icon;

  const CwBackButton({
    super.key,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 50.0,
    this.icon = Icons.arrow_back,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16.0,
      left: 16.0,
      child: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(28.0),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(28.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onPressed ?? () => context.pop(),
            icon: Icon(
              icon,
              color: iconColor ?? Colors.white,
              size: (size! * 0.5),
            ),
            splashRadius: size! * 0.4,
          ),
        ),
      ),
    );
  }
}
