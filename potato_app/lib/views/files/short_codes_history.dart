import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:potato/models/preferences/shared_preferences_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShortCodesHistory extends StatefulWidget {
  const ShortCodesHistory({super.key, required this.onTap});

  final void Function(String code) onTap;

  @override
  State<ShortCodesHistory> createState() => _ShortCodesHistoryState();
}

class _ShortCodesHistoryState extends State<ShortCodesHistory> {
  List<String>? shortCodes;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        shortCodes =
            prefs.getStringList(SharedPreferencesConstants.shortCodesHistory) ??
            [];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (shortCodes == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (shortCodes!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('recent_short_codes'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          height: 54 * min(3, shortCodes!.length).toDouble(),
          child: ListView.builder(
            itemCount: shortCodes!.length,
            itemBuilder: (context, index) {
              final code = shortCodes![index];
              return ListTile(
                title: Text(code),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                onTap: () => widget.onTap(code),
              );
            },
          ),
        ),
      ],
    );
  }
}
