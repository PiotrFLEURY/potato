import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:potato/views/files/files_page.dart';
import 'package:potato/views/home/home_page.dart';

class PotatoApp extends StatelessWidget {
  const PotatoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'Potato',
      onGenerateTitle: (context) => context.tr('app_title'),
      theme: ThemeData(primarySwatch: Colors.brown),
      routes: {
        '/': (context) => const HomePage(),
        '/files': (context) => const FilesPage(),
      },
      initialRoute: '/',
    );
  }
}
