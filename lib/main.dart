import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DompetKuApp());
}

class DompetKuApp extends StatefulWidget {
  const DompetKuApp({super.key});

  @override
  State<DompetKuApp> createState() => _DompetKuAppState();
}

class _DompetKuAppState extends State<DompetKuApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DompetKu',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF10B981),
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF10B981),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: MainScreen(isDarkMode: isDarkMode, onToggleTheme: toggleTheme),
    );
  }
}

class MainScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const MainScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _hideBalance = false;

  // Data State
  Map<String, int> wallets = {
    'BCA': 10200000,
    'GoPay': 750000,
    'Tunai': 1500000,
  };

  Map<String, int> budgets = {
    'Makan': 1500000,
    'Transport': 1000000,
    'Belanja': 1200000,
    'Tagihan': 1000000,
    'Hiburan': 500000,
  };

  List<Map<String, dynamic>> transactions = [];

  final Map<String, String> categoryIcons = {
    'Makan': '🍔',
    'Transport': '🚗',
    'Belanja': '🛒',
    'Hiburan': '🎬',
    'Tagihan': '💡',
    'Gaji': '💰',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedTx = prefs.getString('transactions');
    final String? savedWallets = prefs.getString('wallets');

    if (savedTx != null && savedWallets != null) {
      setState(() {
        transactions = List<Map<String, dynamic>>.from(jsonDecode(savedTx));
        wallets = Map<String, int>.from(jsonDecode(savedWallets));
      });
    } else {
      // Data awal (Seed data) sesuai mockup
      transactions = [
        {
          'id': '1',
          'title': 'Kopi & Roti Pagi',
          'category': 'Makan',
          'wallet': 'GoPay',
          'amount': 45000,
          'type': 'EXPENSE',
          'date': 'Hari ini, 08:30',
        },
        {
          'id': '2',
          'title': 'Bensin Pertamax',
          'category': 'Transport',
          'wallet': 'BCA',
          'amount': 150000,
          'type': 'EXPENSE',
          'date': 'Kemarin, 18:15',
        },
        {
          'id': '3',
          'title': 'Gaji Bulanan',
          'category': 'Gaji',
          'wallet': 'BCA',
          'amount': 8500000,
          'type': 'INCOME',
          'date': '25 Okt, 09:00',
        },
      ];
      _saveData();
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('transactions', jsonEncode(transactions));
    await prefs.setString('wallets', jsonEncode(wallets));
  }

  String formatRupiah(int number) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(number);
  }

  int get totalBalance => wallets.values.fold(0, (sum, val) => sum + val);

  int get totalIncome => transactions
      .where((t) => t['type'] == 'INCOME')
      .fold(0, (sum, t) => sum + (t['amount'] as int));

  int get totalExpense => transactions
      .where((t) => t['type'] == 'EXPENSE')
      .fold(0, (sum, t) => sum + (t['amount'] as int));

  int get totalBudgetLimit => budgets.values.fold(0, (sum, val) => sum + val);

  void _addTransaction(Map<String, dynamic> newTx) {
    setState(() {
      transactions.insert(0, newTx);
      int amount = newTx['amount'] as int;
      String wallet = newTx['wallet'] as String;
      if (newTx['type'] == 'EXPENSE') {
        wallets[wallet] = (wallets[wallet] ?? 0) - amount;
      } else {
        wallets[wallet] = (wallets[wallet] ?? 0) + amount;
      }
    });
    _saveData();
  }

  void _deleteTransaction(int index) {
    final tx = transactions[index];
    setState(() {
      int amount = tx['amount'] as int;
      String wallet = tx['wallet'] as String;
      if (tx['type'] == 'EXPENSE') {
        wallets[wallet] = (wallets[wallet] ?? 0) + amount;
      } else {
        wallets[wallet] = (wallets[wallet] ?? 0) - amount;
      }
      transactions.removeAt(index);
    });
    _saveData();
  }

  void _openQuickInputModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickInputSheet(
        wallets: wallets.keys.toList(),
        categories: categoryIcons,
        onSave: _addTransaction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomeTab(),
      _buildAnalyticsTab(),
      _buildWalletsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DompetKu',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Pencatat Keuangan Pintar',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _openQuickInputModal,
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navButton(0, Icons.home_rounded, 'Home'),
            _navButton(1, Icons.pie_chart_rounded, 'Statistik'),
            const SizedBox(width: 48), // Ruang untuk tombol (+)
            _navButton(2, Icons.account_balance_wallet_rounded, 'Dompet'),
          ],
        ),
      ),
    );
  }

  Widget _navButton(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? const Color(0xFF10B981) : Colors.grey;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // LAYAR 1: HOME DASHBOARD
  Widget _buildHomeTab() {
    double budgetRatio = totalBudgetLimit == 0
        ? 0
        : (totalExpense / totalBudgetLimit).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Kartu Saldo Utama
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
                color: const Color(0xFF10B981).withOpacity(0.25),
                blurRadius: 16,
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
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  IconButton(
                    icon: Icon(
                      _hideBalance ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white70,
                      size: 18,
                    ),
                    onPressed: () =>
                        setState(() => _hideBalance = !_hideBalance),
                  ),
                ],
              ),
              Text(
                _hideBalance ? 'Rp ••••••••' : formatRupiah(totalBalance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '↓ Pemasukan',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatRupiah(totalIncome),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '↑ Pengeluaran',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatRupiah(totalExpense),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Bar Budget Bulanan
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Penggunaan Budget Bulan Ini',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      '${(budgetRatio * 100).toInt()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: budgetRatio > 0.8
                            ? Colors.red
                            : const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: budgetRatio,
                    minHeight: 10,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      budgetRatio > 0.8 ? Colors.red : const Color(0xFF10B981),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Terpakai ${formatRupiah(totalExpense)} dari batas ${formatRupiah(totalBudgetLimit)}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'Transaksi Terakhir (Geser untuk hapus)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        ...List.generate(transactions.length, (index) {
          final tx = transactions[index];
          final isExpense = tx['type'] == 'EXPENSE';
          return Dismissible(
            key: Key(tx['id'].toString()),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => _deleteTransaction(index),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF10B981).withOpacity(0.12),
                  child: Text(
                    categoryIcons[tx['category']] ?? '💸',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                title: Text(
                  tx['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  '${tx['date']} • ${tx['wallet']}',
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: Text(
                  '${isExpense ? "-" : "+"}${formatRupiah(tx['amount'])}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isExpense
                        ? const Color(0xFFE11D48)
                        : const Color(0xFF059669),
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 80),
      ],
    );
  }

  // LAYAR 2: ANALITIK PENGELUARAN
  Widget _buildAnalyticsTab() {
    Map<String, int> categoryTotals = {};
    for (var tx in transactions.where((t) => t['type'] == 'EXPENSE')) {
      String cat = tx['category'];
      categoryTotals[cat] = (categoryTotals[cat] ?? 0) + (tx['amount'] as int);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Total Pengeluaran Bulan Ini',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  formatRupiah(totalExpense),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFE11D48),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Rincian Per Kategori',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 10),
        ...categoryTotals.entries.map((entry) {
          double pct = totalExpense == 0 ? 0 : (entry.value / totalExpense);
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${categoryIcons[entry.key] ?? "📌"} ${entry.key}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${formatRupiah(entry.value)} (${(pct * 100).toInt()}%)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 8,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // LAYAR 3: DOMPET & ANGGARAN
  Widget _buildWalletsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Daftar Dompet Aktif',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 10),
        ...wallets.entries.map((w) {
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF10B981),
                foregroundColor: Colors.white,
                child: Icon(Icons.account_balance_wallet),
              ),
              title: Text(
                w.key,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                formatRupiah(w.value),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 20),
        const Text(
          'Batas Anggaran (Budget) per Kategori',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 10),
        ...budgets.entries.map((b) {
          int spent = transactions
              .where((t) => t['type'] == 'EXPENSE' && t['category'] == b.key)
              .fold(0, (sum, t) => sum + (t['amount'] as int));
          double ratio = (spent / b.value).clamp(0.0, 1.0);
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${categoryIcons[b.key] ?? "📌"} ${b.key}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${(ratio * 100).toInt()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ratio >= 0.8 ? Colors.orange : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatRupiah(spent)} / ${formatRupiah(b.value)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 8,
                      color: ratio >= 0.9
                          ? Colors.red
                          : ratio >= 0.75
                              ? Colors.orange
                              : const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 80),
      ],
    );
  }
}

// BOTTOM SHEET: 3-TAP QUICK INPUT DENGAN CUSTOM NUMPAD
class QuickInputSheet extends StatefulWidget {
  final List<String> wallets;
  final Map<String, String> categories;
  final Function(Map<String, dynamic>) onSave;

  const QuickInputSheet({
    super.key,
    required this.wallets,
    required this.categories,
    required this.onSave,
  });

  @override
  State<QuickInputSheet> createState() => _QuickInputSheetState();
}

class _QuickInputSheetState extends State<QuickInputSheet> {
  String type = 'EXPENSE';
  String rawAmount = '0';
  String selectedCategory = 'Makan';
  late String selectedWallet;
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedWallet = widget.wallets.first;
  }

  void _onKeyTap(String key) {
    setState(() {
      if (key == 'BS') {
        rawAmount = rawAmount.length > 1
            ? rawAmount.substring(0, rawAmount.length - 1)
            : '0';
      } else if (key == 'OCR') {
        // Simulasi Scan Struk Otomatis
        rawAmount = '68500';
        selectedCategory = 'Makan';
        noteController.text = 'Struk Kopi Kenangan (OCR)';
      } else {
        if (rawAmount == '0') {
          rawAmount = key == '000' ? '0' : key;
        } else if (rawAmount.length < 10) {
          rawAmount += key;
        }
      }
    });
  }

  void _submit() {
    int amount = int.tryParse(rawAmount) ?? 0;
    if (amount <= 0) return;

    widget.onSave({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': noteController.text.isEmpty
          ? 'Transaksi $selectedCategory'
          : noteController.text,
      'category': selectedCategory,
      'wallet': selectedWallet,
      'amount': amount,
      'type': type,
      'date': 'Baru saja',
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(int.tryParse(rawAmount) ?? 0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Toggle Pengeluaran / Pemasukan
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'EXPENSE', label: Text('Pengeluaran')),
              ButtonSegment(value: 'INCOME', label: Text('Pemasukan')),
            ],
            selected: {type},
            onSelectionChanged: (val) => setState(() => type = val.first),
          ),
          const SizedBox(height: 16),
          Text(
            formatted,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: type == 'EXPENSE'
                  ? const Color(0xFFE11D48)
                  : const Color(0xFF10B981),
            ),
          ),
          TextField(
            controller: noteController,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              hintText: 'Tambah catatan (opsional)...',
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 8),

          // Pilihan Kategori
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: widget.categories.entries.map((e) {
                final selected = selectedCategory == e.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('${e.value} ${e.key}'),
                    selected: selected,
                    onSelected: (_) => setState(() => selectedCategory = e.key),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Pilihan Dompet
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sumber Dompet:', style: TextStyle(fontSize: 13)),
              DropdownButton<String>(
                value: selectedWallet,
                items: widget.wallets
                    .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                    .toList(),
                onChanged: (val) => setState(() => selectedWallet = val!),
              ),
            ],
          ),
          const Divider(),

          // Custom Numpad (4 Kolom)
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            childAspectRatio: 1.7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ...['1', '2', '3', 'BS', '4', '5', '6', 'OCR', '7', '8', '9', '000', '0']
                  .map((key) {
                return ElevatedButton(
                  onPressed: () => _onKeyTap(key),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    key == 'BS'
                        ? '⌫'
                        : key == 'OCR'
                            ? '📷 Struk'
                            : key,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                );
              }),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'SIMPAN',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
