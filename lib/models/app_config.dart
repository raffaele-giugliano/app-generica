class PageConfig {
  final String pagina;
  final String tabella;
  final String url;

  PageConfig({
    required this.pagina,
    required this.tabella,
    required this.url,
  });

  factory PageConfig.fromCsvRow(List<dynamic> row) {
    return PageConfig(
      pagina: row.isNotEmpty ? row[0].toString().trim() : '',
      tabella: row.length > 1 ? row[1].toString().trim() : '',
      url: row.length > 2 ? row[2].toString().trim() : '',
    );
  }
}