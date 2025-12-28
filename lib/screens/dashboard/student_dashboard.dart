import 'package:flutter/material.dart';
import '../../services/report_service.dart';
import '../../services/attendance_service.dart';
import '../../utils/user_session.dart';
import '../schedule/schedule_screen.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';
import 'dart:async';

class StudentDashboardWidget extends StatefulWidget {
  final String studentId;
  const StudentDashboardWidget({super.key, required this.studentId});

  @override
  State<StudentDashboardWidget> createState() => _StudentDashboardWidgetState();
}



class _StudentDashboardWidgetState extends State<StudentDashboardWidget> {
  final _reportService = ReportService();
  final _attendanceService = AttendanceService();
  
  Map<String, dynamic>? _report;
  List<dynamic> _todaySessions = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchReport();
    // Auto-refresh every 5 seconds to sync deletions/expiry
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchReport(silent: true));
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Helper to check if session is expired
  bool _isSessionActive(Map<String, dynamic> session) {
    // 1. Check logical status if available
    if (session['isActive'] == false) return false;

    // 2. Check Time Expiry
    try {
      final endTimeStr = session['end_time'] ?? session['endTime'];
      if (endTimeStr == null) return true; // Keep if no time limit

      final parts = endTimeStr.split(':');
      final endHour = int.parse(parts[0]);
      final endMinute = int.parse(parts[1]);
      
      final now = DateTime.now();
      final endDateTime = DateTime(now.year, now.month, now.day, endHour, endMinute);
      
      return now.isBefore(endDateTime);
    } catch (e) {
      return true; // Keep if parsing fails
    }
  }

  Future<void> _fetchReport({bool silent = false}) async {
    // 1. Ambil Laporan
    final apiData = await _reportService.getStudentReport(widget.studentId);
    
    // 2. Ambil Sesi Hari Ini
    final classId = UserSession().classId.isNotEmpty ? UserSession().classId : '1'; 
    final sessions = await _attendanceService.getTodaySessions(classId);

    if (mounted) {
      setState(() {
        _report = apiData ?? {
           'percentage': 0,
           'status': 'Belum Ada Data',
           'total_present': 0,
           'total_absent': 0
        };
        
       // Sort sessions: Active first
        _todaySessions = sessions.where((s) {
            if (s is Map<String, dynamic>) {
               return _isSessionActive(s);
            }
            return true;
        }).toList();

        _todaySessions.sort((a, b) {
           final activeA = _isSessionActive(a) ? 1 : 0;
           final activeB = _isSessionActive(b) ? 1 : 0;
           return activeB.compareTo(activeA); // Descending
        });

        _isLoading = false;
        
        // Debug Feedback only for manual refresh
        if (!silent) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Refreshed! Class ID: $classId | Active: ${_todaySessions.length}"),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final percentage = _report?['percentage'] ?? 0;
    final status = _report?['status'] ?? '-';
    // Mock user name/class
    final userName = "Siswa Teladan"; 
    final userClass = "XII RPL 1";
    
    // Sessions are already sorted in _fetchReport

    // Get "Most Relevant" Session (Active only)
    Map<String, dynamic>? activeSession;
    if (_todaySessions.isNotEmpty && _isSessionActive(_todaySessions.first)) {
      activeSession = _todaySessions.first;
    }

    return Container(
      color: Colors.grey.shade50,
      child: RefreshIndicator(
        onRefresh: _fetchReport,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. COMPACT HEADER
              Container(
                padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.blue.shade100,
                      child: Text("ST", style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(userClass, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {},
                    )
                  ],
                ),
              ),

              const SizedBox(height: 24),
              
              Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 24),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     // 2. KARTU ABSEN SEKARANG (CTA UTAMA)
                     if (activeSession != null)
                       _buildMainActionCard(activeSession)
                     else 
                       _buildEmptyStateCard(),

                     const SizedBox(height: 24),

                     // 3. STATISTIK KEHADIRAN
                     _buildReportCard(percentage, status),

                     const SizedBox(height: 24),
                     
                     // 4. MENU UTAMA (GRID)
                     const Text("Menu Utama", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                     const SizedBox(height: 12),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         _buildMenuButton(context, "Jadwal", Icons.calendar_today, Colors.orange, const ScheduleScreen()),
                         _buildMenuButton(context, "Riwayat", Icons.history, Colors.purple, const HistoryScreen()),
                         _buildMenuButton(context, "Profil", Icons.person, Colors.blue, const ProfileScreen()),
                       ],
                     ),

                     const SizedBox(height: 24),
                     
                     // 5. STRUKTUR PENGAJAR (Horizontal List)
                     const Text("Struktur Pengajar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                     const SizedBox(height: 12),
                     SizedBox(
                       height: 90, // Reduced height for compactness
                       child: ListView(
                         scrollDirection: Axis.horizontal,
                         clipBehavior: Clip.none,
                         children: [
                           _buildTeacherCard("Pak Fiqi", "Matematika"),
                           _buildTeacherCard("Bu Siti Aminah", "Bahasa Indonesia"),
                           _buildTeacherCard("Pak Eko Kurniawan", "Mobile Dev"),
                           _buildTeacherCard("Bu Ani Lestari", "Basis Data"),
                           _buildTeacherCard("Dr. Budi Santoso", "Kepala Sekolah"),
                         ],
                       ),
                     ),
                     const SizedBox(height: 40),
                   ],
                 ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainActionCard(Map<String, dynamic> session) {
     return Container(
       width: double.infinity,
       padding: const EdgeInsets.all(20),
       decoration: BoxDecoration(
         gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade500]),
         borderRadius: BorderRadius.circular(20),
         boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
       ),
       child: Column(
         children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const Text("Kelas Sedang Aktif", style: TextStyle(color: Colors.white70, fontSize: 12)),
                   const SizedBox(height: 4),
                   Text(session['title'] ?? 'Sesi', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                   Text("${session['start_time']} - ${session['end_time']}", style: const TextStyle(color: Colors.white, fontSize: 14)),
                 ],
               ),
               const Icon(Icons.timer, color: Colors.white, size: 32),
             ],
           ),
           const SizedBox(height: 16),
           SizedBox(
             width: double.infinity,
             child: ElevatedButton(
               onPressed: () {
                  Navigator.pushNamed(context, '/attendance', arguments: session);
               },
               style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.white,
                 foregroundColor: Colors.blue.shade700,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                 padding: const EdgeInsets.symmetric(vertical: 12),
               ),
               child: const Text("Absen Sekarang", style: TextStyle(fontWeight: FontWeight.bold)),
             ),
           )
         ],
       ),
     );
  }

    Widget _buildEmptyStateCard() {
     return Container(
       width: double.infinity,
       padding: const EdgeInsets.all(20),
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(20),
         border: Border.all(color: Colors.grey.shade200),
       ),
       child: Row(
         children: [
           Container(
             padding: const EdgeInsets.all(12),
             decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
             child: Icon(Icons.verified_user_outlined, color: Colors.grey.shade400),
           ),
           const SizedBox(width: 16),
           const Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text("Tidak ada kelas aktif", style: TextStyle(fontWeight: FontWeight.bold)),
                 Text("Santai sejenak!", style: TextStyle(color: Colors.grey, fontSize: 12)),
               ],
             ),
           )
         ],
       ),
     );
  }

  Widget _buildReportCard(dynamic percentage, dynamic status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text("Kehadiranmu", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                 const SizedBox(height: 4),
                 Text("$percentage%", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                 Text(status, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
               ],
             ),
           ),
           const SizedBox(width: 16),
           CircularStats(percentage: (percentage as num).toDouble()),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String label, IconData icon, Color color, Widget page) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
          ),
          child: Column(
             children: [
               Icon(icon, color: color, size: 28),
               const SizedBox(height: 8),
               Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
             ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherCard(String name, String subject) {
    return Container(
      width: 200, // Wide Enough for Name
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: Colors.blue.shade400, size: 20),
          ),
          const SizedBox(width: 12),
          
          // Text Details
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subject,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    // Helper to get value
    String? getVal(List<String> keys) {
      for (var k in keys) {
        if (session[k] != null) return session[k].toString();
      }
      return null;
    }

    final title = getVal(['title', 'name', 'subject']) ?? 'Sesi Tanpa Judul';
    final teacher = getVal(['teacher_name', 'lecturer_name', 'guru']);
    final className = getVal(['class_name', 'className', 'kelas']);
    
    // Construct display title if fields are separate
    String displayTitle = title;
    if (teacher != null && !displayTitle.contains(teacher)) {
      displayTitle += " ($teacher)";
    }
    if (className != null && !displayTitle.contains(className)) {
      displayTitle += " - $className";
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      displayTitle,
                      style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${session['start_time']} - ${session['end_time']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                       Navigator.pushNamed(context, '/attendance', arguments: session);
                    },
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text("Absen Sekarang"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class CircularStats extends StatelessWidget {
  final double percentage;
  const CircularStats({super.key, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 60,
      child: Stack(
        children: [
          Center(
            child: CircularProgressIndicator(
              value: percentage / 100,
              strokeWidth: 8,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
            ),
          ),
          Center(
            child: Icon(Icons.check_circle, color: Colors.white.withOpacity(0.9)),
          )
        ],
      ),
    );
  }
}
