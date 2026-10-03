import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends StatelessWidget {
  final String title;
  final List<dynamic> headers;
  final List<dynamic> rowData;

  const DetailScreen({
    Key? key,
    required this.title,
    required this.headers,
    required this.rowData,
  }) : super(key: key);

  /// Apri Google Maps tramite URL
  Future<void> _openGoogleMaps(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedAddress',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Impossibile aprire Google Maps per: $address');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title.isNotEmpty ? title : 'Dettaglio'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(headers.length, (index) {
                final headerName = headers[index].toString();
                final cellValue = index < rowData.length ? rowData[index].toString() : '';
                
                // Controllo case-insensitive se il nome campo contiene "indirizzo"
                final isAddress = headerName.toLowerCase().contains('indirizzo');

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome del campo in grassetto
                      Text(
                        headerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Valore del campo in formato normale
                      Text(
                        cellValue.isNotEmpty ? cellValue : '-',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      
                      // Se è un indirizzo ed è presente un valore, mostra il bottone 3D per Google Maps
                      if (isAddress && cellValue.trim().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () => _openGoogleMaps(cellValue),
                          icon: const Icon(Icons.map_outlined),
                          label: const Text('Navigazione Google Maps'),
                        ),
                      ],
                      const Divider(height: 24),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}