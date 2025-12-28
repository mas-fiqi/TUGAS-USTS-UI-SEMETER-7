import 'package:flutter/material.dart';
import '../../services/attendance_service.dart';
import '../../utils/user_session.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _attendanceService = AttendanceService();
  List<Map<String, dynamic>> _historyData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final session = UserSession();
    List<Map<String, dynamic>> data;
    
    if (session.role == 'lecturer') {
      data = await _attendanceService.getLecturerHistory();
    } else {
      data = await _attendanceService.getAttendanceHistory(session.nim);
    }

    if (mounted) {
      setState(() {
        _historyData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Absensi')),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _historyData.length,
        itemBuilder: (context, index) {
          final data = _historyData[index];
          final Color statusColor;
          
          switch (data['status']) {
            case 'Hadir':
              statusColor = Colors.green[700]!;
              break;
            case 'Terlambat':
              statusColor = Colors.orange[800]!;
              break;
            case 'Ditolak':
              statusColor = Theme.of(context).colorScheme.error;
              break;
            case 'Selesai':
              statusColor = Colors.blue[700]!;
              break;
            case 'Dihapus':
               statusColor = Colors.grey[700]!;
               break;
            default:
              statusColor = Colors.grey;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                   // Header: Tanggal & Status
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data['date']!,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withOpacity(0.5)),
                        ),
                        child: Text(
                          data['status']!,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                   ),
                   const Divider(height: 24),
                   
                   // Details Grid
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       _buildInfoColumn('Jam', data['time']!),
                       _buildInfoColumn('Kelas', data['class_name'] ?? '-'),
                       _buildInfoColumn('Mapel', data['subject'] ?? '-'),
                     ],
                   )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
