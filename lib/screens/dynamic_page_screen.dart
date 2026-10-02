import 'package:flutter/material.dart';
import '../models/app_config.dart';
import '../services/csv_service.dart';
import '../widgets/dynamic_table_widget.dart';

class DynamicPageScreen extends StatefulWidget {
  final String pageName;
  final List<PageConfig> tablesForPage;

  const DynamicPageScreen({
    Key? key,
    required this.pageName,
    required this.tablesForPage,
  }) : super(key: key);

  @override
  State<DynamicPageScreen> createState() => _DynamicPageScreenState();
}

class _DynamicPageScreenState extends State<DynamicPageScreen> {
  late Future<List<Map<String, dynamic>>> _tablesFuture;
  bool _hasMissingUrl = false;

  @override
  void initState() {
    super.initState();
    
    // Verifica se manca l'URL anche solo per una delle tabelle collegate
    _hasMissingUrl = widget.tablesForPage.any((config) => config.url.trim().isEmpty);

    if (!_hasMissingUrl) {
      _tablesFuture = _loadAllTables();
    }
  }

  Future<List<Map<String, dynamic>>> _loadAllTables() async {
    List<Map<String, dynamic>> loadedTables = [];
    for (var config in widget.tablesForPage) {
      try {
        final data = await CsvService.fetchTableData(config.url);
        loadedTables.add({
          'title': config.tabella,
          'data': data,
        });
      } catch (e) {
        loadedTables.add({
          'title': config.tabella,
          'error': e.toString(),
          'data': <List<dynamic>>[],
        });
      }
    }
    return loadedTables;
  }

  @override
  Widget build(BuildContext context) {
    // COND_1: Se manca l'URL a una qualsiasi tabella, mostra la pagina di cortesia
    if (_hasMissingUrl) {
      return _buildScaffold(_buildCourtesyPage(context));
    }

    // COND_2: Se ci sono 2 o più tabelle e non è ancora configurata una logica custom, mostra la pagina di cortesia
    if (widget.tablesForPage.length > 1 && !_hasCustomLogicForPage(widget.pageName)) {
      return _buildScaffold(_buildCourtesyPage(context));
    }

    // COND_3: Se è definita una logica custom specifica per questa pagina
    if (_hasCustomLogicForPage(widget.pageName)) {
      return _buildScaffold(_buildCustomPageLayout(widget.pageName));
    }

    // COND_4: Pagina con tabella singola (con URL fornito)
    return _buildScaffold(
      FutureBuilder<List<Map<String, dynamic>>>(
        future: _tablesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Caricamento dati in corso...'),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Errore generale: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildCourtesyPage(context);
          }

          final tables = snapshot.data!;
          final singleTable = tables.first;

          if (singleTable.containsKey('error') && singleTable['error'] != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Errore nel caricamento della tabella "${singleTable['title']}": ${singleTable['error']}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: DynamicTableWidget(
              title: singleTable['title'] ?? '',
              data: singleTable['data'] as List<List<dynamic>>,
            ),
          );
        },
      ),
    );
  }

  /// Registro delle pagine che hanno una logica di visualizzazione personalizzata
  bool _hasCustomLogicForPage(String pageName) {
    // Aggiungi qui i nomi delle pagine non appena scriveremo la loro logica specifica
    const customPages = <String>{
      // Es. 'PaginaVendite',
    };
    return customPages.contains(pageName);
  }

  /// Placeholder per il layout personalizzato delle pagine specifiche
  Widget _buildCustomPageLayout(String pageName) {
    // In futuro inseriremo qui lo switch/case per richiamare i vari widget personalizzati
    return Center(
      child: Text('Layout personalizzato per la pagina: $pageName'),
    );
  }

  Widget _buildScaffold(Widget bodyContent) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pageName),
      ),
      body: bodyContent,
    );
  }

  Widget _buildCourtesyPage(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              size: 64,
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 16),
            Text(
              'Pagina in costruzione',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'La sezione "${widget.pageName}" non ha ancora tutti gli URL o le logiche specifiche configurate.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}