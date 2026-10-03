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
    // Definizione dei colori per garantire massima visibilità e contrasto
    const buttonBgColor = Color(0xFF0D47A1); // Blu scuro/intenso per far risaltare il bottone
    const buttonTextColor = Colors.white;    // Testo bianco per contrasto nitido

    return MaterialApp(
      title: 'App Generica PWA',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonBgColor,
            foregroundColor: buttonTextColor,
            disabledBackgroundColor: Colors.grey.shade400,
            disabledForegroundColor: Colors.grey.shade700,
            
            // Effetto 3D / Rilievo
            elevation: 8,                  // Ombra pronunciata per l'effetto tridimensionale
            shadowColor: Colors.black54,   // Colore dell'ombra 3D
            surfaceTintColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            
            // Bordi e forma in rilievo
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(
                color: Color(0xFF1565C0),  // Bordo leggermente più chiaro per evidenziare i contorni
                width: 1.5,
              ),
            ),
            
            // Stile del testo e dell'icona
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            iconColor: buttonTextColor,
            iconSize: 22,
          ),
        ),
      ),
      home: const HomeScreen(configUrl: configCsvUrl),
    );
  }
}