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

  /// Normalizza la stringa rimuovendo accenti, apostrofi, spazi e convertendo in minuscolo
  static String _normalizeText(String input) {
    String text = input.toLowerCase().trim();
    
    // Rimuovi apostrofi usati al posto dell'accento
    text = text.replaceAll("'", "");

    // Sostituisci lettere accentate
    text = text
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u');

    return text;
  }

  /// Mapping dei giorni della settimana normalizzati (1 = Lunedì, 7 = Domenica)
  static const Map<String, int> _daysOfWeekMap = {
    'lunedi': DateTime.monday,
    'martedi': DateTime.tuesday,
    'mercoledi': DateTime.wednesday,
    'giovedi': DateTime.thursday,
    'venerdi': DateTime.friday,
    'sabato': DateTime.saturday,
    'domenica': DateTime.sunday,
  };

  /// Tenta il parsing di una stringa contenente una data (GG-MM-AAAA, GG/MM/AAAA, AAAA-MM-GG)
  DateTime? _parseDate(String rawDate) {
    final cleaned = rawDate.trim();
    if (cleaned.isEmpty) return null;

    try {
      if (cleaned.contains('-') || cleaned.contains('/')) {
        final separator = cleaned.contains('-') ? '-' : '/';
        final parts = cleaned.split(separator);
        if (parts.length == 3) {
          if (parts[0].length == 4) {
            return DateTime.parse(cleaned.replaceAll('/', '-'));
          } else if (parts[2].length == 4) {
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

  /// Calcola quanti giorni mancano al prossimo giorno della settimana specificato
  int _daysUntil(int targetWeekday, int currentWeekday) {
    int diff = targetWeekday - currentWeekday;
    if (diff < 0) {
      diff += 7;
    }
    return diff;
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

    final titleNormalized = _normalizeText(widget.title);
    final isPartitePage = titleNormalized.contains('partite');
    final isAllenamentiPage = titleNormalized.contains('allenamenti');

    int? highlightedIndex;
    String badgeText = '';

    // LOGICA PARTITE
    if (isPartitePage && rows.isNotEmpty) {
      badgeText = 'PROSSIMA PARTITA';
      rows.sort((a, b) {
        final dateA = _parseDate(a.isNotEmpty ? a[0].toString() : '');
        final dateB = _parseDate(b.isNotEmpty ? b[0].toString() : '');

        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateA.compareTo(dateB);
      });

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      for (int i = 0; i < rows.length; i++) {
        final rowDate = _parseDate(rows[i].isNotEmpty ? rows[i][0].toString() : '');
        if (rowDate != null) {
          final rowDateOnly = DateTime(rowDate.year, rowDate.month, rowDate.day);
          if (rowDateOnly.isAfter(today) || rowDateOnly.isAtSameMomentAs(today)) {
            highlightedIndex = i;
            break;
          }
        }
      }
    }

    // LOGICA ALLENAMENTI
    if (isAllenamentiPage && rows.isNotEmpty) {
      badgeText = 'PROSSIMO ALLENAMENTO';
      final currentWeekday = DateTime.now().weekday;
      int minDaysDifference = 999;

      for (int i = 0; i < rows.length; i++) {
        final rawDay = rows[i].isNotEmpty ? rows[i][0].toString() : '';
        final normalizedDay = _normalizeText(rawDay);
        final targetWeekday = _daysOfWeekMap[normalizedDay];

        if (targetWeekday != null) {
          final daysDiff = _daysUntil(targetWeekday, currentWeekday);
          if (daysDiff < minDaysDifference) {
            minDaysDifference = daysDiff;
            highlightedIndex = i;
          }
        }
      }
    }

    // Esegui l'auto-scroll se è stata trovata una card da evidenziare
    if (highlightedIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final targetKey = _cardKeys[highlightedIndex];
        if (targetKey != null && targetKey.currentContext != null) {
          Scrollable.ensureVisible(
            targetKey.currentContext!,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            alignment: 0.1,
          );
        }
      });
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
            final isHighlighted = index == highlightedIndex;

            _cardKeys[index] = GlobalKey();

            return Card(
              key: _cardKeys[index],
              elevation: isHighlighted ? 4 : 2,
              color: isHighlighted ? const Color(0xFFE8F0FE) : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: isHighlighted
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
                            if (isHighlighted && badgeText.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A73E8),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  badgeText,
                                  style: const TextStyle(
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
                                final headerName =
                                    previewHeaders[colIndex].toString();
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