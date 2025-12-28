import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../services/auth_service.dart';
import '../../utils/user_session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nimController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    final nim = _nimController.text.trim();

    if (nim.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NIM tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.login(nim);

      if (!mounted) return;

      if (user != null) {
        // Simpan Session
        UserSession().saveSession(
          nim: user['nim'] ?? '',
          name: user['name'] ?? 'Mahasiswa',
          classId: (user['class_id'] ?? 1).toString(), // Default 1 jika null
          className: 'Kelas Siswa', // Idealnya dari API, sementara placeholder
        );

        // Login Berhasil
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text('Selamat datang, ${user['name'] ?? 'Mahasiswa'}!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigasi ke Home
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // NIM tidak ditemukan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('NIM tidak ditemukan. Silakan cek kembali.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login Gagal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkConnection(BuildContext context) async {
    // ... logic cek koneksi (tetap ada untuk debug) ...
     ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Menghubungkan ke server...')),
    );

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.baseUrl), 
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.connectionTimeout);

      if (!context.mounted) return;

      if (response.statusCode == 200 || response.statusCode == 404) {
         // 404 is also ok, meaning server is reachable
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Terhubung ke Backend!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Terhubung dengan status: ${response.statusCode}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Gagal Terhubung: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Smart Presence',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Absen Cerdas',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                  ),
                  const SizedBox(height: 48),

                  // Input NIM (Hanya NIM sesuai request)
                  TextField(
                    controller: _nimController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'NIM Mahasiswa',
                      hintText: 'Masukkan NIM',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tombol Login
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading 
                        ? const SizedBox(
                            height: 20, 
                            width: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : const Text('Masuk'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextButton.icon(
                    onPressed: () => _checkConnection(context),
                    icon: const Icon(Icons.wifi_find),
                    label: const Text('Cek Koneksi Server'),
                    style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
