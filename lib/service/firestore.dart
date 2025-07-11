// lib/service/firestore.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getWasteTypes() async {
    QuerySnapshot snapshot = await _firestore.collection('waste_types').get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getKelompok() async {
    QuerySnapshot snapshot = await _firestore.collection('kelompok').get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getSchedulesWithWasteTypes() async {
    final schedulesSnapshot = await _firestore.collection('schedule').get();

    // Cache untuk menyimpan nama waste_types berdasarkan ID
    final Map<String, String> wasteTypesCache = {};

    // Fungsi untuk mendapatkan nama waste_types dari referensi dokumen
    Future<String> getWasteTypeName(DocumentReference ref) async {
      if (wasteTypesCache.containsKey(ref.id)) {
        return wasteTypesCache[ref.id]!;
      }
      final doc = await ref.get();
      final name =
          (doc.data() as Map<String, dynamic>?)?['name'] ?? 'Tidak diketahui';
      wasteTypesCache[ref.id] = name;
      return name;
    }

    // Mengambil data jadwal dengan jenis sampah
    return Future.wait(schedulesSnapshot.docs.map((scheduleDoc) async {
      final data = scheduleDoc.data();

      // Ambil nama waste_type jika ada referensi
      String wasteTypeName = 'Tidak diketahui';
      if (data['waste_types'] is DocumentReference) {
        final ref = data['waste_types'] as DocumentReference;
        wasteTypeName = await getWasteTypeName(ref);
      }

      return {
        'day': data['day'] ?? 'Hari tidak diketahui',
        'time': data['time'] ?? 'Tidak tersedia',
        'waste_types': wasteTypeName,
      };
    }).toList());
  }

  Future<void> addWasteEntry(Map<String, dynamic> data) async {
    await _firestore.collection('waste_entries').add(data);
  }

  Future<List<Map<String, dynamic>>> getWasteEntriesByUserId(
      String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('waste_entries')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<double> getTotalPriceByUserId(String userId) async {
    final snapshot = await _firestore
        .collection('waste_entries')
        .where('userId', isEqualTo: userId)
        .get();

    double total = 0.0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final price = (data['price'] ?? 0).toDouble();
      final weight = (data['weight'] ?? 0).toDouble();
      total += price * weight;
    }
    return total;
  }

  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    final entriesSnapshot = await _firestore
        .collection('waste_entries')
        .where('userId', isEqualTo: userId)
        .get();

    double totalWeight = 0.0;
    double totalPrice = 0.0;
    Map<String, int> wasteTypeCounts = {};

    for (var doc in entriesSnapshot.docs) {
      final data = doc.data();
      final weight = (data['weight'] ?? 0).toDouble();
      final price = (data['price'] ?? 0).toDouble();
      final wasteType = data['wasteType'] ?? 'Tidak diketahui';

      totalWeight += weight;
      totalPrice += price;
      wasteTypeCounts[wasteType] = (wasteTypeCounts[wasteType] ?? 0) + 1;
    }

    String mostFrequentWasteType = wasteTypeCounts.entries.isNotEmpty
        ? wasteTypeCounts.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key
        : 'Tidak ada';

    return {
      'totalWeight': totalWeight,
      'totalPrice': totalPrice,
      'mostFrequentWasteType': mostFrequentWasteType,
    };
  }

  Future<List<Map<String, dynamic>>> getWasteEntriesByDateRange(
      String userId, DateTime startDate, DateTime endDate) async {
    final snapshot = await _firestore
        .collection('waste_entries')
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .where('timestamp', isLessThanOrEqualTo: endDate)
        .get();

    return snapshot.docs
        .map((doc) => doc.data())
        .toList();
  }
}
