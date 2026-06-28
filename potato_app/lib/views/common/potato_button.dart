import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:potato/views/theme.dart';

class PotatoButton extends StatelessWidget {
  const PotatoButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor = PotatoColors.primary,
    this.enabled = true,
    this.icon,
  });

  const PotatoButton.primary({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor = PotatoColors.primary,
    this.enabled = true,
    this.icon,
  });

  const PotatoButton.secondary({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor = PotatoColors.smoothBackground3,
    this.enabled = true,
    this.icon,
  });

  const PotatoButton.disabled({
    super.key,
    this.onPressed,
    required this.child,
    this.backgroundColor = PotatoColors.gray,
    this.enabled = false,
    this.icon,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color backgroundColor;
  final bool enabled;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: enabled
            ? LinearGradient(
                colors: [backgroundColor.withAlpha(200), backgroundColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        border: backgroundColor == PotatoColors.smoothBackground3
            ? Border.all(color: Colors.grey.shade400, width: 1)
            : null,
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: backgroundColor == PotatoColors.smoothBackground3
                      ? Colors.black
                      : enabled
                      ? Colors.white
                      : Colors.grey.shade200,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                child: icon != null
                    ? Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [icon!, const SizedBox(width: 8), child],
                      )
                    : Center(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
