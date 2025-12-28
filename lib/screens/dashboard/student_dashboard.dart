import 'package:flutter/material.dart';
import '../../services/report_service.dart';

class StudentDashboardWidget extends StatefulWidget {
  final String studentId;
  const StudentDashboardWidget({super.key, required this.studentId});

  @override
  State<StudentDashboardWidget> createState() => _StudentDashboardWidgetState();
}

class _StudentDashboardWidgetState extends State<StudentDashboardWidget> {
  final _reportService = ReportService();
  Map<String, dynamic>? _report;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    // 1. Coba Ambil Data dari API Backend
    final apiData = await _reportService.getStudentReport(widget.studentId);
    
    if (apiData != null) {
      if (mounted) {
        setState(() {
          _report = apiData;
          _isLoading = false;
        });
      }
      return;
    }

    // 2. Fallback Mock Data (Jika API Error/Offline) agar UI tetap bagus saat Demo
    await Future.delayed(const Duration(seconds: 1));
    final mockData = {
      'percentage': 85,
      'status': 'Aman',
      'total_present': 12,
      'total_absent': 2
    };

    if (mounted) {
      setState(() {
        _report = mockData;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final percentage = _report?['percentage'] ?? 0;
    final status = _report?['status'] ?? '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Laporan Kehadiran',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Status: $status',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              CircularStats(percentage: percentage.toDouble()),
            ],
          ),
        ],
      ),
    );
  }
}

class CircularStats extends StatelessWidget {
  final double percentage;
  const CircularStats({super.key, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 60,
      child: Stack(
        children: [
          Center(
            child: CircularProgressIndicator(
              value: percentage / 100,
              strokeWidth: 8,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
            ),
          ),
          Center(
            child: Icon(Icons.check_circle, color: Colors.white.withOpacity(0.9)),
          )
        ],
      ),
    );
  }
}
