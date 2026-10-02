import 'package:flutter/material.dart';

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

    final headers = data.first;
    final rows = data.skip(1).toList();

    return Column(
      crossAxisAlignment: CrossAlignment.start,
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
              columns: headers
                  .map((header) => DataColumn(
                        label: Text(
                          header.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ))
                  .toList(),
              rows: rows
                  .map((row) => DataRow(
                        cells: row
                            .map((cell) => DataCell(Text(cell.toString())))
                            .toList(),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}