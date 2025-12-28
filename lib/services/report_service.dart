import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ReportService {
  // Get Student Report (Personal)
  Future<Map<String, dynamic>?> getStudentReport(String studentId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/reports/student/$studentId');
      final response = await http.get(url, headers: ApiConfig.headers).timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print("Error fetching student report: $e");
      return null;
    }
  }

  // Get Class Report (Lecturer View)
  Future<List<dynamic>> getClassReport(String classId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/reports/class/$classId');
      final response = await http.get(url, headers: ApiConfig.headers).timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print("Error fetching class report: $e");
      return [];
    }
  }

  // Create Session (Lecturer Action) - Placing here or AttendanceService is fine
  // Create Session (Lecturer Action)
  Future<Map<String, dynamic>> createSession(Map<String, dynamic> sessionData) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/attendance/sessions/'); 
      print("Creating session at $url with body: $sessionData");

      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: json.encode(sessionData),
      ).timeout(ApiConfig.connectionTimeout);

      print("Create Session Response: ${response.statusCode} ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Sesi berhasil dibuat'};
      } else {
        return {'success': false, 'message': 'Server Error: ${response.statusCode} - ${response.body}'};
      }
    } catch (e) {
      print("Error creating session: $e");
      return {'success': false, 'message': 'Connection Error: $e'};
    }
  }


  // Delete Session (Lecturer Action)
  Future<Map<String, dynamic>> deleteSession(int sessionId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/attendance/sessions/$sessionId'); 
      final response = await http.delete(
        url,
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true, 'message': 'Sesi berhasil dihapus'};
      } else {
        return {'success': false, 'message': 'Gagal menghapus: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
