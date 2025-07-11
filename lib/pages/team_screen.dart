import 'package:flutter/material.dart';
import '../service/firestore.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TeamScreenState createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<Map<String, dynamic>>> teamFuture;
  final String placeholderImageUrl = 'https://avatar.iran.liara.run/public/45';

  @override
  void initState() {
    super.initState();
    teamFuture = _firestoreService.getKelompok();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Team Kami',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.green[700]?.withOpacity(0.95),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green[400]!,
                    Colors.green[200]!,
                    Colors.green[50]!,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.3, 0.9],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 24.0),
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: teamFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Colors.green[700],
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Memuat data tim...',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline,
                                    color: Colors.red[700], size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  'Terjadi kesalahan:',
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${snapshot.error}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.group_off_outlined,
                                size: 64,
                                color: Colors.green[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tidak ada data anggota kelompok.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final teamMembers = snapshot.data!;
                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: teamMembers.length,
                        itemBuilder: (context, index) {
                          final member = teamMembers[index];
                          return Card(
                            elevation: 12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                            shadowColor: Colors.green.withOpacity(0.5),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24.0),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.green[50]!,
                                    Colors.green[100]!,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: const [0.0, 0.7, 1.0],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.green.withOpacity(0.3),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          member['imageUrl'] ??
                                              placeholderImageUrl,
                                        ),
                                        radius: 52,
                                        backgroundColor: Colors.green[100],
                                        onBackgroundImageError: (_, __) {
                                          setState(() {
                                            member['imageUrl'] =
                                                placeholderImageUrl;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      member['name'] ?? 'Unknown',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.green[900],
                                        letterSpacing: 0.5,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 3.0,
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            offset: const Offset(1.0, 1.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.green[700]?.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.green[300]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        'NPM: ${member['npm'] ?? 'Tidak tersedia'}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Colors.green[700],
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.green[700],
            child: const Center(
              child: Text(
                'Aplikasi ini dibuat untuk memenuhi tugas pengembangan aplikasi piranti bergerak',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
