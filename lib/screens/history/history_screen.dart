import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data
    // TODO: Replace with Real Data from Backend
    // 1. Call AttendanceService.getHistory()
    // 2. Use FutureBuilder or StreamBuilder to handle async data
    // 3. Map JSON response to List<Map> or Models
    final List<Map<String, String>> historyData = [
      {'date': 'Jumat, 27 Des 2024', 'time': '07:05', 'status': 'Hadir'},
      {'date': 'Kamis, 26 Des 2024', 'time': '07:00', 'status': 'Hadir'},
      {'date': 'Rabu, 25 Des 2024', 'time': '-', 'status': 'Hari Libur'},
      {'date': 'Selasa, 24 Des 2024', 'time': '07:15', 'status': 'Terlambat'},
      {'date': 'Senin, 23 Des 2024', 'time': '07:02', 'status': 'Hadir'},
      {'date': 'Jumat, 20 Des 2024', 'time': '-', 'status': 'Ditolak'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Absensi')),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: historyData.length,
        itemBuilder: (context, index) {
          final data = historyData[index];
          final Color statusColor;
          
          switch (data['status']) {
            case 'Hadir':
              statusColor = Theme.of(context).colorScheme.primary; // Or explicit green if semantic
              break;
            case 'Terlambat':
              statusColor = Theme.of(context).colorScheme.secondary; // Or Orange
              break;
            case 'Ditolak':
              statusColor = Theme.of(context).colorScheme.error;
              break;
            default:
              statusColor = Colors.grey;
          }

          // Use static colors for semantic status for better UX (Traffic light)
          final Color semanticColor;
           switch (data['status']) {
            case 'Hadir':
              semanticColor = Colors.green[700]!;
              break;
            case 'Terlambat':
              semanticColor = Colors.orange[800]!;
              break;
            case 'Ditolak':
              semanticColor = Theme.of(context).colorScheme.error;
              break;
            default:
              semanticColor = Colors.grey;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['date']!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Jam Masuk: ${data['time']}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: semanticColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: semanticColor),
                    ),
                    child: Text(
                      data['status']!,
                      style: TextStyle(
                        color: semanticColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
