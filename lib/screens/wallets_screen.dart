import 'package:flutter/material.dart';
import '../models/wallet_model.dart';
import '../services/data_service.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/budget_card.dart';
import '../widgets/wallet_card.dart';

class WalletsScreen extends StatefulWidget {
  final DataService dataService;

  const WalletsScreen({super.key, required this.dataService});

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {
  // Dialog Tambah / Edit Dompet
  void _showWalletDialog({int? editIndex, WalletModel? existing}) {
    final nameController =
        TextEditingController(text: existing?.name ?? '');
    final balanceController = TextEditingController(
        text: existing != null ? existing.balance.toString() : '');
    String selectedIcon = existing?.icon ?? '🏦';

    final availableIcons = ['🏦', '📱', '💵', '💳', '🪙', '💼', '🐖'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(existing != null ? 'Edit Dompet' : 'Tambah Dompet Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pilih Ikon
                const Text('Pilih Ikon:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: availableIcons.map((ic) {
                    final isSel = selectedIcon == ic;
                    return InkWell(
                      onTap: () => setDialogState(() => selectedIcon = ic),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSel
                              ? AppColors.primary.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSel ? AppColors.primary : Colors.transparent,
                          ),
                        ),
                        child: Text(ic, style: const TextStyle(fontSize: 22)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Nama Dompet
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Dompet / Akun',
                    hintText: 'Misal: Bank Mandiri, OVO, dll',
                  ),
                ),
                const SizedBox(height: 12),

                // Saldo
                TextField(
                  controller: balanceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Saldo (Rp)',
                    hintText: '0',
                    prefixText: 'Rp ',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final balance = int.tryParse(balanceController.text.trim()) ?? 0;
                if (name.isEmpty) return;

                if (existing != null && editIndex != null) {
                  widget.dataService.editWallet(
                    editIndex,
                    WalletModel(name: name, icon: selectedIcon, balance: balance),
                  );
                } else {
                  widget.dataService.addWallet(
                    WalletModel(name: name, icon: selectedIcon, balance: balance),
                  );
                }
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog Transfer Antar Dompet
  void _showTransferDialog() {
    final ds = widget.dataService;
    if (ds.wallets.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perlu minimal 2 dompet untuk melakukan transfer'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    String fromWallet = ds.wallets.first.name;
    String toWallet = ds.wallets[1].name;
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Transfer Antar Dompet'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dari Dompet
                const Text('Dari Dompet:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: fromWallet,
                  items: ds.wallets
                      .map((w) => DropdownMenuItem(
                            value: w.name,
                            child: Text('${w.icon} ${w.name} (${Formatters.shortRupiah(w.balance)})'),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        fromWallet = val;
                        if (toWallet == fromWallet) {
                          toWallet = ds.wallets
                              .firstWhere((w) => w.name != fromWallet)
                              .name;
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Ke Dompet
                const Text('Ke Dompet:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: toWallet,
                  items: ds.wallets
                      .where((w) => w.name != fromWallet)
                      .map((w) => DropdownMenuItem(
                            value: w.name,
                            child: Text('${w.icon} ${w.name}'),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => toWallet = val);
                  },
                ),
                const SizedBox(height: 12),

                // Nominal
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nominal Transfer',
                    prefixText: 'Rp ',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final amt = int.tryParse(amountController.text.trim()) ?? 0;
                if (amt <= 0) return;

                final fromBalance = ds.wallets
                    .firstWhere((w) => w.name == fromWallet)
                    .balance;
                if (amt > fromBalance) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Saldo dompet asal tidak mencukupi'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                  return;
                }

                ds.transfer(fromWallet, toWallet, amt);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Berhasil transfer ${Formatters.rupiah(amt)} dari $fromWallet ke $toWallet'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Transfer Sekarang'),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog Tambah / Edit Budget
  void _showBudgetDialog({String? existingCategory, int? existingLimit}) {
    final ds = widget.dataService;
    String selectedCategory = existingCategory ??
        CategoryHelper.expenseCategories.firstWhere(
          (c) => !ds.budgets.containsKey(c),
          orElse: () => CategoryHelper.expenseCategories.first,
        );
    final limitController = TextEditingController(
        text: existingLimit != null ? existingLimit.toString() : '1000000');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(existingCategory != null
              ? 'Atur Budget $existingCategory'
              : 'Tambah Budget Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (existingCategory == null) ...[
                const Text('Pilih Kategori:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: CategoryHelper.expenseCategories
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(
                                '${CategoryHelper.getIcon(cat)} $cat'),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedCategory = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: limitController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Batas Budget Bulanan',
                  prefixText: 'Rp ',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final limit = int.tryParse(limitController.text.trim()) ?? 0;
                if (limit <= 0) return;

                widget.dataService.updateBudget(selectedCategory, limit);
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ds = widget.dataService;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Header Mockup: "Dompet & Anggaran" + "+ Tambah" button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Dompet & Anggaran',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showWalletDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text(
                'Tambah',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Section: Daftar Dompet
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Daftar Dompet',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            TextButton.icon(
              onPressed: _showTransferDialog,
              icon: const Icon(Icons.swap_horiz_rounded, size: 16),
              label: const Text(
                'Transfer',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        ...ds.wallets.asMap().entries.map((entry) {
          final idx = entry.key;
          final wallet = entry.value;
          return WalletCard(
            wallet: wallet,
            onTap: () => _showWalletDialog(editIndex: idx, existing: wallet),
            onEdit: () => _showWalletDialog(editIndex: idx, existing: wallet),
            onDelete: () {
              if (ds.wallets.length <= 1) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Minimal harus memiliki 1 dompet'),
                    backgroundColor: AppColors.warning,
                  ),
                );
                return;
              }
              ds.deleteWallet(idx);
            },
          );
        }),
        const SizedBox(height: 20),

        // Section: Budget Bulanan (Mockup Phone 4)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Budget Bulanan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded,
                  color: AppColors.primary),
              onPressed: () => _showBudgetDialog(),
              tooltip: 'Tambah Anggaran',
            ),
          ],
        ),
        const SizedBox(height: 6),

        if (ds.budgets.isEmpty)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.withOpacity(0.12)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Belum ada anggaran kategori.\nTap icon (+) untuk menambahkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            ),
          )
        else
          ...ds.budgets.entries.map((entry) {
            final category = entry.key;
            final limit = entry.value;
            final spent = ds.spentInCategory(category);

            return BudgetCard(
              category: category,
              spent: spent,
              limit: limit,
              onEdit: () => _showBudgetDialog(
                existingCategory: category,
                existingLimit: limit,
              ),
              onDelete: () => ds.deleteBudget(category),
            );
          }),

        const SizedBox(height: 80),
      ],
    );
  }
}
