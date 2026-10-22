import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class QuickInputSheet extends StatefulWidget {
  final List<WalletModel> wallets;
  final Function(TransactionModel) onSave;
  final TransactionModel? initialTransaction;
  final String? initialType;

  const QuickInputSheet({
    super.key,
    required this.wallets,
    required this.onSave,
    this.initialTransaction,
    this.initialType,
  });

  @override
  State<QuickInputSheet> createState() => _QuickInputSheetState();
}

class _QuickInputSheetState extends State<QuickInputSheet> {
  late String _type;
  late String _rawAmount;
  late String _selectedCategory;
  late String _selectedWallet;
  late DateTime _selectedDate;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final init = widget.initialTransaction;
    if (init != null) {
      _type = init.type;
      _rawAmount = init.amount.toString();
      _selectedCategory = init.category;
      _selectedWallet = init.wallet;
      _selectedDate = init.date;
      _noteController = TextEditingController(text: init.title);
    } else {
      _type = widget.initialType ?? 'EXPENSE';
      _rawAmount = '0';
      _selectedCategory = _type == 'EXPENSE' ? 'Makan' : 'Gaji';
      _selectedWallet = widget.wallets.isNotEmpty
          ? widget.wallets.first.name
          : 'Tunai';
      _selectedDate = DateTime.now();
      _noteController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onKeyTap(String key) {
    setState(() {
      if (key == 'BS') {
        _rawAmount = _rawAmount.length > 1
            ? _rawAmount.substring(0, _rawAmount.length - 1)
            : '0';
      } else if (key == 'OCR') {
        // Simulasi scan struk cerdas
        _rawAmount = '45000';
        _selectedCategory = 'Makan';
        _noteController.text = 'Kopi & Roti Pagi (Scan Struk)';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Berhasil memindai struk otomatis: Rp 45.000'),
            duration: Duration(seconds: 2),
            backgroundColor: AppColors.primary,
          ),
        );
      } else if (key == '+50k') {
        int cur = int.tryParse(_rawAmount) ?? 0;
        _rawAmount = (cur + 50000).toString();
      } else {
        if (_rawAmount == '0') {
          _rawAmount = key == '000' ? '0' : key;
        } else if (_rawAmount.length < 11) {
          _rawAmount += key;
        }
      }
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);

    if (today == selectedDay) {
      return 'Hari ini';
    } else if (today.subtract(const Duration(days: 1)) == selectedDay) {
      return 'Kemarin';
    } else {
      return DateFormat('dd MMM').format(date);
    }
  }

  void _submit() {
    final amount = int.tryParse(_rawAmount) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nominal transaksi terlebih dahulu'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final tx = TransactionModel(
      id: widget.initialTransaction?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: _noteController.text.trim().isEmpty
          ? 'Transaksi $_selectedCategory'
          : _noteController.text.trim(),
      category: _selectedCategory,
      wallet: _selectedWallet,
      amount: amount,
      type: _type,
      date: _selectedDate,
    );

    widget.onSave(tx);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _type == 'EXPENSE';
    final categories = isExpense
        ? CategoryHelper.expenseCategories
        : CategoryHelper.incomeCategories;

    final formattedAmount = Formatters.rupiah(int.tryParse(_rawAmount) ?? 0);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag indicator & Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Tutup',
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Header Title
            Center(
              child: Text(
                widget.initialTransaction != null
                    ? 'Edit Transaksi'
                    : 'Tambah Transaksi',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tipe Transaksi (Pengeluaran / Pemasukan)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _type = 'EXPENSE';
                        if (!CategoryHelper.expenseCategories
                            .contains(_selectedCategory)) {
                          _selectedCategory = 'Makan';
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isExpense
                            ? AppColors.expense.withOpacity(0.12)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isExpense
                              ? AppColors.expense
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Pengeluaran',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isExpense
                              ? AppColors.expense
                              : Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _type = 'INCOME';
                        if (!CategoryHelper.incomeCategories
                            .contains(_selectedCategory)) {
                          _selectedCategory = 'Gaji';
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !isExpense
                            ? AppColors.income.withOpacity(0.12)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: !isExpense
                              ? AppColors.income
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Pemasukan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: !isExpense
                              ? AppColors.income
                              : Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bagian Nominal & Note
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.withOpacity(0.15)),
              ),
              child: Column(
                children: [
                  Text(
                    'Nominal',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      formattedAmount,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: isExpense
                            ? AppColors.expense
                            : AppColors.income,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Kopi & Roti Pagi (Catatan opsional)...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).hintColor,
                      ),
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.08),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Grid Kategori
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Grid Kategori',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _selectedCategory,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CategoryHelper.getColor(_selectedCategory),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 74,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = _selectedCategory == cat;
                  final icon = CategoryHelper.getIcon(cat);

                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 68,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.15)
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.withOpacity(0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(icon, style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(
                            cat,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppColors.primaryDark
                                  : Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Sumber Dana & Tanggal
            const Text(
              'Sumber Dana & Tanggal',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Dropdown Wallet
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: widget.wallets.any((w) => w.name == _selectedWallet)
                            ? _selectedWallet
                            : (widget.wallets.isNotEmpty
                                ? widget.wallets.first.name
                                : null),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        items: widget.wallets.map((w) {
                          return DropdownMenuItem(
                            value: w.name,
                            child: Row(
                              children: [
                                Text(w.icon, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    w.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedWallet = val);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Date Picker Chip
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatDateLabel(_selectedDate),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Custom Numpad
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              childAspectRatio: 1.6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildKeyButton('1'),
                _buildKeyButton('2'),
                _buildKeyButton('3'),
                _buildKeyButton('+50k', isAction: true, label: '+50rb'),
                _buildKeyButton('4'),
                _buildKeyButton('5'),
                _buildKeyButton('6'),
                _buildKeyButton('OCR', isAction: true, label: '📷 Scan'),
                _buildKeyButton('7'),
                _buildKeyButton('8'),
                _buildKeyButton('9'),
                _buildKeyButton('000'),
                _buildKeyButton('0'),
                _buildKeyButton('BS', isAction: true, label: '⌫'),
              ],
            ),
            const SizedBox(height: 14),

            // Tombol Simpan Transaksi (Green Pill Button full-width)
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'SIMPAN TRANSAKSI',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyButton(String key, {bool isAction = false, String? label}) {
    return ElevatedButton(
      onPressed: () => _onKeyTap(key),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: isAction
            ? AppColors.primary.withOpacity(0.12)
            : Theme.of(context).cardColor,
        foregroundColor: isAction
            ? AppColors.primaryDark
            : Theme.of(context).textTheme.bodyLarge?.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.grey.withOpacity(0.18),
            width: 1,
          ),
        ),
        padding: EdgeInsets.zero,
      ),
      child: Text(
        label ?? key,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: isAction ? 13 : 16,
        ),
      ),
    );
  }
}
