import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // Ganti dengan URL Laravel kamu
  // static const String baseUrl = 'http://10.0.2.2:8000/api'; // untuk emulator
  static const String baseUrl = 'http://192.168.1.250:8000/api'; // untuk device fisik

  Future<dynamic> getData() async {
    final response = await http.get(
      Uri.parse('$baseUrl/endpoint'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
}