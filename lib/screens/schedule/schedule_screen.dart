import 'package:flutter/material.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data Jadwal
    final List<Map<String, String>> schedules = [
      {
        'subject': 'Matematika Wajib',
        'teacher': 'Pak Fiqi',
        'time': '07:00 - 09:00',
        'day': 'Senin',
      },
      {
        'subject': 'Bahasa Indonesia',
        'teacher': 'Bu Siti',
        'time': '09:00 - 11:00',
        'day': 'Senin',
      },
      {
        'subject': 'Pemrograman Mobile',
        'teacher': 'Pak Eko',
        'time': '07:00 - 12:00',
        'day': 'Selasa',
      },
       {
        'subject': 'Basis Data',
        'teacher': 'Bu Ani',
        'time': '08:00 - 10:00',
        'day': 'Rabu',
      },
       {
        'subject': 'PKN',
        'teacher': 'Pak Budi',
        'time': '10:00 - 12:00',
        'day': 'Kamis',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal Pelajaran')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final item = schedules[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_today, color: Colors.blue),
              ),
              title: Text(item['subject']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${item['teacher']} • ${item['day']}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(item['time']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          );
        },
      ),
    );
  }
}
