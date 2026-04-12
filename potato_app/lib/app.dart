import 'package:flutter/material.dart';
import 'package:potato/views/home/home_page.dart';

class PotatoApp extends StatelessWidget {
  const PotatoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Potato',
      theme: ThemeData(primarySwatch: Colors.brown),
      routes: {'/': (context) => const HomePage()},
      initialRoute: '/',
    );
  }
}
