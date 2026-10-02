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

  @override
  void initState() {
    super.initState();
    _tablesFuture = _loadAllTables();
  }

  Future<List<Map<String, dynamic>>> _loadAllTables() async {
    List<Map<String, dynamic>> loadedTables = [];
    for (var config in widget.tablesForPage) {
      if (config.url.isNotEmpty) {
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
    }
    return loadedTables;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pageName),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
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
          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: tables.length,
            separatorBuilder: (context, index) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              final table = tables[index];
              if (table.containsKey('error') && table['error'] != null) {
                return Card(
                  color: Colors.amber.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Errore nel caricamento della tabella "${table['title']}": ${table['error']}',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                );
              }
              return DynamicTableWidget(
                title: table['title'] ?? '',
                data: table['data'] as List<List<dynamic>>,
              );
            },
          );
        },
      ),
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
              'La sezione "${widget.pageName}" non ha ancora tabelle o componenti personalizzati configurati.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}