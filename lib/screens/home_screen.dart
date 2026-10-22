import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/data_service.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/quick_input_sheet.dart';
import '../widgets/transaction_card.dart';

class HomeScreen extends StatefulWidget {
  final DataService dataService;
  final VoidCallback onOpenAddTransaction;

  const HomeScreen({
    super.key,
    required this.dataService,
    required this.onOpenAddTransaction,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hideBalance = false;
  String _searchQuery = '';

  void _showNotificationsDialog() {
    final ds = widget.dataService;
    final totalExpense = ds.totalExpense;
    final totalBudget = ds.totalBudgetLimit;
    final ratio = totalBudget > 0 ? (totalExpense / totalBudget) : 0.0;

    List<Map<String, dynamic>> alerts = [];

    if (ratio >= 0.8) {
      alerts.add({
        'title': 'Peringatan Anggaran!',
        'body':
            'Pengeluaran bulan ini sudah mencapai ${(ratio * 100).toInt()}% dari total anggaran.',
        'icon': Icons.warning_amber_rounded,
        'color': AppColors.warning,
      });
    }

    // Check specific categories
    for (var entry in ds.budgets.entries) {
      int spent = ds.spentInCategory(entry.key);
      if (entry.value > 0 && (spent / entry.value) >= 0.85) {
        alerts.add({
          'title': 'Budget ${entry.key} Hampir Habis',
          'body':
              'Terpakai ${Formatters.rupiah(spent)} dari batas ${Formatters.rupiah(entry.value)}.',
          'icon': Icons.error_outline_rounded,
          'color': AppColors.danger,
        });
      }
    }

    if (alerts.isEmpty) {
      alerts.add({
        'title': 'Keuangan Stabil ✨',
        'body': 'Semua pengeluaran masih berada di batas aman budget kamu.',
        'icon': Icons.check_circle_outline_rounded,
        'color': AppColors.primary,
      });
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.notifications_active_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Notifikasi & Peringatan'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: alerts.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (ctx, i) {
              final a = alerts[i];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: (a['color'] as Color).withOpacity(0.15),
                  child: Icon(a['icon'] as IconData, color: a['color'] as Color),
                ),
                title: Text(
                  a['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                subtitle: Text(
                  a['body'] as String,
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final controller =
        TextEditingController(text: widget.dataService.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Ubah Nama Pengguna'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nama Anda',
            hintText: 'Masukkan nama...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                widget.dataService.updateUserName(controller.text.trim());
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
    );
  }

  void _openQuickInputForType(String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickInputSheet(
        wallets: widget.dataService.wallets,
        initialType: type,
        onSave: (tx) => widget.dataService.addTransaction(tx),
      ),
    );
  }

  void _openEditTransaction(int index, TransactionModel tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickInputSheet(
        wallets: widget.dataService.wallets,
        initialTransaction: tx,
        onSave: (updated) => widget.dataService.editTransaction(index, updated),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ds = widget.dataService;
    final totalBalance = ds.totalBalance;
    final totalExpense = ds.totalExpense;
    final totalBudget = ds.totalBudgetLimit;

    // Hitung sisa budget
    double spentRatio = totalBudget > 0
        ? (totalExpense / totalBudget).clamp(0.0, 1.0)
        : 0.0;
    int remainingBudgetPercent = ((1.0 - spentRatio) * 100).toInt();

    // Filter transaksi berdasarkan search
    final transactions = ds.transactions.where((t) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return t.title.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q) ||
          t.wallet.toLowerCase().contains(q);
    }).toList();

    return RefreshIndicator(
      onRefresh: () => ds.loadData(),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Header: Halo, Budi! + Avatar + Notification
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: _showEditProfileDialog,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withOpacity(0.18),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: AppColors.primaryDark,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, ${ds.userName}!',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'Selamat Datang Kembali',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: _showNotificationsDialog,
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_none_rounded, size: 26),
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                tooltip: 'Pemberitahuan',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Total Saldo Gabungan Card (Design from Mockup)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF0F766E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF059669).withOpacity(0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Saldo Gabungan',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _hideBalance = !_hideBalance),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          _hideBalance
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _hideBalance ? 'Rp ••••••••' : Formatters.rupiah(totalBalance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 18),

                // Tombol Pemasukan & Pengeluaran (Side by side pills)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openQuickInputForType('INCOME'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text(
                          'Pemasukan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openQuickInputForType('EXPENSE'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48).withOpacity(0.85),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.remove_rounded, size: 18),
                        label: const Text(
                          'Pengeluaran',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sisa Anggaran Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: Colors.grey.withOpacity(0.12)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sisa Anggaran',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sisa Budget ${Formatters.monthYear(DateTime.now()).split(" ").first}:',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '$remainingBudgetPercent%',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: remainingBudgetPercent < 20
                              ? AppColors.danger
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: 1.0 - spentRatio,
                      minHeight: 8,
                      backgroundColor: Colors.grey.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        remainingBudgetPercent < 20
                            ? AppColors.danger
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header Transaksi Terakhir & Search
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Transaksi Terakhir',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (ds.transactions.length > 3)
                Text(
                  '${ds.transactions.length} transaksi',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Search Field jika transaksi > 4
          if (ds.transactions.length > 4) ...[
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Cari transaksi...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.15)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.15)),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Transaction list
          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 48,
                    color: Colors.grey.withOpacity(0.4),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Belum ada transaksi',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap tombol (+) di bawah untuk mencatat transaksi',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            )
          else
            ...transactions.asMap().entries.map((entry) {
              final index = entry.key;
              final tx = entry.value;
              return TransactionCard(
                transaction: tx,
                onTap: () => _openEditTransaction(index, tx),
                onDelete: () => ds.deleteTransaction(index),
              );
            }),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
