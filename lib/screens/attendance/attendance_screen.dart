import 'dart:typed_data'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/attendance_service.dart';
import '../../utils/user_session.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _attendanceService = AttendanceService();
  
  Map<String, dynamic>? _activeSession;
  Uint8List? _photoBytes; 
  
  bool _isLoading = false;
  String _loadingMessage = "Memproses..."; // Detailed loading message
  bool _isCheckingSession = true;
  String? _statusMessage; 

  // Get data from Session
  String get _nim => UserSession().nim;
  String get _classId => UserSession().classId; 

  @override
  void initState() {
    super.initState();
    _checkActiveSession();
  }

  Future<void> _checkActiveSession() async {
    setState(() => _isCheckingSession = true);
    try {
      // Use defaults if session is empty (prevent crash)
      final classIdToCheck = _classId.isEmpty ? '1' : _classId; 
      final session = await _attendanceService.getActiveSession(classIdToCheck);
      setState(() {
        _activeSession = session;
        if (session == null) {
          _statusMessage = "Tidak ada sesi absensi aktif untuk kelas ini.";
        }
      });
    } catch (e) {
      if (mounted) setState(() => _statusMessage = "Gagal memuat sesi: $e");
    } finally {
      if (mounted) setState(() => _isCheckingSession = false);
    }
  }

  // 2. Ambil Foto (HYBRID: Real Camera for Mobile, Sim for Web)
  Future<void> _takePhoto() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = "Membuka Kamera...";
    });

    try {
      // Cek apakah di Web (Simulasi) atau Mobile (Real Camera)
      // Sederhananya try-catch ImagePicker, jika gagal fallback ke simulasi
      
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 600, 
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.front,
      );

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _photoBytes = bytes;
          _loadingMessage = "Memproses Foto...";
        });
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('📸 Foto Berhasil Diambil!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Pengambilan foto dibatalkan')),
        );
      }

    } catch (e) {
       // Fallback jika error (misal di Web/Emulator tanpa kamera)
       print("Camera Error (Falling back to Sim): $e");
       
       await Future.delayed(const Duration(seconds: 1));
       // Use a tiny transparent GIF bytes so it doesn't crash MemoryImage if we strictly check length
       // But better to just set a flag or use dummy bytes that we catch in UI
       final dummyBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]); 
       
       setState(() {
         _photoBytes = dummyBytes;
         _loadingMessage = "Memproses Foto (Simulasi)...";
       });
       
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal kamera native: $e. Menggunakan Simulasi.')),
      );
    } finally {
        if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitAttendance() async {
    if (_photoBytes == null || _activeSession == null) return;

    setState(() {
      _isLoading = true;
      _loadingMessage = "Mengirim Data...";
    });

    try {
      // Simulate "Validasi AI" step for UX
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() => _loadingMessage = "Validasi Wajah dengan AI...");
      
      final result = await _attendanceService.submitAttendance(
        nim: _nim,
        classId: _classId.isNotEmpty ? _classId : '1',
        sessionId: _activeSession!['id'].toString(), 
        method: 'face', 
        imageBytes: _photoBytes,
      );

      if (!mounted) return;

      if (result['success']) {
        final score = result['data']['confidence_score'] ?? 0.0;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            title: const Text('Absensi Berhasil!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Status: ${result['data']['status'] ?? 'Hadir'}'),
                const SizedBox(height: 8),
                Text('Skor Kecocokan: ${(score * 100).toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('(Wajah valid)', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              )
            ],
          ),
        );
      } else {
        // Detailed Error Handling
        final msg = result['message'] ?? 'Gagal absen';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(msg)),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Absensi Kehadiran')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: _isCheckingSession
                ? const Center(child: CircularProgressIndicator())
                : _activeSession == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              _statusMessage ?? 'Sesi tidak tersedia',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _checkActiveSession,
                              child: const Text('Coba Lagi'),
                            )
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // 1. Camera Preview
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey),
                                    // Web Safe Image Preview
                                    image: (_photoBytes != null && _photoBytes!.length > 100)
                                        ? DecorationImage(
                                            image: MemoryImage(_photoBytes!), 
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: (_photoBytes == null || _photoBytes!.length <= 100)
                                      ? Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.camera_alt,
                                                size: 64, color: Colors.grey[600]),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Pastikan wajah terlihat jelas',
                                              style: TextStyle(color: Colors.grey[600]),
                                            ),
                                          ],
                                        )
                                      : null,
                                ),
                                
                                // 2. Face Overlay / Frame (Visual Guide)
                                IgnorePointer(
                                  child: Container(
                                    width: 250,
                                    height: 300,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                                      borderRadius: BorderRadius.circular(150), // Oval shape
                                    ),
                                    child: Align(
                                        alignment: Alignment.topCenter,
                                        child: Padding(
                                            padding: const EdgeInsets.only(top: 16),
                                            child: Text("Area Wajah", style: TextStyle(color: Colors.white.withOpacity(0.7)))
                                        )
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          Text(
                            'Sesi: ${_activeSession?['title'] ?? 'Absensi Harian'}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Text("Metode: Face Recognition", style: TextStyle(color: Colors.grey[600])),
                          
                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _takePhoto,
                              icon: const Icon(Icons.camera),
                              label: Text(_photoBytes == null ? 'Ambil Foto' : 'Foto Ulang'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: (_photoBytes != null && !_isLoading)
                                  ? _submitAttendance
                                  : null,
                              icon: const Icon(Icons.send),
                              label: const Text('Kirim Absensi'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
          
          // 3. Full Screen Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      _loadingMessage,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
