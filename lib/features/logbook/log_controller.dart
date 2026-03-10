import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mongo_dart/mongo_dart.dart' hide Box;
import 'package:logbook_app_086/features/logbook/models/log_model.dart';
import 'package:logbook_app_086/services/mongo_service.dart';
import 'package:logbook_app_086/helpers/log_helper.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier =
      ValueNotifier<List<LogModel>>([]);
  final ValueNotifier<bool> isOffline = ValueNotifier<bool>(
    false,
  ); // Indikator offline

  static const String _boxName = 'logs';

  List<LogModel> get logs => logsNotifier.value;

  Box<LogModel> get _box => Hive.box<LogModel>(_boxName);

  LogController() {
    loadFromDisk();
  }
  // ─── Hive Helpers ────────────────────────────────────────────────────────

  Future<void> saveToDisk() async {
    await _box.clear();
    await _box.addAll(logsNotifier.value);
    await LogHelper.writeLog(
      "HIVE: ${logsNotifier.value.length} catatan disimpan ke lokal",
      source: "log_controller.dart",
      level: 2,
    );
  }

  Future<void> loadFromDisk() async {
    final localData = _box.values.toList();
    logsNotifier.value = localData;

    await LogHelper.writeLog(
      "HIVE: Muat ${localData.length} catatan dari lokal",
      source: "log_controller.dart",
      level: 2,
    );

    _syncFromCloud();
  }

  Future<void> _syncFromCloud() async {
    try {
      await MongoService().reconnect();

      final cloudData = await MongoService().getLogs();
      final cloudIds = cloudData.map((e) => e.idString).toSet();

      final localData = _box.values.toList();
      bool hasUploaded = false;

      for (var localLog in localData) {
        if (!cloudIds.contains(localLog.idString)) {
          try {
            await MongoService().insertLog(localLog);
            hasUploaded = true;

            await LogHelper.writeLog(
              "AUTO-SYNC: Berhasil unggah catatan tertunda '${localLog.title}'",
              source: "log_controller.dart",
              level: 2,
            );
          } catch (e) {
            // Abaikan jika satu file gagal, lanjut periksa yang lain
          }
        }
      }

      final finalCloudData = hasUploaded
          ? await MongoService().getLogs()
          : cloudData;

      await _box.clear();
      await _box.addAll(finalCloudData);
      logsNotifier.value = List<LogModel>.from(finalCloudData);

      isOffline.value = false;

      await LogHelper.writeLog(
        "CLOUD SYNC: ${finalCloudData.length} catatan berhasil di-sync",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      isOffline.value = true;

      await LogHelper.writeLog(
        "CLOUD SYNC: Gagal (offline/error) - $e. Data lokal tetap ditampilkan.",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }

  // ─── CRUD Operations ─────────────────────────────────────────────────────

  Future<void> addLog(
    String title,
    String desc,
    String category,
    String owner,
      bool isPublic,
  ) async {
    final newLog = LogModel(
      id: ObjectId(),
      title: title,
      description: desc,
      category: category,
      owner: owner,
      date: DateTime.now(),
      createdAt: DateTime.now().toIso8601String(),
      isPublic: isPublic,
    );

    await _box.add(newLog);
    final currentLogs = List<LogModel>.from(logsNotifier.value)..add(newLog);
    logsNotifier.value = currentLogs;

    try {
      await MongoService().insertLog(newLog);
      isOffline.value = false;
      await LogHelper.writeLog(
        "SUCCESS: Tambah data '${newLog.title}' ke Cloud",
        source: "log_controller.dart",
      );
    } catch (e) {
      isOffline.value = true;
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
    bool isPublic,
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
      isPublic: oldLog.isPublic,
    );

    await _saveAllToBox(List<LogModel>.from(currentLogs)..[index] = updatedLog);
    currentLogs[index] = updatedLog;
    logsNotifier.value = currentLogs;

    try {
      await MongoService().updateLog(updatedLog);
      isOffline.value = false;
      await LogHelper.writeLog(
        "SUCCESS: Sinkronisasi Update '${oldLog.title}' Berhasil",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      isOffline.value = true;
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

    currentLogs.removeAt(index);
    await _saveAllToBox(currentLogs);
    logsNotifier.value = currentLogs;

    try {
      if (targetLog.id == null) {
        throw Exception(
          "ID Log tidak ditemukan, tidak bisa menghapus di Cloud.",
        );
      }
      await MongoService().deleteLog(targetLog.id!);
      isOffline.value = false;
      await LogHelper.writeLog(
        "SUCCESS: Sinkronisasi Hapus '${targetLog.title}' Berhasil",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      isOffline.value = true;
      await LogHelper.writeLog(
        "WARNING: Hapus lokal OK, gagal sync cloud Hapus - $e",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }

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
