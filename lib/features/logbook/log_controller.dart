import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:logbook_app_086/features/logbook/models/log_model.dart';
import 'package:logbook_app_086/services/mongo_service.dart';
import 'package:logbook_app_086/helpers/log_helper.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier =
      ValueNotifier<List<LogModel>>([]);

  static const String _boxName = 'logs';

  List<LogModel> get logs => logsNotifier.value;

  /// Akses Hive Box yang sudah dibuka di main.dart
  Box<LogModel> get _box => Hive.box<LogModel>(_boxName);

  LogController() {
    loadFromDisk();
  }

  // ─── Hive Helpers ────────────────────────────────────────────────────────

  /// Simpan seluruh list ke Hive box (replace all)
  Future<void> saveToDisk() async {
    await _box.clear();
    await _box.addAll(logsNotifier.value);
    await LogHelper.writeLog(
      "HIVE: ${logsNotifier.value.length} catatan disimpan ke lokal",
      source: "log_controller.dart",
      level: 2,
    );
  }

  /// Muat data dari Hive terlebih dahulu, lalu sync cloud di background
  Future<void> loadFromDisk() async {
    // 1. Tampilkan data lokal dulu (instant, offline-friendly)
    final localData = _box.values.toList();
    logsNotifier.value = localData;

    await LogHelper.writeLog(
      "HIVE: Muat ${localData.length} catatan dari lokal",
      source: "log_controller.dart",
      level: 2,
    );

    // 2. Coba sync dari MongoDB di background
    _syncFromCloud();
  }

  Future<void> _syncFromCloud() async {
    try {
      final cloudData = await MongoService().getLogs();

      // Update Hive dan notifier dengan data terbaru dari cloud
      await _box.clear();
      await _box.addAll(cloudData);
      logsNotifier.value = List<LogModel>.from(cloudData);

      await LogHelper.writeLog(
        "CLOUD SYNC: ${cloudData.length} catatan berhasil di-sync",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      // Gagal sync cloud → tetap tampilkan data lokal, tidak ada error ke UI
      await LogHelper.writeLog(
        "CLOUD SYNC: Gagal (offline/error) - $e. Data lokal tetap ditampilkan.",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }

  // ─── CRUD Operations ─────────────────────────────────────────────────────

  Future<void> addLog(String title, String desc, String category, String owner) async {
    final newLog = LogModel(
      id: ObjectId(),
      title: title,
      description: desc,
      category: category,
      owner: owner,
      date: DateTime.now(),
      createdAt: DateTime.now().toIso8601String(),
    );

    // 1. Simpan ke Hive dulu (instant, offline-friendly)
    await _box.add(newLog);
    final currentLogs = List<LogModel>.from(logsNotifier.value)..add(newLog);
    logsNotifier.value = currentLogs;

    // 2. Coba sync ke MongoDB
    try {
      await MongoService().insertLog(newLog);
      await LogHelper.writeLog(
        "SUCCESS: Tambah data '${newLog.title}' ke Cloud",
        source: "log_controller.dart",
      );
    } catch (e) {
      await LogHelper.writeLog(
        "WARNING: Simpan lokal OK, gagal sync cloud Add - $e",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }

  Future<void> updateLog(
    int index,
    String newTitle,
    String newDesc,
    String category,
  ) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final oldLog = currentLogs[index];

    final updatedLog = LogModel(
      idString: oldLog.idString,
      title: newTitle,
      description: newDesc,
      category: category,
      date: DateTime.now(),
      createdAt: oldLog.createdAt,
      owner: oldLog.owner,
    );

    // 1. Update Hive
    await _saveAllToBox(
      List<LogModel>.from(currentLogs)..[index] = updatedLog,
    );
    currentLogs[index] = updatedLog;
    logsNotifier.value = currentLogs;

    // 2. Coba sync ke MongoDB
    try {
      await MongoService().updateLog(updatedLog);
      await LogHelper.writeLog(
        "SUCCESS: Sinkronisasi Update '${oldLog.title}' Berhasil",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "WARNING: Update lokal OK, gagal sync cloud Update - $e",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }

  Future<void> removeLog(int index) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final targetLog = currentLogs[index];

    // 1. Hapus dari Hive
    currentLogs.removeAt(index);
    await _saveAllToBox(currentLogs);
    logsNotifier.value = currentLogs;

    // 2. Coba sync ke MongoDB
    try {
      if (targetLog.id == null) {
        throw Exception("ID Log tidak ditemukan, tidak bisa menghapus di Cloud.");
      }
      await MongoService().deleteLog(targetLog.id!);
      await LogHelper.writeLog(
        "SUCCESS: Sinkronisasi Hapus '${targetLog.title}' Berhasil",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "WARNING: Hapus lokal OK, gagal sync cloud Hapus - $e",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }

  /// Helper: replace semua isi box dengan list baru
  Future<void> _saveAllToBox(List<LogModel> items) async {
    await _box.clear();
    await _box.addAll(items);
  }

  // ─── UI Helpers ──────────────────────────────────────────────────────────

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      return "Selamat Pagi";
    } else if (hour >= 12 && hour < 15) {
      return "Selamat Siang";
    } else if (hour >= 15 && hour < 18) {
      return "Selamat Sore";
    } else {
      return "Selamat Malam";
    }
  }
}
