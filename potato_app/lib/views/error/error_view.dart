import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:potato/views/common/potato_button.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required String errorMessage})
    : _errorMessage = errorMessage;

  final String _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 24,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/potato_error.png',
            width: 200,
            height: 200,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(
            child: Text(
              _errorMessage,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: PotatoButton.primary(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.tr('close')),
          ),
        ),
      ],
    );
  }
}
