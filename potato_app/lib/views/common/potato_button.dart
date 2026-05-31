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
  });

  const PotatoButton.primary({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor = PotatoColors.primary,
    this.enabled = true,
  });

  const PotatoButton.secondary({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor = Colors.white,
    this.enabled = true,
  });

  const PotatoButton.disabled({
    super.key,
    this.onPressed,
    required this.child,
    this.backgroundColor = PotatoColors.gray,
    this.enabled = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color backgroundColor;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(32),
        border: backgroundColor == Colors.white
            ? Border.all(color: PotatoColors.gray, width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(32),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(32),
          child: SizedBox(
            width: double.infinity,
            height: kIsWeb ? 48 : 56,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: kIsWeb ? 8 : 12,
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: backgroundColor == Colors.white
                      ? Colors.black
                      : enabled
                      ? Colors.white
                      : Colors.grey.shade200,
                  fontSize: kIsWeb ? 12 : 16,
                  fontWeight: FontWeight.w700,
                ),
                child: Center(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
