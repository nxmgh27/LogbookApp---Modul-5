import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mongo_dart/mongo_dart.dart' hide Box;
import 'package:logbook_app_086/features/logbook/models/log_model.dart';
import 'package:logbook_app_086/services/mongo_service.dart';
import 'package:logbook_app_086/helpers/log_helper.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier<List<LogModel>>([]);
  final ValueNotifier<bool> isOffline = ValueNotifier<bool>(false);

  static const String _boxName = 'logs';
  String activeTeamId = 'no_team';

  List<LogModel> get logs => logsNotifier.value;

  Box<LogModel> get _box => Hive.box<LogModel>(_boxName);

  LogController(); 

  void init(String teamId) {
    activeTeamId = teamId;
    loadFromDisk();
  }

  Future<void> saveToDisk() async {
    await _box.clear();
    await _box.addAll(logsNotifier.value);
  }

  Future<void> loadFromDisk() async {
    final localData = _box.values.where((log) => log.teamId == activeTeamId).toList();
    logsNotifier.value = localData;

    await LogHelper.writeLog(
      "HIVE: Muat ${localData.length} catatan dari lokal untuk tim $activeTeamId",
      source: "log_controller.dart",
      level: 2,
    );

    _syncFromCloud();
  }

  Future<void> _syncFromCloud() async {
    try {
      await MongoService().reconnect();

      final cloudData = await MongoService().getLogs(activeTeamId);
      final cloudIds = cloudData.map((e) => e.id).toSet();

      final localData = _box.values.where((log) => log.teamId == activeTeamId).toList();
      bool hasUploaded = false;

      for (var localLog in localData) {
        if (!cloudIds.contains(localLog.id)) {
          try {
            await MongoService().insertLog(localLog);
            hasUploaded = true;
          } catch (e) {}
        }
      }

      final finalCloudData = hasUploaded ? await MongoService().getLogs(activeTeamId) : cloudData;

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
        "CLOUD SYNC: Gagal (offline/error) - $e. Data lokal tetap.",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }

  Future<void> addLog(
    String title,
    String desc,
    String category,
    String owner,
    bool isPublic,
  ) async {
    final newLog = LogModel(
      id: ObjectId().oid, 
      title: title,
      description: desc,
      category: category,
      authorId: owner,
      teamId: activeTeamId, 
      date: DateTime.now().toIso8601String(), 
      isPublic: isPublic,
    );

    await _box.add(newLog);
    final currentLogs = List<LogModel>.from(logsNotifier.value)..add(newLog);
    logsNotifier.value = currentLogs;

    try {
      await MongoService().insertLog(newLog);
      isOffline.value = false;
    } catch (e) {
      isOffline.value = true;
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
      id: oldLog.id, 
      title: newTitle,
      description: newDesc,
      category: category,
      date: DateTime.now().toIso8601String(),
      authorId: oldLog.authorId, 
      teamId: oldLog.teamId,
      isPublic: isPublic, 
    );

    await _saveAllToBox(List<LogModel>.from(currentLogs)..[index] = updatedLog);
    currentLogs[index] = updatedLog;
    logsNotifier.value = currentLogs;

    try {
      await MongoService().updateLog(updatedLog);
      isOffline.value = false;
    } catch (e) {
      isOffline.value = true;
    }
  }

  Future<void> removeLog(int index) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final targetLog = currentLogs[index];

    currentLogs.removeAt(index);
    await _saveAllToBox(currentLogs);
    logsNotifier.value = currentLogs;

    try {
      if (targetLog.id != null) {
        await MongoService().deleteLog(ObjectId.fromHexString(targetLog.id!));
      }
      isOffline.value = false;
    } catch (e) {
      isOffline.value = true;
    }
  }

  Future<void> _saveAllToBox(List<LogModel> items) async {
    await _box.clear();
    await _box.addAll(items);
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return "Selamat Pagi";
    if (hour >= 12 && hour < 15) return "Selamat Siang";
    if (hour >= 15 && hour < 18) return "Selamat Sore";
    return "Selamat Malam";
  }
}