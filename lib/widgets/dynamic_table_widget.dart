// Se siamo nella prima colonna, tentiamo di formattare la data
                                if (colIndex == 0) {
                                  final parsedDate = _parseDate(cellValue);
                                  if (parsedDate != null) {
                                    const weekdays = [
                                      'Lunedì',
                                      'Martedì',
                                      'Mercoledì',
                                      'Giovedì',
                                      'Venerdì',
                                      'Sabato',
                                      'Domenica'
                                    ];
                                    final dayName = weekdays[parsedDate.weekday - 1];
                                    // Formato: 01-01-2027 - Domenica
                                    cellValue = '$cellValue - $dayName';
                                  }
                                }