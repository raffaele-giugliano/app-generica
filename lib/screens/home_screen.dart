import 'package:flutter/material.dart';
import '../models/app_config.dart';
import '../services/csv_service.dart';
import 'dynamic_page_screen.dart';

class HomeScreen extends StatefulWidget {
  final String configUrl;

  const HomeScreen({Key? key, required this.configUrl}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<PageConfig>> _configFuture;
  String? _selectedPage;

  @override
  void initState() {
    super.initState();
    _configFuture = CsvService.fetchConfig(widget.configUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Principale'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<PageConfig>>(
        future: _configFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Caricamento configurazione...'),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Errore nel caricamento della configurazione: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Nessun dato di configurazione disponibile.'),
            );
          }

          final allConfigs = snapshot.data!;
          final pageNames = allConfigs
              .map((c) => c.pagina)
              .where((name) => name.isNotEmpty)
              .toSet()
              .toList();

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Seleziona una pagina dal menu:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  hint: const Text('Scegli una pagina...'),
                  value: _selectedPage,
                  items: pageNames.map((page) {
                    return DropdownMenuItem<String>(
                      value: page,
                      child: Text(page),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPage = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text(
                    'Apri Pagina',
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: _selectedPage == null
                      ? null
                      : () {
                          final tablesForPage = allConfigs
                              .where((c) => c.pagina == _selectedPage)
                              .toList();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DynamicPageScreen(
                                pageName: _selectedPage!,
                                tablesForPage: tablesForPage,
                              ),
                            ),
                          );
                        },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}