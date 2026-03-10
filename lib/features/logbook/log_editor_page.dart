// lib/features/logbook/log_editor_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logbook_app_086/features/logbook/models/log_model.dart';
import 'package:logbook_app_086/features/logbook/log_controller.dart';

class LogEditorPage extends StatefulWidget {
  final LogModel? log;
  final int? index;
  final LogController controller;
  final String currentUsername;

  const LogEditorPage({
    super.key,
    this.log,
    this.index,
    required this.controller,
    required this.currentUsername,
  });

  @override
  State<LogEditorPage> createState() => _LogEditorPageState();
}

class _LogEditorPageState extends State<LogEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  
  final List<String> _categories = ["Pekerjaan", "Urgent", "Pribadi"];
  late String _selectedCategory;
  bool _isPublic = false; // Status Privasi (Tombol Slide)

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.log?.title ?? '');
    _descController = TextEditingController(text: widget.log?.description ?? '');
    _selectedCategory = widget.log?.category ?? _categories.first;
    _isPublic = widget.log?.isPublic ?? false;

    _descController.addListener(() => setState(() {}));
  }

  void _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Judul tidak boleh kosong!", style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
      return;
    }

    if (widget.log == null) {
      await widget.controller.addLog(
        _titleController.text, _descController.text, _selectedCategory, widget.currentUsername, _isPublic,
      );
    } else {
      await widget.controller.updateLog(
        widget.index!, _titleController.text, _descController.text, _selectedCategory, _isPublic,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.log == null ? "Catatan Baru" : "Edit Catatan"),
          backgroundColor: const Color(0xFF243C2C), // Warna asli
          foregroundColor: const Color(0xFFECE69D), // Warna asli
          bottom: const TabBar(
            labelColor: Color(0xFFECE69D),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFFECE69D),
            tabs: [
              Tab(text: "Editor", icon: Icon(Icons.edit_document)),
              Tab(text: "Pratinjau", icon: Icon(Icons.preview)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _save,
            )
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF59789F), Color(0xFFA9B6C4)], // Warna background asli
            ),
          ),
          child: TabBarView(
            children: [
              // --- TAB 1: EDITOR ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: "Judul Catatan",
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: "Kategori",
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (value) => setState(() => _selectedCategory = value!),
                    ),
                    const SizedBox(height: 12),

                    // --- ICON YANG BISA DI-SLIDE DENGAN TEMA ASLI ---
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Publikasikan ke Tim", 
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(_isPublic ? "Dapat dilihat oleh tim" : "Hanya Anda yang bisa melihat", 
                                  style: const TextStyle(fontSize: 13, color: Colors.black54)),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isPublic,
                            activeColor: const Color(0xFF7A9445), // Warna switch hijau
                            onChanged: (val) {
                              setState(() {
                                _isPublic = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Expanded(
                      child: TextField(
                        controller: _descController,
                        maxLines: null,
                        expands: true,
                        keyboardType: TextInputType.multiline,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          hintText: "Tulis isi laporanmu di sini...\n\nKamu bisa menggunakan sintaks Markdown!\nContoh:\n# Ini Judul Besar\n**Ini Teks Tebal**",
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // --- TAB 2: PRATINJAU ---
              Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: _descController.text.isEmpty
                    ? const Center(child: Text("Pratinjau kosong. Ketik sesuatu di Editor.", style: TextStyle(color: Colors.grey)))
                    : MarkdownBody(data: _descController.text, selectable: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}