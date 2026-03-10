import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/log_model.dart';
import '../log_controller.dart';

class LogItemWidget extends StatelessWidget {
  final LogModel log;
  final int index;
  final LogController controller;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LogItemWidget({
    super.key,
    required this.log,
    required this.index,
    required this.controller,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Pribadi":
        return const Color(0xFFE2D96E);
      case "Urgent":
        return const Color(0xFF4A6A8D);
      case "Pekerjaan":
      default:
        return const Color(0xFF6B8A3C);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 8, color: accentColor),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCategoryBadge(log.category, accentColor),
                          Text(
                            DateFormat(
                              'dd MMM yyyy, HH:mm',
                            ).format(DateTime.parse(log.createdAt.toString())),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF243C2C),
                              fontWeight: FontWeight.w500,
                            ),
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

                      const SizedBox(height: 20),
                      const Divider(height: 1, thickness: 0.5),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Spacer(),
                          _buildActionButton(
                            Icons.edit_rounded,
                            accentColor,
                            onEdit,
                          ),
                          const SizedBox(width: 10),
                          _buildActionButton(
                            Icons.delete_outline_rounded,
                            Colors.redAccent,
                            onDelete,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
