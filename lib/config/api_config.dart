class ApiConfig {
  // =======================================================================
  // KONFIGURASI UTAMA (Pilih Salah Satu URL)
  // =======================================================================
  
  // [OPSI 1] Emulator Android
  // Gunakan ini jika running di Emulator Android Studio / VS Code
  // static const String baseUrl = "http://10.0.2.2:8000";

  // [OPSI 2] Device Fisik / HP (USB Debugging / WiFi)
  // Gunakan ini jika running di HP asli. PENTING:
  // 1. HP dan Laptop wajib di WiFi yang sama.
  // 2. Ganti IP di bawah dengan IP Laptop Anda (cek cmd -> ipconfig).
  static const String baseUrl = "http://192.168.100.200:8000"; 
  
  // =======================================================================
  
  // Header Standar
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Timeout settings
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration connectionTimeout = Duration(seconds: 15);
}
