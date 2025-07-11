import 'package:flutter/material.dart';

class WasteDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> wasteType;

  const WasteDetailsScreen({super.key, required this.wasteType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          wasteType['name'] ?? 'Detail Jenis Sampah',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[100]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (wasteType['imageUrl'] != null &&
                    wasteType['imageUrl']!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      wasteType['imageUrl']!,
                      width: MediaQuery.of(context).size.width,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  'Sampah ${wasteType['name'] ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Harga: ${wasteType['price'] ?? 'Tidak tersedia'}/kg',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
                _buildCardSection(
                  title: 'Deskripsi',
                  content:
                      wasteType['deskripsi'] ?? 'Tidak ada deskripsi tersedia.',
                ),
                const SizedBox(height: 20),
                _buildCardSection(
                  title: 'Tipe',
                  content: wasteType['tipe'],
                  icon: Icons.category,
                ),
                _buildCardSection(
                  title: 'Waktu Terurai',
                  content: wasteType['waktu_terurai'],
                  icon: Icons.access_time,
                ),
                _buildCardSection(
                  title: 'Contoh',
                  content: wasteType['contoh'],
                  icon: Icons.lightbulb_outline,
                ),
                _buildCardSection(
                  title: 'Kategori Pengolahan',
                  content: wasteType['kategori_pengolahan'],
                  icon: Icons.recycling,
                ),
                _buildCardSection(
                  title: 'Potensi Dampak',
                  content: wasteType['potensi_dampak'],
                  icon: Icons.warning,
                ),
                _buildCardSection(
                  title: 'Manfaat Daur Ulang',
                  content: wasteType['manfaat_daur_ulang'],
                  icon: Icons.eco,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardSection({
    required String title,
    dynamic content,
    IconData? icon,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) Icon(icon, color: Colors.green[700], size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content != null && content.toString().isNotEmpty
                        ? content.toString()
                        : 'Tidak tersedia.',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
