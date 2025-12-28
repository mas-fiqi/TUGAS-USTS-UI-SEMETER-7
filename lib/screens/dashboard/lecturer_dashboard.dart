import 'package:flutter/material.dart';
import '../../services/report_service.dart';
import '../../services/attendance_service.dart';
import '../../services/deleted_session_manager.dart';
import 'class_detail_screen.dart';

class LecturerDashboardWidget extends StatefulWidget {
  const LecturerDashboardWidget({super.key});

  @override
  State<LecturerDashboardWidget> createState() => _LecturerDashboardWidgetState();
}

class _LecturerDashboardWidgetState extends State<LecturerDashboardWidget> {
  // Store locally created sessions for display
  final List<Map<String, dynamic>> _createdSessions = [];
  bool _isLoadingSessions = false;

  @override
  void initState() {
    super.initState();
    _fetchTodaySessions();
  }

  Future<void> _fetchTodaySessions() async {
    setState(() => _isLoadingSessions = true);
    try {
      final service = AttendanceService();
      // Fetch for known classes (mock list of classes)
      // In real app, lecturer would have list of assigned classes.
      // Here we fetch for class 1 and 2 as we have buttons/dropdowns for them.
      final s1 = await service.getTodaySessions('1');
      final s2 = await service.getTodaySessions('2');
      
      if (mounted) {
        setState(() {
          _createdSessions.clear(); 
          _createdSessions.addAll(s1.cast<Map<String, dynamic>>());
          _createdSessions.addAll(s2.cast<Map<String, dynamic>>());
        });
      }
    } catch (e) {
      print("Error fetching lecturer sessions: $e");
    } finally {
      if (mounted) setState(() => _isLoadingSessions = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchTodaySessions,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Added consistent padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOMBOL BUAT SESI
            InkWell(
              onTap: () {
                _showCreateSessionDialog(context);
              },
              borderRadius: BorderRadius.circular(20),
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
                    Expanded(
                      child: Column(
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
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
            
            // SESI YANG BARU DIBUAT (Dynamic)
            if (_createdSessions.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sesi Aktif Hari Ini',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '(${_createdSessions.length})',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Remove fixed height constraint to let it grow naturally within the scroll view
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // Scroll handled by parent
                padding: EdgeInsets.zero,
                itemCount: _createdSessions.length,
                itemBuilder: (context, index) {
                  return _buildSessionCard(_createdSessions[index]);
                },
              ),
            ],

            const SizedBox(height: 24),
            const Text(
              'Rekap Kelas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildClassItemV2(context, 'XII RPL 1', '32 Hadir', '2 Alfa'),
                _buildClassItemV2(context, 'XII TKJ 2', '30 Hadir', '0 Alfa'),
                _buildClassItemV2(context, 'XII MM 1', '28 Hadir', '1 Alfa'),
                _buildClassItemV2(context, 'XII OTKP 1', '34 Hadir', '0 Alfa'),
                _buildClassItemV2(context, 'XII BDP 2', '31 Hadir', '3 Alfa'),
              ],
            ),
             const SizedBox(height: 40), // Bottom spacer
          ],
        ),
      ),
    );
  }

  // Not used currently but kept for reference
  Widget _buildClassItem(BuildContext context, String className, String present, String absent) {
    return Container(); 
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    // Helper to get value with fallback keys
    String? getVal(List<String> keys) {
      for (var k in keys) {
        if (session[k] != null) return session[k].toString();
      }
      return null;
    }

    final title = getVal(['title', 'name', 'subject']) ?? 'Sesi Tanpa Judul';
    final cId = getVal(['class_id', 'classId']) ?? '?';
    final start = getVal(['start_time', 'startTime']) ?? '-';
    final end = getVal(['end_time', 'endTime']) ?? '-';

    final sId = getVal(['id', 'session_id', 'sessionId']) ?? UniqueKey().toString();

    return Card(
      key: ValueKey(sId),
      margin: const EdgeInsets.only(bottom: 12), 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.orange.shade50,
      elevation: 0, // Flat look as requested
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.timer, color: Colors.deepOrange, size: 20),
            ),
            const SizedBox(width: 12),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: $cId • $start - $end',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Action
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              tooltip: 'Hapus Sesi',
              onPressed: () {
                 final sIdVal = getVal(['id', 'session_id', 'sessionId']);
                 if (sIdVal != null) {
                   var finalId = int.tryParse(sIdVal) ?? sIdVal;
                   _confirmDeleteSession(finalId, title);
                 } else {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ID Sesi tidak ditemukan")));
                 }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  // _showCreateSessionDialog omitted for brevity - unchanged

  Widget _buildClassItemV2(BuildContext context, String className, String present, String absent) {
    String classId = '1';
    if (className.contains('TKJ')) classId = '2';

    final activeSession = _createdSessions.firstWhere(
      (s) {
        final cId = s['class_id']?.toString() ?? s['classId']?.toString();
        return cId == classId;
      },
      orElse: () => <String, dynamic>{},
    );
    bool isActive = activeSession.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset:const Offset(0,2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ClassDetailScreen(
                  classId: classId,
                  className: className,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar Class Code
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isActive ? Colors.blue.shade100 : Colors.grey.shade100,
                  child: Text(
                    className.length > 4 ? className.substring(4, 7) : "CLS", 
                    style: TextStyle(color: isActive ? Colors.blue.shade800 : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)
                  ),
                ),
                const SizedBox(width: 12),
                
                // Class Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        className,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      isActive 
                        ? Row(
                            children: [
                              Icon(Icons.check_circle, size: 12, color: Colors.green),
                              const SizedBox(width: 4),
                              Text(present, style: const TextStyle(fontSize: 11)),
                              const SizedBox(width: 8),
                              Icon(Icons.cancel, size: 12, color: Colors.red),
                              const SizedBox(width: 4),
                              Text(absent, style: const TextStyle(fontSize: 11)),
                            ],
                          )
                        : const Text("Belum Aktif", style: TextStyle(color: Colors.orange, fontSize: 11)),
                    ],
                  ),
                ),
                
                // Action Button
                SizedBox(
                  height: 32,
                  child: isActive
                    ? ElevatedButton(
                        onPressed: () => _deactivateSession(activeSession['id'], className),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("Stop", style: TextStyle(fontSize: 12)),
                      )
                    : ElevatedButton(
                        onPressed: () => _quickActivateSession(classId, className),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          foregroundColor: Colors.blue,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("Start", style: TextStyle(fontSize: 12)),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _showCreateSessionDialog(BuildContext context) {
    // Controllers for inputs
    // Use current time/dynamic time for better UX
    final now = DateTime.now();
    final startStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    final endTime = now.add(const Duration(hours: 2));
    final endStr = "${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}";

    final titleController = TextEditingController();
    final startController = TextEditingController(text: startStr);
    final endController = TextEditingController(text: endStr);
    final ReportService reportService = ReportService();
    String selectedClassId = '1'; // Default Value

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
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedClassId, // Default Value
              decoration: const InputDecoration(
                labelText: 'Pilih Kelas',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: '1', child: Text('XII RPL 1')),
                DropdownMenuItem(value: '2', child: Text('XII TKJ 2')),
              ],
              onChanged: (val) {
                if (val != null) selectedClassId = val;
              },
            ),
            const SizedBox(height: 16),
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

              // Current Date YYYY-MM-DD
              final now = DateTime.now();
              final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

              // call API
              final result = await reportService.createSession({
                'title': titleController.text, // "IPA"
                'name': titleController.text,  // Redundant for safety
                'subject': titleController.text, // Redundant for safety
                'start_time': startController.text,
                'end_time': endController.text,
                'method': 'face', 
                'class_id': int.parse(selectedClassId),
                'date': dateStr,
              });

              if (result['success']) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Sesi Berhasil Dibuat!')),
                );
                
                // Add to local list to update UI
                setState(() {
                  _createdSessions.insert(0, {
                    'title': titleController.text,
                    'start_time': startController.text,
                    'end_time': endController.text,
                    'class_id': selectedClassId,
                  });
                });
                
              } else {
                 ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ Gagal: ${result['message']}')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }



  Future<void> _quickActivateSession(String classId, String className) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mengaktifkan sesi untuk $className...')),
    );

    final reportService = ReportService();
    final now = DateTime.now();
    final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final startStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    final endTime = now.add(const Duration(hours: 2));
    final endStr = "${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}";

    String subject = "Matematika"; 
    String teacher = "Pak Fiqi";
    String title = "$subject ($teacher) - $className"; 

    final result = await reportService.createSession({
      'title': title,
      'name': title, // Redundant
      'subject': title, // Redundant
      'start_time': startStr,
      'end_time': endStr,
      'method': 'face',
      'class_id': int.parse(classId),
      'date': dateStr,
    });

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ $className Berhasil Diaktifkan!')),
      );
      _fetchTodaySessions();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Gagal: ${result['message']}')),
      );
    }
  }

  Future<void> _deactivateSession(dynamic sessionId, String className) async {
    if (sessionId == null) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Menonaktifkan sesi $className...')),
    );

    final reportService = ReportService();
    // Assuming delete logic is appropriate for "Deactivate"
    final result = await reportService.deleteSession(sessionId is int ? sessionId : int.parse(sessionId.toString()));

    if (result['success']) {
      setState(() {
         // Optimistically remove from list
         // Debug print to ensure ID matching works
         print("Attempting to remove session ID: $sessionId");
         
         // REGISTER TO MANAGER
         final deletedManager = DeletedSessionManager();
         deletedManager.add(sessionId);

         _createdSessions.removeWhere((s) {
           final sId = s['id']?.toString() ?? s['session_id']?.toString() ?? s['sessionId']?.toString();
           // Debug match
           bool match = sId == sessionId.toString();
           if (match) print("Removing session from list: $sId");
           return match;
         });
      });

      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('🛑 Sesi $className Dinonaktifkan & Dihapus')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Gagal: ${result['message']}')),
      );
    }
  }

  void _confirmDeleteSession(dynamic sessionId, String sessionName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Sesi?'),
        content: Text('Apakah Anda yakin ingin menghapus sesi "$sessionName"?\nSesi yang dihapus tidak bisa dikembalikan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              _deactivateSession(sessionId, sessionName);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
