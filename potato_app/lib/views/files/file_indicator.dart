import 'package:flutter/widgets.dart';

class FileIndicator extends StatelessWidget {
  const FileIndicator({
    super.key,
    required this.color,
    required this.fileExtension,
  });

  final Color color;
  final String fileExtension;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        border: Border.all(color: color.withAlpha(100)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          fileExtension.toUpperCase(),
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
