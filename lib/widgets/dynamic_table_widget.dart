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

    // Considera solo le prime 4 colonne per l'anteprima nel riquadro
    final previewHeaders = allHeaders.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rows.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final row = rows[index];

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  // Apertura della pagina di dettaglio con TUTTI i campi della riga
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Area contenuti (Prime 4 colonne)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            previewHeaders.length,
                            (colIndex) {
                              final headerName = previewHeaders[colIndex].toString();
                              final cellValue = colIndex < row.length
                                  ? row[colIndex].toString()
                                  : '';

                              if (cellValue.trim().isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      height: 1.3,
                                    ),
                                    children: [
                                      // Intestazione in grassetto
                                      TextSpan(
                                        text: '$headerName ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // Valore in formato normale
                                      TextSpan(text: cellValue),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Freccia '>' per indicare la presenza del dettaglio
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}