import 'package:flutter/material.dart';
import '../models/wallet_model.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class WalletCard extends StatelessWidget {
  final WalletModel wallet;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const WalletCard({
    super.key,
    required this.wallet,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = WalletHelper.getIcon(wallet.name);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.12)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Wallet Icon Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: wallet.icon.length > 2
                    ? Icon(iconData, color: AppColors.primary, size: 22)
                    : Text(wallet.icon, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 14),

              // Wallet Name
              Expanded(
                child: Text(
                  wallet.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),

              // Balance
              Text(
                Formatters.rupiah(wallet.balance),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),

              // Popup Menu
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 20,
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
                        Text('Edit Dompet'),
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
                        Text('Hapus',
                            style: TextStyle(color: AppColors.danger)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
