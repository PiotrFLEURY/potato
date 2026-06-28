import 'package:flutter/widgets.dart';
import 'package:potato/views/theme.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: PotatoColors.smoothBackground3,
        border: Border.all(color: PotatoColors.gray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: PotatoColors.gray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
