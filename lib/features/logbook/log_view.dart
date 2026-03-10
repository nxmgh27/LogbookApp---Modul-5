import 'package:flutter/material.dart';
import 'log_controller.dart';
import 'models/log_model.dart';
import 'widgets/log_item_widget.dart';
import '../onboarding/onboarding_view.dart';
import 'package:logbook_app_086/services/mongo_service.dart';

class LogView extends StatefulWidget {
  final String username;

  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final LogController _controller = LogController();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = ["Pekerjaan", "Urgent", "Pribadi"];
  String _selectedCategory = "Pekerjaan";

  late Future<List<LogModel>> _logFuture;

  @override
  void initState() {
    super.initState();
    _logFuture = MongoService().getLog(widget.username);
  }

  void _refreshData() {
    setState(() {
      _logFuture = MongoService().getLog(widget.username);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<bool?> _confirmDelete(int index) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFA9B6C4),
        title: const Text(
          "Hapus Catatan",
          style: TextStyle(color: Color(0xFF243C2C)),
        ),
        content: const Text(
          "Apakah Anda yakin ingin menghapus catatan ini di Cloud?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Batal",
              style: TextStyle(color: Color(0xFF243C2C)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  void _showAddLogDialog() {
    _titleController.clear();
    _contentController.clear();
    _selectedCategory = _categories.first;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFA9B6C4),
          title: const Text(
            "Tambah Catatan",
            style: TextStyle(color: Color(0xFF243C2C)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Judul"),
              ),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: "Deskripsi"),
                maxLines: 3,
              ),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) =>
                    setDialogState(() => _selectedCategory = value!),
                decoration: const InputDecoration(labelText: "Kategori"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Batal",
                style: TextStyle(color: Color(0xFF243C2C)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF243C2C),
                foregroundColor: const Color(0xFFECE69D),
              ),
              onPressed: () async {
                if (_titleController.text.isNotEmpty) {
                  final navigator = Navigator.of(context);

                  await _controller.addLog(
                    _titleController.text,
                    _contentController.text,
                    _selectedCategory,
                    widget.username,
                  );

                  if (!mounted) return;

                  navigator.pop();
                  _refreshData();
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditLogDialog(int index, LogModel log) {
    _titleController.text = log.title;
    _contentController.text = log.description;
    _selectedCategory = log.category;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFA9B6C4),
          title: const Text(
            "Edit Catatan",
            style: TextStyle(color: Color(0xFF243C2C)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Judul"),
              ),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: "Deskripsi"),
                maxLines: 3,
              ),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) =>
                    setDialogState(() => _selectedCategory = value!),
                decoration: const InputDecoration(labelText: "Kategori"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Batal",
                style: TextStyle(color: Color(0xFF243C2C)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF243C2C),
                foregroundColor: const Color(0xFFECE69D),
              ),
              onPressed: () async {
                final navigator = Navigator.of(context);

                await _controller.updateLog(
                  index,
                  _titleController.text,
                  _contentController.text,
                  _selectedCategory,
                );

                if (!mounted) return;

                navigator.pop();
                _refreshData();
              },
              child: const Text("Update"),
            ),
          ],
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
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
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
            style: TextStyle(
              color: Color(0xFF243C2C),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Pastikan internetmu aktif dan coba lagi.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF243C2C), fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF243C2C),
              foregroundColor: const Color(0xFFECE69D),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: _refreshData,
            child: const Text("Coba Lagi"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 48, color: Color(0xFF243C2C)),
          const SizedBox(height: 16),
          const Text(
            "Tidak ada catatan",
            style: TextStyle(color: Color(0xFF243C2C), fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${_controller.getGreeting()} ${widget.username}!",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF243C2C),
        foregroundColor: const Color(0xFFECE69D),
        actions: [
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
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  hintText: "Cari judul...",
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF243C2C),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFA9B6C4).withValues(alpha: 0.8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<LogModel>>(
                future: _logFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildErrorWidget();
                  }

                  if (snapshot.hasData) {
                    final allLogs = snapshot.data!;
                    final filteredLogs = allLogs
                        .where(
                          (log) => log.title.toLowerCase().contains(
                            _searchController.text.toLowerCase(),
                          ),
                        )
                        .toList();

                    if (filteredLogs.isEmpty) return _buildEmptyWidget();

                    return RefreshIndicator(
                      color: const Color(0xFF243C2C),
                      onRefresh: () async => _refreshData(),
                      child: ListView.builder(
                        itemCount: filteredLogs.length,
                        itemBuilder: (context, index) {
                          final log = filteredLogs[index];
                          return Dismissible(
                            key: Key(
                              log.id?.oid ??
                                  log.id?.toString() ??
                                  index.toString(),
                            ),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) =>
                                _confirmDelete(index),
                            onDismissed: (direction) async {
                              await _controller.removeLog(index);
                              _refreshData();
                            },
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            child: LogItemWidget(
                              index: index,
                              log: log,
                              controller: _controller,
                              onEdit: () => _showEditLogDialog(index, log),
                              onDelete: () async {
                                final confirmed = await _confirmDelete(index);
                                if (confirmed == true) {
                                  await _controller.removeLog(index);
                                  _refreshData();
                                }
                              },
                            ),
                          );
                        },
                      ),
                    );
                  }

                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF243C2C)),
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
        onPressed: _showAddLogDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
