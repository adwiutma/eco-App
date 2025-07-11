// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sampah/pages/team_screen.dart';
import 'package:sampah/pages/waste_details_screen.dart';
import 'package:sampah/pages/waste_input_screen.dart';
import '../service/auth_service.dart';
import '../service/firestore.dart';
import 'history_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  final String userId;
  const DashboardScreen(
      {super.key, required this.userName, required this.userId});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<Map<String, dynamic>>> wasteTypesFuture;

  @override
  void initState() {
    super.initState();
    wasteTypesFuture = _firestoreService.getWasteTypes();
  }

  void navigateToWasteInput(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WasteInputScreen(
          userId: widget.userId,
          userName: widget.userName,
        ),
      ),
    );
  }

  void navigateToSchedule(BuildContext context) {
    Navigator.pushNamed(context, '/schedulePickup');
  }

  void navigateToArticles(BuildContext context) {
    Navigator.pushNamed(context, '/articles');
  }

  void navigateToWasteDetails(
      BuildContext context, Map<String, dynamic> wasteType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WasteDetailsScreen(wasteType: wasteType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HistoryScreen(userId: widget.userId),
              ),
            ),
          ),
          IconButton(
            icon:
                const Icon(Icons.group, color: Colors.white), // New icon button
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TeamScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final confirmLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text(
                    "Logout",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  content: const Text("Apakah Anda yakin ingin logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text(
                        "Batal",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmLogout == true) {
                final authService = AuthService();
                await authService.logout();
                // ignore: use_build_context_synchronously
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login', // Pastikan rute ini mengarah ke layar login Anda
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[100]!, Colors.green[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CarouselSlider(
                items: [
                  Image.asset('assets/banner1.png', fit: BoxFit.cover),
                  Image.asset('assets/banner2.png', fit: BoxFit.cover),
                  Image.asset('assets/banner3.png', fit: BoxFit.cover),
                ],
                options: CarouselOptions(
                  height: 200.0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  viewportFraction: 0.9,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Halo, ${widget.userName}!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Selamat datang di aplikasi manajemen sampah.',
                style: TextStyle(fontSize: 16, color: Colors.green[800]),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => navigateToSchedule(context),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Jadwal Pengambilan'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => navigateToArticles(context),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      icon: const Icon(Icons.article),
                      label: const Text('Artikel Menarik'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => navigateToWasteInput(context),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Text(
                  'Buang Sampah Sekarang',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Jenis Sampah:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: wasteTypesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text('Terjadi kesalahan: ${snapshot.error}',
                              style: TextStyle(color: Colors.red[700])));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('Tidak ada data jenis sampah.'));
                    }

                    final wasteTypes = snapshot.data!;
                    return ListView.builder(
                      itemCount: wasteTypes.length,
                      itemBuilder: (context, index) {
                        final wasteType = wasteTypes[index];
                        return Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0)),
                          child: ListTile(
                            leading: Icon(
                              Icons.recycling,
                              color: Colors.green[800],
                            ),
                            title: Text(
                              wasteType['name'] ?? 'Unknown',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[900],
                              ),
                            ),
                            subtitle: Text(
                              'Harga: ${wasteType['price'] ?? 'Tidak tersedia'}/kg',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.green,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                            onTap: () =>
                                navigateToWasteDetails(context, wasteType),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
