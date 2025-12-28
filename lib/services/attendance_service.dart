import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'deleted_session_manager.dart';

class AttendanceService {
  // Cek Sesi Aktif (Single - Deprecated if multiple sessions allowed, but kept for compatibility)
  Future<Map<String, dynamic>?> getActiveSession(String classId) async {
    final sessions = await getTodaySessions(classId);
    if (sessions.isNotEmpty) return sessions.first;
    return null;
  }

  // Ambil Semua Sesi Hari Ini
  Future<List<dynamic>> getTodaySessions(String classId) async {
    try {
      final now = DateTime.now();
      final date = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      
      final url = Uri.parse('${ApiConfig.baseUrl}/attendance/sessions/?class_id=$classId&date=$date');
      
      final response = await http.get(
        url,
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> rawSessions = json.decode(response.body);
        print("RAW SESSION RESPONSE: $rawSessions"); // Debug

        final deletedManager = DeletedSessionManager();

        // Normalize Data & Filter Deleted
        return rawSessions.where((s) {
          if (s is Map<String, dynamic>) {
            final sId = s['id']?.toString() ?? s['session_id']?.toString() ?? s['sessionId']?.toString();
            if (deletedManager.contains(sId)) {
               print("Skipping deleted session: $sId");
               return false; 
            }
          }
          return true;
        }).map((s) {
          if (s is Map<String, dynamic>) {
            // Ensure title exists
            if (s['title'] == null) {
               s['title'] = s['name'] ?? s['subject'] ?? 'Sesi Tanpa Judul';
            }
            // Ensure class_id exists
            if (s['class_id'] == null) {
              s['class_id'] = s['classId'];
            }
            return s;
          }
          return s;
        }).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching sessions: $e");
      return [];
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
  // Ambil Riwayat Absensi (Mock)
  Future<List<Map<String, dynamic>>> getAttendanceHistory(String studentId) async {
    // Simulasi delay API
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock Data dengan detail lengkap
    return [
      {
        'date': 'Jumat, 27 Des 2024',
        'time': '07:05',
        'status': 'Hadir',
        'subject': 'Matematika Wajib',
        'class_name': 'XII RPL 1'
      },
      {
        'date': 'Kamis, 26 Des 2024',
        'time': '07:00',
        'status': 'Hadir',
        'subject': 'Bahasa Indonesia',
        'class_name': 'XII RPL 1'
      },
      {
        'date': 'Rabu, 25 Des 2024',
        'time': '-',
        'status': 'Hari Libur',
        'subject': '-',
        'class_name': '-'
      },
      {
        'date': 'Selasa, 24 Des 2024',
        'time': '07:15',
        'status': 'Terlambat',
        'subject': 'Fisika',
        'class_name': 'XII RPL 1'
      },
       {
        'date': 'Senin, 23 Des 2024',
        'time': '07:02',
        'status': 'Hadir',
        'subject': 'Pemrograman Web',
        'class_name': 'XII RPL 1'
      },
    ];
  }

  // Ambil Riwayat Sesi (Lecturer)
  Future<List<Map<String, dynamic>>> getLecturerHistory() async {
    // Simulasi delay API
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock Data Sesi yang sudah selesai/dihapus
    return [
      {
        'date': 'Minggu, 29 Des 2024',
        'time': '07:00 - 09:00',
        'status': 'Selesai',
        'subject': 'Matematika (Pak Fiqi)',
        'class_name': 'XII RPL 1'
      },
      {
        'date': 'Sabtu, 28 Des 2024',
        'time': '10:00 - 12:00',
        'status': 'Dihapus', // Sesi yang dihapus user
        'subject': 'Bahasa Indonesia',
        'class_name': 'XII TKJ 2'
      },
       {
        'date': 'Sabtu, 28 Des 2024',
        'time': '07:30 - 09:30',
        'status': 'Selesai', 
        'subject': 'Pemrograman Mobile',
        'class_name': 'XII RPL 1'
      },
    ];
  }
}
