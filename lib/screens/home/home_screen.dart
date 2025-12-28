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
      // AppBar only for Lecturer or if needed. StudentDashboard has its own header.
      appBar: _isLecturer 
        ? AppBar(
            title: const Text('Dashboard Dosen'),
            backgroundColor: Colors.orange,
            elevation: 0,
            actions: [
               _buildRoleSwitch(),
               const SizedBox(width: 16),
            ],
          )
        : null, // No AppBar for Student (Uses Custom Header)
      
      // Floating Action Button for Role Switch in Student Mode (Optional, or keep in custom header)
      // For now, let's keep the switch accessible. 
      // Since Student Header has a notification icon, maybe we can overlay the switch or put it there?
      // Let's rely on a temporary invisible way or just add a small floating button if AppBar is gone.
      // actually, let's keep a minimal SafeArea wrapper.
      
      body: _isLecturer
          ? Column(
              children: [
                // Lecturer Header Info
                Container(
                   padding: const EdgeInsets.all(24.0),
                   decoration: const BoxDecoration(
                     color: Colors.orange,
                     borderRadius: BorderRadius.only(
                       bottomLeft: Radius.circular(24),
                       bottomRight: Radius.circular(24),
                     ),
                   ),
                   child: Row(
                     children: [
                       const CircleAvatar(
                         radius: 30,
                         backgroundColor: Colors.white,
                         child: Icon(Icons.person, size: 30, color: Colors.orange),
                       ),
                       const SizedBox(width: 16),
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: const [
                           Text('Halo, Pak Dosen', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                           SizedBox(height: 4),
                           Text('NIP. 19850101', style: TextStyle(color: Colors.white70, fontSize: 14)),
                         ],
                       ),
                     ],
                   ),
                ),
                Expanded(child: const LecturerDashboardWidget()),
              ],
            )
          : Stack(
              children: [
                // Student Dashboard takes full screen
                StudentDashboardWidget(studentId: UserSession().nim),
                
                // Overlay Role Switcher (Temporary for testing)
                Positioned(
                  top: 50,
                  right: 24+48, // Next to notification
                  child: _buildRoleSwitch(),
                )
              ],
            ),
    );
  }

  Widget _buildRoleSwitch() {
    return Switch(
      value: _isLecturer,
      activeColor: Colors.white,
      activeTrackColor: Colors.orangeAccent,
      inactiveThumbColor: Colors.white, // Blue theme
      inactiveTrackColor: Colors.blue.shade200,
      onChanged: (val) {
        setState(() {
          _isLecturer = val;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mode: ${val ? "Dosen" : "Siswa"}')),
        );
      },
    );
  }
}
