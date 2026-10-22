import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class BudgetCard extends StatelessWidget {
  final String category;
  final int spent;
  final int limit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BudgetCard({
    super.key,
    required this.category,
    required this.spent,
    required this.limit,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final double ratio = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final int percentage = (ratio * 100).toInt();
    final bool isWarning = ratio >= 0.8;
    final bool isCritical = ratio >= 0.95;

    final Color barColor = isCritical
        ? AppColors.danger
        : isWarning
            ? AppColors.warning
            : AppColors.primary;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCritical
              ? AppColors.danger.withOpacity(0.3)
              : Colors.grey.withOpacity(0.12),
        ),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Category name + warning icon + percentage
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '${CategoryHelper.getIcon(category)} $category',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (isWarning) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 18,
                          color: isCritical ? AppColors.danger : AppColors.warning,
                        ),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '($percentage%)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: barColor,
                        ),
                      ),
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.more_vert_rounded,
                          size: 18,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        onSelected: (val) {
                          if (val == 'edit') onEdit();
                          if (val == 'delete') onDelete();
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('Ubah Batas Budget'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline,
                                    size: 18, color: AppColors.danger),
                                SizedBox(width: 8),
                                Text('Hapus Budget',
                                    style: TextStyle(color: AppColors.danger)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Spent / Limit text
              Text(
                '${Formatters.rupiah(spent)} / ${Formatters.rupiah(limit)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 10),

              // Linear Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 8,
                  backgroundColor: Colors.grey.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
