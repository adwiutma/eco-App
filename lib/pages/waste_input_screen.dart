// lib/pages/waste_input_screen.dart
// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sampah/pages/succes_screen.dart';
import '../service/firestore.dart';

class WasteInputScreen extends StatefulWidget {
  final String userId;
  final String userName; // Tambahkan parameter userName
  const WasteInputScreen(
      {super.key, required this.userId, required this.userName});

  @override
  _WasteInputScreenState createState() => _WasteInputScreenState();
}

class _WasteInputScreenState extends State<WasteInputScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  late Future<List<Map<String, dynamic>>> wasteTypesFuture;

  String? selectedWasteType;
  double selectedWastePrice = 0.0;
  double wasteWeight = 0.0;
  double totalPrice = 0.0;
  bool isProcessingPayment = false;
  String? qrCodeUrl;
  String? currentOrderId;
  String paymentStatus = "Belum dibayar";
  Timer? _timer;
  int _remainingTime = 300; // 5 minutes in seconds
  final TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    wasteTypesFuture = _firestoreService.getWasteTypes();
    _weightController.addListener(_updateTotalPrice);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _updateTotalPrice() {
    setState(() {
      wasteWeight = double.tryParse(_weightController.text) ?? 0.0;
      totalPrice = selectedWastePrice * wasteWeight;
    });
  }

  void _updateSelectedWasteType(String? value, double price) {
    setState(() {
      selectedWasteType = value;
      selectedWastePrice = price;
      totalPrice = selectedWastePrice * wasteWeight;
    });
  }

  void startTimer() {
    _remainingTime = 300; // reset to 5 minutes
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> proceedToPayment() async {
    if (selectedWasteType == null || wasteWeight <= 0 || totalPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap masukkan data yang valid.')),
      );
      return;
    }

    setState(() {
      isProcessingPayment = true;
      qrCodeUrl = null;
      paymentStatus = "Belum dibayar";
    });

    try {
      const apiUrl = 'http://10.0.2.2:3000/create-qris-payment';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': totalPrice}),
      );

      if (response.statusCode == 200) {
        final payment = jsonDecode(response.body);
        setState(() {
          qrCodeUrl = payment['qrisUrl'];
          currentOrderId = payment['orderId'];
        });
        print("qris url : $qrCodeUrl");
        startTimer(); // Start the timer when the QR code is generated
      } else {
        throw Exception('Gagal membuat pembayaran QRIS.');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    } finally {
      setState(() {
        isProcessingPayment = false;
      });
    }
  }

  Future<void> regenerateQrCode() async {
    await proceedToPayment();
  }

  Future<void> checkPaymentStatus() async {
    if (currentOrderId == null) return;

    try {
      final apiUrl = 'http://10.0.2.2:3000/payment-status/$currentOrderId';
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final status = jsonDecode(response.body);
        setState(() {
          paymentStatus = status['transaction_status'] == 'settlement'
              ? "Sudah dibayar"
              : "Belum dibayar";
        });

        if (paymentStatus == "Sudah dibayar") {
          await _firestoreService.addWasteEntry({
            'userId': widget.userId, // Tambahkan userId
            'userName': widget.userName, // Tambahkan userName
            'wasteType': selectedWasteType,
            'weight': wasteWeight,
            'price': totalPrice,
            'timestamp': DateTime.now(),
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SuccessScreen(
                  userName: widget.userName,
                  wasteType: selectedWasteType!,
                  weight: wasteWeight,
                  price: totalPrice,
                  timestamp: DateTime.now(),
                  userId: widget.userId),
            ),
          );
        }
      } else {
        throw Exception('Gagal memeriksa status pembayaran.');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    }
  }

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Input Sampah',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.green[700],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[700]!, Colors.green[50]!],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Hero Section
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/buang.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: const Text(
                        'Selamat datang di halaman input sampah! Di sini Anda dapat memilih jenis sampah, memasukkan berat, dan melakukan pembayaran melalui QRIS.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Input Section
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Jenis Sampah',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green[200]!),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: wasteTypesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('Tidak ada data jenis sampah.'),
                            );
                          }

                          return DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              border: InputBorder.none,
                            ),
                            value: selectedWasteType,
                            hint: const Text('Pilih jenis sampah'),
                            isExpanded: true,
                            items: snapshot.data!.map((type) {
                              return DropdownMenuItem<String>(
                                value: type['name'],
                                child: Text(type['name']),
                                onTap: () {
                                  _updateSelectedWasteType(
                                    type['name'],
                                    type['price'].toDouble(),
                                  );
                                },
                              );
                            }).toList(),
                            onChanged: (value) {
                              // The _updateSelectedWasteType will be called from onTap
                              setState(() {
                                selectedWasteType = value;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Berat Sampah (kg)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.green[50],
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.green[200]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.green[200]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              BorderSide(color: Colors.green[400]!, width: 2),
                        ),
                        hintText: 'Masukkan berat',
                        hintStyle: TextStyle(color: Colors.green[300]),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Harga:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                          Text(
                            'Rp ${totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (selectedWasteType != null &&
                                wasteWeight > 0 &&
                                !isProcessingPayment)
                            ? proceedToPayment
                            : null,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green[600],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 2,
                        ),
                        child: isProcessingPayment
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Bayar Sekarang',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              // QR Code Section
              if (qrCodeUrl != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Scan QR Code untuk Pembayaran',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Image.network(
                          qrCodeUrl!,
                          height: 200,
                          width: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: _remainingTime > 60
                              ? Colors.green[50]
                              : Colors.red[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Waktu tersisa: ${formatTime(_remainingTime)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                _remainingTime > 60 ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _remainingTime == 0
                              ? regenerateQrCode
                              : checkPaymentStatus,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: _remainingTime == 0
                                ? Colors.green[800]
                                : Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            _remainingTime == 0
                                ? 'Generate Ulang QR Code'
                                : 'Cek Status Pembayaran',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Payment Status
              if (paymentStatus != "Belum dibayar")
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: paymentStatus == "Sudah dibayar"
                          ? Colors.green
                          : Colors.orange,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        paymentStatus == "Sudah dibayar"
                            ? Icons.check_circle
                            : Icons.info,
                        color: paymentStatus == "Sudah dibayar"
                            ? Colors.green
                            : Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Status Pembayaran: $paymentStatus',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: paymentStatus == "Sudah dibayar"
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
