import 'package:flutter/material.dart';
import '../../services/report_service.dart';

class ClassDetailScreen extends StatefulWidget {
  final String classId;
  final String className;

  const ClassDetailScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  final _reportService = ReportService();
  List<dynamic> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClassData();
  }

  Future<void> _fetchClassData() async {
    // Ambil data laporan kelas dari API
    final data = await _reportService.getClassReport(widget.classId);
    
    // Jika API kosong/gagal, gunakan Mock Data sementara agar UI terlihat
    if (data.isEmpty) {
       await Future.delayed(const Duration(seconds: 1)); // Simulate delay
       if (mounted) {
         setState(() {
           _students = _getMockStudents(); 
           _isLoading = false;
         });
       }
    } else {
      if (mounted) {
        setState(() {
          _students = data;
          _isLoading = false;
        });
      }
    }
  }

  // Mock Data (Data Palsu untuk Demo)
  List<dynamic> _getMockStudents() {
    return [
      {'name': 'Ahmad Fiqi', 'nim': '2022020100052', 'status': 'Hadir', 'time': '07:15'},
      {'name': 'Budi Santoso', 'nim': '2022020100053', 'status': 'Alpa', 'time': '-'},
      {'name': 'Siti Aminah', 'nim': '2022020100054', 'status': 'Hadir', 'time': '07:05'},
      {'name': 'Rudi Hartono', 'nim': '2022020100055', 'status': 'Izin', 'time': '-'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail ${widget.className}'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchClassData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _students.length,
                itemBuilder: (context, index) {
                  final student = _students[index];
                  final status = student['status'] ?? 'Alpa';
                  Color statusColor = Colors.grey;
                  if (status == 'Hadir') statusColor = Colors.green;
                  if (status == 'Alpa') statusColor = Colors.red;
                  if (status == 'Izin') statusColor = Colors.orange;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        child: Text(
                          (student['name'] ?? 'U')[0],
                          style: TextStyle(color: Colors.blue.shade800),
                        ),
                      ),
                      title: Text(student['name'] ?? 'Mahasiswa', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('NIM: ${student['nim'] ?? '-'}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          if (status == 'Hadir') ...[
                             const SizedBox(height: 4),
                             Text(student['time'] ?? '', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ]
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
