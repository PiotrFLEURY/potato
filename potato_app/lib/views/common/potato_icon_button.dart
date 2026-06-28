import 'package:flutter/material.dart';
import 'package:potato/views/theme.dart';

class PotatoIconButton extends StatelessWidget {
  const PotatoIconButton({super.key, required this.icon, this.onPressed});

  final Widget icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PotatoColors.smoothBackground2,
          border: Border.all(color: PotatoColors.gray),
          borderRadius: BorderRadius.circular(16),
        ),
        child: icon,
      ),
    );
  }
}
