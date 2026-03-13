// lib/features/logbook/widgets/log_item_widget.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logbook_app_086/features/logbook/models/log_model.dart';
import 'package:logbook_app_086/features/logbook/log_controller.dart';
import 'package:logbook_app_086/services/access_control_service.dart';

class LogItemWidget extends StatelessWidget {
  final LogModel log;
  final int index;
  final LogController controller;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final String currentRole;
  final String currentUsername;

  const LogItemWidget({
    super.key,
    required this.log,
    required this.index,
    required this.controller,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
    required this.currentRole,
    required this.currentUsername,
  });

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Meeting":
        return const Color(0xFFE2D96E); // Kuning
      case "Development":
        return const Color(0xFF4A6A8D); // Biru Gelap
      case "Testing":
        return const Color(0xFF6B8A3C); // Hijau
      case "Deployment":
        return const Color(0xFF8B4513); // Coklat
      case "Research":
        return const Color(0xFF9370DB); // Ungu
      case "Documentation":
        return const Color(0xFF20B2AA); // Teal
      default:
        return const Color(0xFF6B8A3C); // Hijau
    }
  }

  void _showDetailDialog(
    BuildContext context,
    Color accentColor,
    Color primaryDark,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).size.height *
                0.8, // Maksimal 80% tinggi layar
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCategoryBadge(log.category, accentColor),
                          const SizedBox(height: 12),
                          Text(
                            log.title,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: primaryDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.person,
                                    size: 14,
                                    color: primaryDark.withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    // PERBAIKAN: Gunakan authorId
                                    log.authorId,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: primaryDark.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    log.isPublic
                                        ? Icons.public
                                        : Icons.lock_outline,
                                    size: 14,
                                    color: primaryDark.withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    log.isPublic ? "Publik" : "Privat",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: primaryDark.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: primaryDark.withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    // PERBAIKAN: Gunakan date
                                    DateFormat('dd MMM yyyy, HH:mm').format(
                                      DateTime.tryParse(log.date) ??
                                          DateTime.now(),
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: primaryDark.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: primaryDark),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: log.description.isEmpty
                      ? Text(
                          "Tidak ada detail catatan.",
                          style: TextStyle(
                            color: primaryDark.withValues(alpha: 0.5),
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      : MarkdownBody(data: log.description, selectable: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // PERBAIKAN: Gunakan authorId
    final isOwner = log.authorId == currentUsername;
    final canUpdate = AccessControlService.canPerform(
      currentRole,
      AccessControlService.actionUpdate,
      isOwner: isOwner,
    );
    final canDelete = AccessControlService.canPerform(
      currentRole,
      AccessControlService.actionDelete,
      isOwner: isOwner,
    );

    final accentColor = _getCategoryColor(log.category);
    final primaryDark = const Color(0xFF1B2E22);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showDetailDialog(context, accentColor, primaryDark),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(width: 8, color: accentColor),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  _buildCategoryBadge(
                                    log.category,
                                    accentColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.person,
                                    size: 14,
                                    color: primaryDark.withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    // PERBAIKAN: Gunakan authorId
                                    log.authorId,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: primaryDark.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  // --- IKON PUBLIK/PRIVAT ---
                                  Icon(
                                    log.isPublic
                                        ? Icons.public
                                        : Icons.lock_outline,
                                    size: 14,
                                    color: primaryDark.withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    log.isPublic ? "Publik" : "Privat",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: primaryDark.withValues(alpha: 0.6),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // --- IKON STATUS CLOUD SYNC ---
                                  Icon(
                                    // PERBAIKAN: Gunakan id
                                    log.id != null
                                        ? Icons.cloud_done
                                        : Icons.cloud_upload_outlined,
                                    size: 14,
                                    color: log.id != null
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    // PERBAIKAN: Gunakan date
                                    DateFormat('dd MMM, HH:mm').format(
                                      DateTime.tryParse(log.date) ??
                                          DateTime.now(),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF243C2C),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Text(
                            log.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: primaryDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            log.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: primaryDark.withValues(alpha: 0.6),
                            ),
                          ),

                          if (canUpdate || canDelete) ...[
                            const SizedBox(height: 16),
                            const Divider(height: 1, thickness: 0.5),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Spacer(),
                                if (canUpdate)
                                  _buildActionButton(
                                    Icons.edit_rounded,
                                    accentColor,
                                    onEdit,
                                  ),
                                if (canUpdate && canDelete)
                                  const SizedBox(width: 10),
                                if (canDelete)
                                  _buildActionButton(
                                    Icons.delete_outline_rounded,
                                    Colors.redAccent,
                                    onDelete,
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
          color: color.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
