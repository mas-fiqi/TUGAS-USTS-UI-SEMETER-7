import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthService {
  // Login dengan NIM (Mock Login by fetching student list)
  Future<Map<String, dynamic>?> login(String nim) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/students');
      
      final response = await http.get(
        url,
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        // Asumsi response adalah List<Student>
        final List<dynamic> students = json.decode(response.body);
        
        // Cari mahasiswa dengan NIM yang sesuai
        try {
          final student = students.firstWhere(
            (s) => s['nim'] == nim || s['nid'] == nim, // Cek 'nim' atau 'nid' jaga-jaga
            orElse: () => null,
          );
          return student;
        } catch (e) {
          // Fallback jika struktur data berbeda, print error untuk debug
          print('Error parsing student list: $e');
          return null;
        }
      } else {
        throw Exception('Gagal memuat data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kesalahan koneksi: $e');
    }
  }
}
