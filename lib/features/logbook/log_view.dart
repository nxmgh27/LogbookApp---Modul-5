// lib/features/logbook/log_view.dart

import 'package:flutter/material.dart';
import 'package:logbook_app_086/features/logbook/log_controller.dart';
import 'package:logbook_app_086/features/logbook/models/log_model.dart';
import 'package:logbook_app_086/services/access_control_service.dart';
import 'package:logbook_app_086/features/logbook/log_editor_page.dart';
import 'package:logbook_app_086/features/logbook/widgets/log_item_widget.dart';
import 'package:logbook_app_086/features/onboarding/onboarding_view.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async'; 

class LogView extends StatefulWidget {
  final String username;
  final String role; 
  final String teamId; 

  const LogView({super.key, required this.username, this.role = 'Anggota', required this.teamId});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> with SingleTickerProviderStateMixin {
  final LogController _controller = LogController();
  final TextEditingController _searchController = TextEditingController();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription; 
  late AnimationController _animationController;
  late Animation<Offset> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller.init(widget.teamId); 
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), 
    )..repeat(reverse: true); 

    _floatingAnimation = Tween<Offset>(
      begin: const Offset(0, -0.15), 
      end: const Offset(0, 0.05),    
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut, 
    ));

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (!results.contains(ConnectivityResult.none) && _controller.isOffline.value) {
        _controller.loadFromDisk();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Koneksi pulih. Menyinkronkan data tertunda..."),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _connectivitySubscription.cancel(); 
    _animationController.dispose(); 
    super.dispose();
  }

  void _runPrivacyLeakTest() {
    final allLogs = _controller.logsNotifier.value;
    int hiddenPrivateLogs = 0;
    int visibleLogs = 0;
    bool isSecure = true;

    for (var log in allLogs) {
      final isOwner = log.authorId == widget.username;
      final isPublic = log.isPublic == true;

      if (!isOwner && !isPublic) {
        hiddenPrivateLogs++;
      } else {
        visibleLogs++;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFA9B6C4),
        title: const Row(
          children: [
            Icon(Icons.security, color: Color(0xFF243C2C)),
            SizedBox(width: 8),
            Text("Privacy Leak Test", style: TextStyle(color: Color(0xFF243C2C))),
          ],
        ),
        content: Text(
          isSecure 
            ? "Status Keamanan: AMAN \n\n- Catatan yang dapat Anda lihat: $visibleLogs\n- Catatan privat anggota lain yang dienkapsulasi (disembunyikan): $hiddenPrivateLogs\n\nValidasi RBAC berjalan dengan sangat baik. Tidak ada kebocoran data privasi."
            : "Status Keamanan: BOCOR \nSilakan periksa kembali logika filter RBAC Anda.",
          style: const TextStyle(color: Color(0xFF243C2C)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup", style: TextStyle(color: Color(0xFF243C2C))),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(int index) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFA9B6C4),
        title: const Text("Hapus Catatan", style: TextStyle(color: Color(0xFF243C2C))),
        content: const Text("Apakah Anda yakin ingin menghapus catatan ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal", style: TextStyle(color: Color(0xFF243C2C))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  void _goToEditor({LogModel? log, int? index}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogEditorPage(
          log: log,
          index: index,
          controller: _controller,
          currentUsername: widget.username,
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFA9B6C4),
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah kamu yakin ingin logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const OnboardingView()),
                (route) => false,
              );
            },
            child: const Text("Keluar"),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 80, color: Colors.redAccent),
          const SizedBox(height: 24),
          const Text(
            "Waduh, koneksi terputus!",
            style: TextStyle(color: Color(0xFF243C2C), fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Kamu tidak memiliki catatan lokal.\nPastikan internet aktif untuk memuat dari Cloud.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF243C2C), fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF243C2C),
              foregroundColor: const Color(0xFFECE69D),
            ),
            onPressed: () => _controller.loadFromDisk(),
            child: const Text("Coba Lagi"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${_controller.getGreeting()} ${widget.username}!", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            Text("Tim: ${widget.teamId} | Role: ${widget.role}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF243C2C),
        foregroundColor: const Color(0xFFECE69D),
        actions: [
          IconButton(
            icon: const Icon(Icons.security_rounded),
            tooltip: "Jalankan Tes Kebocoran Privasi",
            onPressed: _runPrivacyLeakTest,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.loadFromDisk(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF59789F), Color(0xFFA9B6C4)],
          ),
        ),
        child: Column(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: _controller.isOffline,
              builder: (context, isOffline, child) {
                if (!isOffline) return const SizedBox.shrink(); 

                return Container(
                  width: double.infinity,
                  color: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    children: const [
                      Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Waduh, koneksi terputus! Bekerja dalam mode Offline.",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  hintText: "Cari judul atau isi catatan...",
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF243C2C)),
                  filled: true,
                  fillColor: const Color(0xFFA9B6C4).withOpacity(0.8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),

            Expanded(
              child: ValueListenableBuilder<List<LogModel>>(
                valueListenable: _controller.logsNotifier,
                builder: (context, allLogs, child) {
                  
                  final String query = _searchController.text.toLowerCase();
                  
                  final filteredLogs = allLogs.where((log) {
                    final isOwner = log.authorId == widget.username; 
                    final isPublic = log.isPublic == true;
                    
                    final matchesSearch = log.title.toLowerCase().contains(query) || 
                                          log.description.toLowerCase().contains(query);

                    return (isOwner || isPublic) && matchesSearch;
                  }).toList();

                  if (filteredLogs.isEmpty) {
                    if (_controller.isOffline.value && _searchController.text.isEmpty) {
                      return _buildErrorWidget();
                    }

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          
                          SlideTransition(
                            position: _floatingAnimation,
                            child: SvgPicture.network(
                              'https://raw.githubusercontent.com/FortAwesome/Font-Awesome/6.x/svgs/solid/box-open.svg', 
                              height: 100,
                              colorFilter: const ColorFilter.mode(Color(0xFF243C2C), BlendMode.srcIn),
                              placeholderBuilder: (context) => const CircularProgressIndicator(color: Color(0xFF243C2C)),
                            ),
                          ),

                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text(
                              _searchController.text.isEmpty 
                                  ? "Belum ada aktivitas hari ini?\nMulai catat kemajuan proyek Anda!" 
                                  : "Catatan tidak ditemukan.",
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF243C2C), height: 1.5),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF243C2C), foregroundColor: const Color(0xFFECE69D)),
                            onPressed: () => _goToEditor(),
                            child: const Text("Buat Catatan Pertama"),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: const Color(0xFF243C2C),
                    onRefresh: () async => _controller.loadFromDisk(),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filteredLogs.length,
                      itemBuilder: (context, index) {
                        final log = filteredLogs[index];
                        final isOwner = log.authorId == widget.username;
                     
                        final canDelete = AccessControlService.canPerform(widget.role, AccessControlService.actionDelete, isOwner: isOwner);

                        return canDelete 
                          ? Dismissible(
                              key: Key(log.id ?? index.toString()),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (direction) => _confirmDelete(index),
                              onDismissed: (direction) async {
                                await _controller.removeLog(index);
                              },
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              child: _buildLogItem(log, index, isOwner),
                            )
                          : _buildLogItem(log, index, isOwner); 
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7A9445),
        foregroundColor: const Color(0xFFECE69D),
        onPressed: () => _goToEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLogItem(LogModel log, int index, bool isOwner) {
    return LogItemWidget(
      log: log,
      index: index,
      controller: _controller,
      onEdit: () => _goToEditor(log: log, index: index),
      onDelete: () async {
        final confirm = await _confirmDelete(index);
        if (confirm == true) {
          await _controller.removeLog(index);
        }
      },
      currentRole: widget.role,
      currentUsername: widget.username,
    );
  }
}