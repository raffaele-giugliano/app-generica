import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // Link diretto CSV pubblicato da Google Sheets
  static const String configCsvUrl =
      'https://docs.google.com/spreadsheets/d/e/2PACX-1vTK1BzKUMV1BRG_DymJVueT0R5guHPAqz7ZpJngaTIp487sbIJLl5uh8UFkLtDfX0SOd8ge5YSZILwr/pub?gid=1930029797&single=true&output=csv';

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