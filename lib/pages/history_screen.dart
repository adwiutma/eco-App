import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../service/firestore.dart';

class HistoryScreen extends StatelessWidget {
  final String userId;

  const HistoryScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Riwayat Sampah',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green[700],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: firestoreService.getUserStatistics(userId),
        builder: (context, statsSnapshot) {
          if (statsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (statsSnapshot.hasError) {
            return Center(
                child: Text('Terjadi kesalahan: ${statsSnapshot.error}'));
          } else if (!statsSnapshot.hasData) {
            return const Center(child: Text('Data statistik tidak ditemukan.'));
          }

          final userStats = statsSnapshot.data!;
          final totalWeight = userStats['totalWeight'] as double;
          final totalPrice = userStats['totalPrice'] as double;
          final mostFrequentWasteType =
              userStats['mostFrequentWasteType'] as String;

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: firestoreService.getWasteEntriesByUserId(userId),
            builder: (context, entriesSnapshot) {
              if (entriesSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (entriesSnapshot.hasError) {
                return Center(
                    child: Text('Terjadi kesalahan: ${entriesSnapshot.error}'));
              } else if (!entriesSnapshot.hasData ||
                  entriesSnapshot.data!.isEmpty) {
                return const Center(child: Text('Belum ada data sampah.'));
              }

              final wasteEntries = entriesSnapshot.data!;
              final groupedEntries = _groupEntriesByDate(wasteEntries);

              return ListView(
                children: [
                  // Statistik Pengguna
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: Colors.green[50],
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Statistik Pengguna',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatisticItem(
                                  icon: Icons.scale,
                                  label: 'Total Berat',
                                  value: '${totalWeight.toStringAsFixed(2)} kg',
                                  color: Colors.green[700]!,
                                ),
                                _buildStatisticItem(
                                  icon: Icons.monetization_on,
                                  label: 'Pengeluaran',
                                  value: currencyFormatter.format(totalPrice),
                                  color: Colors.green[800]!,
                                ),
                                _buildStatisticItem(
                                  icon: Icons.recycling,
                                  label: 'Sampah Favorit',
                                  value: mostFrequentWasteType,
                                  color: Colors.green[600]!,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Daftar Riwayat
                  ...groupedEntries.entries.map((entry) {
                    final date = entry.key;
                    final entries = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                                .format(date),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                        ),
                        ...entries.map((entry) {
                          final timestamp =
                              (entry['timestamp'] as Timestamp?)?.toDate() ??
                                  DateTime.now();
                          final userName =
                              entry['userName'] ?? 'Pengguna Tidak Diketahui';
                          final wasteType =
                              entry['wasteType'] ?? 'Jenis Tidak Diketahui';
                          final weight = entry['weight']?.toDouble() ?? 0.0;
                          final price = entry['price']?.toDouble() ?? 0.0;
                          final totalPrice = price;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 16),
                            child: ListTile(
                              leading: Icon(Icons.recycling,
                                  color: Colors.green[800]),
                              title: Text(
                                wasteType,
                                style: TextStyle(
                                  color: Colors.green[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Pengguna: $userName\nBerat: ${weight.toStringAsFixed(2)} kg\nTotal: ${currencyFormatter.format(totalPrice)}',
                                style: const TextStyle(color: Colors.green),
                              ),
                              trailing: Text(
                                DateFormat('HH:mm').format(timestamp),
                                style: TextStyle(color: Colors.green[900]),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatisticItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green[900]),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 14, color: Colors.green[800]),
        ),
      ],
    );
  }

  Map<DateTime, List<Map<String, dynamic>>> _groupEntriesByDate(
      List<Map<String, dynamic>> entries) {
    final Map<DateTime, List<Map<String, dynamic>>> groupedEntries = {};

    for (var entry in entries) {
      final timestamp =
          (entry['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
      final date = DateTime(timestamp.year, timestamp.month, timestamp.day);

      if (!groupedEntries.containsKey(date)) {
        groupedEntries[date] = [];
      }
      groupedEntries[date]!.add(entry);
    }

    return groupedEntries;
  }
}
