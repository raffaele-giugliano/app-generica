import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PWA Google Sheets',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class ConfigEntry {
  final String pagina;
  final String tabella;
  final String url;

  ConfigEntry({
    required this.pagina,
    required this.tabella,
    required this.url,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // URL del CSV remoto di configurazione fornito
  final String configCsvUrl =
      'https://docs.google.com/spreadsheets/d/e/2PACX-1vTK1BzKUMV1BRG_DymJVueT0R5guHPAqz7ZpJngaTIp487sbIJLl5uh8UFkLtDfX0SOd8ge5YSZILwr/pub?gid=1930029797&single=true&output=csv';

  List<ConfigEntry> _configData = [];
  List<String> _pagineDisponibili = [];
  String? _paginaSelezionata;
  bool _isLoadingConfig = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _caricaConfigurazione();
  }

  Future<void> _caricaConfigurazione() async {
    try {
      final response = await http.get(Uri.parse(configCsvUrl));
      if (response.statusCode == 200) {
        List<List<dynamic>> rows =
            CsvToListConverter().convert(response.body);

        List<ConfigEntry> entries = [];
        Set<String> pagineSet = {};

        // Salta l'intestazione (i = 1)
        for (var i = 1; i < rows.length; i++) {
          if (rows[i].length >= 3) {
            String pag = rows[i][0].toString().trim();
            String tab = rows[i][1].toString().trim();
            String link = rows[i][2].toString().trim();

            if (pag.isNotEmpty) {
              entries.add(ConfigEntry(pagina: pag, tabella: tab, url: link));
              pagineSet.add(pag);
            }
          }
        }

        setState(() {
          _configData = entries;
          _pagineDisponibili = pagineSet.toList();
          _isLoadingConfig = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Errore nel caricamento dell\'indice: ${response.statusCode}';
          _isLoadingConfig = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Errore di connessione: $e';
        _isLoadingConfig = false;
      });
    }
  }

  void _visualizzaPagina() {
    if (_paginaSelezionata == null) return;

    // Recupera tutte le righe del CSV di indice associate alla pagina selezionata
    final tabelleAssociate = _configData
        .where((entry) => entry.pagina == _paginaSelezionata)
        .toList();

    // Apre la pagina di cortesia
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaginaCortesiaScreen(
          nomePagina: _paginaSelezionata!,
          tabelle: tabelleAssociate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleziona Pagina'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _isLoadingConfig
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Caricamento elenco pagine...'),
                  ],
                ),
              )
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Pagine disponibili:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        hint: const Text('Seleziona una pagina'),
                        value: _paginaSelezionata,
                        items: _pagineDisponibili.map((String pagina) {
                          return DropdownMenuItem<String>(
                            value: pagina,
                            child: Text(pagina),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _paginaSelezionata = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed:
                            _paginaSelezionata != null ? _visualizzaPagina : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Visualizza Pagina',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class PaginaCortesiaScreen extends StatefulWidget {
  final String nomePagina;
  final List<ConfigEntry> tabelle;

  const PaginaCortesiaScreen({
    super.key,
    required this.nomePagina,
    required this.tabelle,
  });

  @override
  State<PaginaCortesiaScreen> createState() => _PaginaCortesiaScreenState();
}

class _PaginaCortesiaScreenState extends State<PaginaCortesiaScreen> {
  bool _isLoading = true;
  Map<String, List<List<dynamic>>> _datiTabelle = {};
  String _statusMessage = 'Scaricamento tabelle in corso...';

  @override
  void initState() {
    super.initState();
    _scaricaTabelle();
  }

  Future<void> _scaricaTabelle() async {
    Map<String, List<List<dynamic>>> mappaRisultati = {};

    for (var item in widget.tabelle) {
      try {
        final res = await http.get(Uri.parse(item.url));
        if (res.statusCode == 200) {
          List<List<dynamic>> csvData =
              CsvToListConverter().convert(res.body);
          mappaRisultati[item.tabella] = csvData;
        }
      } catch (e) {
        // Gestione errore scaricamento singola tabella
      }
    }

    setState(() {
      _datiTabelle = mappaRisultati;
      _isLoading = false;
      _statusMessage = 'Tutte le tabelle sono state caricate con successo!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nomePagina),
      ),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_statusMessage),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 72,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Pagina di Cortesia',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pagina selezionata: "${widget.nomePagina}"',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Tabelle scaricate in memoria:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _datiTabelle.keys
                          .map((t) => Chip(label: Text(t)))
                          .toList(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}