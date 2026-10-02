import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // SOSTITUISCI QUESTO URL CON IL LINK CSV REALE E COMPLETO DEL TUO GOOGLE SHEETS
  static const String configCsvUrl =
      'https://docs.google.com/spreadsheets/d/e/INSERISCI_IL_TUO_ID_REALE/pub?output=csv';

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