import 'package:flutter/material.dart';
import '../dashboard/student_dashboard.dart';
import '../dashboard/lecturer_dashboard.dart';
import '../../utils/user_session.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Toggle Role (Simulasi)
  bool _isLecturer = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_isLecturer ? 'Dashboard Dosen' : 'Smart Presence'),
        backgroundColor: _isLecturer ? Colors.orange : Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          Switch(
            value: _isLecturer,
            activeColor: Colors.white,
            activeTrackColor: Colors.orangeAccent,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.blueAccent,
            onChanged: (val) {
              setState(() {
                _isLecturer = val;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Mode: ${val ? "Dosen" : "Siswa"}')),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header User Info
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: _isLecturer ? Colors.orange : Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person,
                        size: 30,
                        color: _isLecturer
                            ? Colors.orange
                            : Theme.of(context).primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isLecturer 
                          ? 'Halo, Pak Dosen' 
                          : 'Halo, ${UserSession().name}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isLecturer 
                          ? 'NIP. 19850101' 
                          : UserSession().className.isNotEmpty ? UserSession().className : 'Kelas XII RPL 1',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // DASHBOARD CONTENT (Dynamic)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                     // 1. Dashboard Widget (Report / Create Session)
                    _isLecturer
                        ? const LecturerDashboardWidget()
                        : StudentDashboardWidget(studentId: UserSession().nim),
                    
                    const SizedBox(height: 24),
                    
                    // 2. Menu Grid (Hanya relevan untuk Siswa biasanya, atau menu tambahan Dosen)
                    if (!_isLecturer) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Menu Utama", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _buildMenuCard(
                            context,
                            icon: Icons.camera_alt,
                            label: 'Absensi',
                            color: Theme.of(context).primaryColor,
                            route: '/attendance',
                          ),
                          _buildMenuCard(
                            context,
                            icon: Icons.history,
                            label: 'Riwayat',
                            color: Theme.of(context).colorScheme.secondary,
                            route: '/history',
                          ),
                          _buildMenuCard(
                            context,
                            icon: Icons.person,
                            label: 'Profil',
                            color: Colors.green,
                            route: '/profile',
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required String route}) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
