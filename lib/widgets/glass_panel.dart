import 'dart:ui';
import 'package:flutter/material.dart';

/// Базовый "стеклянный" контейнер: размытие фона + полупрозрачная
/// заливка + тонкая светлая обводка + мягкая тень.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color tint;
  final Border? border;

  const GlassPanel({
    super.key,
    required this.child,
    this.blur = 22,
    this.opacity = 0.10,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.padding,
    this.tint = Colors.white,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint.withOpacity(opacity),
            borderRadius: borderRadius,
            border: border ??
                Border.all(
                  color: Colors.white.withOpacity(0.18),
                  width: 1.2,
                ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
