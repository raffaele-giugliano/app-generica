import 'package:flutter/material.dart';
import '../screens/detail_screen.dart';

class DynamicTableWidget extends StatelessWidget {
  final String title;
  final List<List<dynamic>> data;

  const DynamicTableWidget({
    Key? key,
    required this.title,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Nessun dato disponibile.'),
        ),
      );
    }

    final allHeaders = data.first;
    final rows = data.skip(1).toList();

    // Prendi solo le prime 4 colonne per la vista tabellare
    final displayHeaders = allHeaders.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              showCheckboxColumn: false,
              columns: [
                ...displayHeaders.map(
                  (header) => DataColumn(
                    label: Text(
                      header.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Colonna per l'icona con la freccia '>'
                const DataColumn(
                  label: SizedBox.shrink(),
                ),
              ],
              rows: rows.map((row) {
                // Prendi i dati delle prime 4 colonne per la visualizzazione nella tabella
                final displayCells = row.take(4).toList();

                return DataRow(
                  onSelectChanged: (_) {
                    // Al click sulla riga apri la pagina di dettaglio con TUTTI i dati della riga
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(
                          title: title,
                          headers: allHeaders,
                          rowData: row,
                        ),
                      ),
                    );
                  },
                  cells: [
                    ...displayCells.map(
                      (cell) => DataCell(
                        Text(cell.toString()),
                      ),
                    ),
                    // Freccia '>' alla fine della riga
                    const DataCell(
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}