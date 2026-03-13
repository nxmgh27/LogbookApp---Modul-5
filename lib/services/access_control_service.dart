// lib/services/access_control_service.dart

class AccessControlService {
  static const String actionCreate = 'create';
  static const String actionRead = 'read';
  static const String actionUpdate = 'update';
  static const String actionDelete = 'delete';

  // Ketua dan Anggota pada dasarnya sama-sama cuma bisa buat & baca
  static final Map<String, List<String>> _rolePermissions = {
    'Ketua': [actionCreate, actionRead],
    'Anggota': [actionCreate, actionRead],
  };

  static bool canPerform(String role, String action, {bool isOwner = false}) {
    // ATURAN SOVEREIGNTY (KEDAULATAN):
    // Apapun role-nya (termasuk Ketua), HANYA pemilik asli yang bisa edit/hapus!
    if (action == actionUpdate || action == actionDelete) {
      return isOwner;
    }

    final permissions = _rolePermissions[role] ?? [];
    return permissions.contains(action);
  }
}
