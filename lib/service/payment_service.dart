// payment_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  final String apiUrl =
      'http://localhost:3000/create-transaction'; // Update with your server URL

  Future<Map<String, dynamic>> createTransaction({
    required String orderId,
    required double grossAmount,
    required Map<String, dynamic> customerDetails,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'orderId': orderId,
          'grossAmount': grossAmount,
          'customerDetails': customerDetails,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create transaction');
      }
    } catch (e) {
      throw Exception('Error creating transaction: $e');
    }
  }
}
