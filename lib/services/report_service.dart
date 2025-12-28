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
  Future<bool> createSession(Map<String, dynamic> sessionData) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/attendance/sessions/');
      final response = await http.post(
        url,
        headers: ApiConfig.headers, // Ensure Content-Type: application/json
        body: json.encode(sessionData),
      ).timeout(ApiConfig.connectionTimeout);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error creating session: $e");
      return false;
    }
  }
}
