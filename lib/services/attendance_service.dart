import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AttendanceService {
  // Cek Sesi Aktif
  Future<Map<String, dynamic>?> getActiveSession(String classId) async {
    try {
      // Menggunakan tanggal hari ini (YYYY-MM-DD)
      final now = DateTime.now();
      final date = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      
      final url = Uri.parse('${ApiConfig.baseUrl}/attendance/sessions/?class_id=$classId&date=$date');
      
      final response = await http.get(
        url,
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> sessions = json.decode(response.body);
        if (sessions.isNotEmpty) {
          // Ambil sesi pertama yang ditemukan (asumsi 1 sesi aktif per waktu)
          return sessions.first; 
        }
        return null;
      } else {
        // Jika 404 atau kosong, berarti tidak ada sesi
        return null;
      }
    } catch (e) {
      print("Error checking session: $e");
      return null;
    }
  }

  // Kirim Absensi (Multipart File)
  Future<Map<String, dynamic>> submitAttendance({
    required String nim,
    required String sessionId,
    required String method,
    required String classId,
    String? imagePath, // Optional for IO
    List<int>? imageBytes, // Optional for Web/Memory
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/attendance/');
      var request = http.MultipartRequest('POST', url);
       
      // Headers
      request.headers.addAll({'Accept': 'application/json'});

      // Fields
      request.fields['nim'] = nim;
      request.fields['class_id'] = classId;
      request.fields['session_id'] = sessionId;
      request.fields['method'] = method;
      request.fields['timestamp'] = DateTime.now().toIso8601String();

      // File handling (Supports both Path (Mobile) and Bytes (Web/Simulated))
      if (imageBytes != null && imageBytes.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file', 
            imageBytes,
            filename: 'attendance_face.jpg',
          )
        );
      } else if (imagePath != null && imagePath.isNotEmpty) {
         var pic = await http.MultipartFile.fromPath('file', imagePath);
         request.files.add(pic);
      }

      final streamedResponse = await request.send().timeout(ApiConfig.connectionTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': response.body, // Bisa diparsing lebih lanjut
          'statusCode': response.statusCode
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi Gagal: $e',
      };
    }
  }
}
