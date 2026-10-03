import 'package:flutter/material.dart';
import '../screens/detail_screen.dart';

class DynamicTableWidget extends StatefulWidget {
  final String title;
  final List<List<dynamic>> data;

  const DynamicTableWidget({
    Key? key,
    required this.title,
    required this.data,
  }) : super(key: key);

  @override
  State<DynamicTableWidget> createState() => _DynamicTableWidgetState();
}

class _DynamicTableWidgetState extends State<DynamicTableWidget> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _cardKeys = {};

  /// Tenta il parsing di una stringa contenente una data (GG-MM-AAAA, GG/MM/AAAA, AAAA-MM-GG)
  DateTime? _parseDate(String rawDate) {
    final cleaned = rawDate.trim();
    if (cleaned.isEmpty) return null;

    try {
      // Formato GG-MM-AAAA o GG/MM/AAAA
      if (cleaned.contains('-') || cleaned.contains('/')) {
        final separator = cleaned.contains('-') ? '-' : '/';
        final parts = cleaned.split(separator);
        if (parts.length == 3) {
          if (parts[0].length == 4) {
            // AAAA-MM-GG
            return DateTime.parse(cleaned.replaceAll('/', '-'));
          } else if (parts[2].length == 4) {
            // GG-MM-AAAA
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            return DateTime(year, month, day);
          }
        }
      }
      return DateTime.tryParse(cleaned);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Nessun dato disponibile.'),
        ),
      );
    }

    final allHeaders = widget.data.first;
    List<List<dynamic>> rows = widget.data.skip(1).toList();

    final isPartitePage = widget.title.toLowerCase().contains('partite');
    int? nextMatchIndex;

    if (isPartitePage && rows.isNotEmpty) {
      // 1. Ordinamento crescente basato sulla prima colonna (data/giorno)
      rows.sort((a, b) {
        final dateA = _parseDate(a.isNotEmpty ? a[0].toString() : '');
        final dateB = _parseDate(b.isNotEmpty ? b[0].toString() : '');

        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateA.compareTo(dateB);
      });

      // 2. Trova l'indice della prima partita con giorno >= data_oggi
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      for (int i = 0; i < rows.length; i++) {
        final rowDate = _parseDate(rows[i].isNotEmpty ? rows[i][0].toString() : '');
        if (rowDate != null) {
          final rowDateOnly = DateTime(rowDate.year, rowDate.month, rowDate.day);
          if (rowDateOnly.isAfter(today) || rowDateOnly.isAtSameMomentAs(today)) {
            nextMatchIndex = i;
            break;
          }
        }
      }

      // 3. Se trovata, esegui lo scroll automatico alla card evidenziata dopo il rendering
      if (nextMatchIndex != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final targetKey = _cardKeys[nextMatchIndex];
          if (targetKey != null && targetKey.currentContext != null) {
            Scrollable.ensureVisible(
              targetKey.currentContext!,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              alignment: 0.1, // Posiziona vicino alla cima
            );
          }
        });
      }
    }

    final previewHeaders = allHeaders.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ListView.separated(
          controller: _scrollController,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rows.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final row = rows[index];
            final isNextMatch = isPartitePage && index == nextMatchIndex;

            // Assegna una chiave per identificare la card da raggiungere con lo scroll
            _cardKeys[index] = GlobalKey();

            return Card(
              key: _cardKeys[index],
              elevation: isNextMatch ? 4 : 2,
              color: isNextMatch ? const Color(0xFFE8F0FE) : null, // Sfondo evidenziato per la prossima partita
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: isNextMatch
                    ? const BorderSide(color: Color(0xFF1A73E8), width: 2)
                    : BorderSide.none,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(
                        title: widget.title,
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isNextMatch) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A73E8),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'PROSSIMA PARTITA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            ...List.generate(
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
                                        TextSpan(
                                          text: '$headerName ',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(text: cellValue),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
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