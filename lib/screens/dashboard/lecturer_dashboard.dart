import 'package:flutter/material.dart';
import '../../services/report_service.dart';

class LecturerDashboardWidget extends StatelessWidget {
  const LecturerDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TOMBOL BUAT SESI
        InkWell(
          onTap: () {
            _showCreateSessionDialog(context);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade800, Colors.orange.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Buat Sesi Baru',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tap untuk mulai absensi',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        const Text(
          'Rekap Kelas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        
        // MOCK LIST REKAP
        _buildClassItem(context, 'XII RPL 1', '32 Hadir', '2 Alfa'),
        _buildClassItem(context, 'XII TKJ 2', '30 Hadir', '0 Alfa'),
      ],
    );
  }

  Widget _buildClassItem(BuildContext context, String className, String present, String absent) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(className.substring(4, 7), style: TextStyle(color: Colors.blue.shade800, fontSize: 12)),
        ),
        title: Text(className, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(
          children: [
            Icon(Icons.check_circle, size: 14, color: Colors.green),
            const SizedBox(width: 4),
            Text(present, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 12),
            Icon(Icons.cancel, size: 14, color: Colors.red),
            const SizedBox(width: 4),
            Text(absent, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Detail laporan kelas (Coming Soon)')),
          );
        },
      ),
    );
  }

  void _showCreateSessionDialog(BuildContext context) {
    // Controllers for inputs
    final titleController = TextEditingController();
    final startController = TextEditingController(text: "07:00");
    final endController = TextEditingController(text: "09:00");
    final ReportService reportService = ReportService();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Buat Sesi Absensi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Mata Pelajaran (Contoh: Matematika)'),
            ),
            TextField(
              controller: startController,
              decoration: const InputDecoration(labelText: 'Jam Mulai (HH:mm)'),
            ),
            TextField(
              controller: endController,
              decoration: const InputDecoration(labelText: 'Jam Selesai (HH:mm)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              
              // Tampilkan Loading
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Membuat Sesi...')),
              );

              // call API
              final success = await reportService.createSession({
                'title': titleController.text,
                'start_time': startController.text,
                'end_time': endController.text,
                'method': 'face', // Default face
                'class_id': 1, // Default class for demo
              });

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Sesi Berhasil Dibuat!')),
                );
              } else {
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('❌ Gagal Membuat Sesi (Cek Koneksi/API)')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
