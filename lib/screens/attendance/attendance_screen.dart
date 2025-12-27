import 'package:flutter/material.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool _isPhotoTaken = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Absensi Kehadiran')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Camera Preview / Placeholder Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isPhotoTaken ? Icons.check_circle : Icons.camera_alt,
                      size: 64,
                      color: _isPhotoTaken ? Theme.of(context).colorScheme.primary : Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isPhotoTaken
                          ? 'Foto Terambil'
                          : 'Preview Kamera',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isPhotoTaken = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cekrek! Foto diambil (Simulasi)')),
                  );
                },
                icon: const Icon(Icons.camera),
                label: const Text('Ambil Foto'),
                // Style handled by Theme default, but overriding padding/color if needed
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isPhotoTaken
                    ? () {
                        // TODO: Implement Backend Attendance Logic Here
                        // 1. Prepare data (Photo file, Location, timestamp)
                        // 2. Call AttendanceService.submit(photo, location)
                        // 3. Handle success -> Show success message & navigate
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Absensi berhasil dikirim! (Simulasi)'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        // Optional: Navigate back after delay
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) Navigator.pop(context);
                        });
                      }
                    : null, // Disabled if photo not taken
                icon: const Icon(Icons.send),
                label: const Text('Kirim Absensi'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Specific semantic color for success action
                    disabledBackgroundColor: Colors.grey[300]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
