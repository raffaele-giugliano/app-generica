import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // Inserisci qui l'URL del CSV di configurazione pubblicato da Google Sheets
  static const String configCsvUrl =
      'https://docs.google.com/spreadsheets/d/e/2PACX-1vR.../pub?output=csv';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Generica PWA',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(configUrl: configCsvUrl),
    );
  }
}