import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import '../models/app_config.dart';

class CsvService {
  /// Scarica e analizza il CSV di configurazione principale
  static Future<List<PageConfig>> fetchConfig(String configUrl) async {
    final response = await http.get(Uri.parse(configUrl));
    if (response.statusCode == 200) {
      List<List<dynamic>> rows = CsvToListConverter().convert(response.body);
      if (rows.length <= 1) return [];
      
      return rows.skip(1).map((row) => PageConfig.fromCsvRow(row)).toList();
    } else {
      throw Exception('Errore durante il caricamento del CSV di configurazione');
    }
  }

  /// Scarica e analizza una generica tabella CSV da Google Sheets
  static Future<List<List<dynamic>>> fetchTableData(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return CsvToListConverter().convert(response.body);
    } else {
      throw Exception('Errore durante il caricamento dei dati della tabella');
    }
  }
}