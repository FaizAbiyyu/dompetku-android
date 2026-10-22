import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';

class DataService extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  List<WalletModel> _wallets = [];
  Map<String, int> _budgets = {};
  String _userName = 'Budi';

  List<TransactionModel> get transactions => _transactions;
  List<WalletModel> get wallets => _wallets;
  Map<String, int> get budgets => _budgets;
  String get userName => _userName;

  int get totalBalance => _wallets.fold(0, (sum, w) => sum + w.balance);

  int get totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  int get totalExpense => _transactions
      .where((t) => t.isExpense)
      .fold(0, (sum, t) => sum + t.amount);

  int get totalBudgetLimit => _budgets.values.fold(0, (sum, v) => sum + v);

  // Hitung pemasukan/pengeluaran berdasarkan bulan
  int incomeForMonth(DateTime month) => _transactions
      .where((t) =>
          t.isIncome &&
          t.date.year == month.year &&
          t.date.month == month.month)
      .fold(0, (sum, t) => sum + t.amount);

  int expenseForMonth(DateTime month) => _transactions
      .where((t) =>
          t.isExpense &&
          t.date.year == month.year &&
          t.date.month == month.month)
      .fold(0, (sum, t) => sum + t.amount);

  // Rincian kategori per bulan
  Map<String, int> categoryTotalsForMonth(DateTime month) {
    Map<String, int> totals = {};
    for (var tx in _transactions.where((t) =>
        t.isExpense &&
        t.date.year == month.year &&
        t.date.month == month.month)) {
      totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount;
    }
    return totals;
  }

  // Transaksi per bulan
  List<TransactionModel> transactionsForMonth(DateTime month) {
    return _transactions
        .where((t) =>
            t.date.year == month.year && t.date.month == month.month)
        .toList();
  }

  // Pengeluaran per kategori total
  int spentInCategory(String category) => _transactions
      .where((t) => t.isExpense && t.category == category)
      .fold(0, (sum, t) => sum + t.amount);

  // Pengeluaran per kategori per bulan
  int spentInCategoryForMonth(String category, DateTime month) => _transactions
      .where((t) =>
          t.isExpense &&
          t.category == category &&
          t.date.year == month.year &&
          t.date.month == month.month)
      .fold(0, (sum, t) => sum + t.amount);

  // ====== CRUD Operations ======

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedTx = prefs.getString('transactions_v2');
    final String? savedWallets = prefs.getString('wallets_v2');
    final String? savedBudgets = prefs.getString('budgets_v2');
    final String? savedName = prefs.getString('user_name');

    if (savedTx != null && savedWallets != null) {
      _transactions = (jsonDecode(savedTx) as List)
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _wallets = (jsonDecode(savedWallets) as List)
          .map((e) => WalletModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _budgets = savedBudgets != null
          ? Map<String, int>.from(jsonDecode(savedBudgets))
          : _defaultBudgets();
      _userName = savedName ?? 'Budi';
    } else {
      // Seed data sesuai mockup
      _wallets = [
        WalletModel(name: 'Bank BCA', icon: '🏦', balance: 10200000),
        WalletModel(name: 'GoPay', icon: '📱', balance: 750000),
        WalletModel(name: 'Tunai', icon: '💵', balance: 1500000),
      ];
      _budgets = _defaultBudgets();
      _transactions = [
        TransactionModel(
          id: '1',
          title: 'Kopi & Roti Pagi',
          category: 'Makan',
          wallet: 'GoPay',
          amount: 45000,
          type: 'EXPENSE',
          date: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        TransactionModel(
          id: '2',
          title: 'Bensin Pertamax',
          category: 'Transport',
          wallet: 'Bank BCA',
          amount: 150000,
          type: 'EXPENSE',
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
        TransactionModel(
          id: '3',
          title: 'Gaji Bulanan',
          category: 'Gaji',
          wallet: 'Bank BCA',
          amount: 8500000,
          type: 'INCOME',
          date: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ];
      await _saveData();
    }
    notifyListeners();
  }

  Map<String, int> _defaultBudgets() => {
        'Makan': 1500000,
        'Transport': 1000000,
        'Belanja': 1200000,
        'Tagihan': 1000000,
        'Hiburan': 500000,
      };

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'transactions_v2', jsonEncode(_transactions.map((t) => t.toJson()).toList()));
    await prefs.setString(
        'wallets_v2', jsonEncode(_wallets.map((w) => w.toJson()).toList()));
    await prefs.setString('budgets_v2', jsonEncode(_budgets));
    await prefs.setString('user_name', _userName);
  }

  // -- Transaksi --
  void addTransaction(TransactionModel tx) {
    _transactions.insert(0, tx);
    // Update saldo dompet
    final wallet = _wallets.firstWhere(
      (w) => w.name == tx.wallet,
      orElse: () => _wallets.first,
    );
    if (tx.isExpense) {
      wallet.balance -= tx.amount;
    } else {
      wallet.balance += tx.amount;
    }
    _saveData();
    notifyListeners();
  }

  void deleteTransaction(int index) {
    if (index < 0 || index >= _transactions.length) return;
    final tx = _transactions[index];
    // Kembalikan saldo dompet
    final walletIdx = _wallets.indexWhere((w) => w.name == tx.wallet);
    if (walletIdx != -1) {
      if (tx.isExpense) {
        _wallets[walletIdx].balance += tx.amount;
      } else {
        _wallets[walletIdx].balance -= tx.amount;
      }
    }
    _transactions.removeAt(index);
    _saveData();
    notifyListeners();
  }

  void editTransaction(int index, TransactionModel updated) {
    if (index < 0 || index >= _transactions.length) return;
    final old = _transactions[index];

    // Kembalikan saldo lama
    final oldWalletIdx = _wallets.indexWhere((w) => w.name == old.wallet);
    if (oldWalletIdx != -1) {
      if (old.isExpense) {
        _wallets[oldWalletIdx].balance += old.amount;
      } else {
        _wallets[oldWalletIdx].balance -= old.amount;
      }
    }

    // Terapkan saldo baru
    final newWalletIdx = _wallets.indexWhere((w) => w.name == updated.wallet);
    if (newWalletIdx != -1) {
      if (updated.isExpense) {
        _wallets[newWalletIdx].balance -= updated.amount;
      } else {
        _wallets[newWalletIdx].balance += updated.amount;
      }
    }

    _transactions[index] = updated;
    _saveData();
    notifyListeners();
  }

  // -- Dompet --
  void addWallet(WalletModel wallet) {
    _wallets.add(wallet);
    _saveData();
    notifyListeners();
  }

  void editWallet(int index, WalletModel updated) {
    if (index < 0 || index >= _wallets.length) return;
    final oldName = _wallets[index].name;
    _wallets[index] = updated;

    // Update referensi dompet di transaksi
    if (oldName != updated.name) {
      for (int i = 0; i < _transactions.length; i++) {
        if (_transactions[i].wallet == oldName) {
          _transactions[i] = TransactionModel(
            id: _transactions[i].id,
            title: _transactions[i].title,
            category: _transactions[i].category,
            wallet: updated.name,
            amount: _transactions[i].amount,
            type: _transactions[i].type,
            date: _transactions[i].date,
          );
        }
      }
    }
    _saveData();
    notifyListeners();
  }

  void deleteWallet(int index) {
    if (index < 0 || index >= _wallets.length) return;
    if (_wallets.length <= 1) return; // Minimal 1 dompet
    _wallets.removeAt(index);
    _saveData();
    notifyListeners();
  }

  // -- Transfer Antar Dompet --
  void transfer(String from, String to, int amount) {
    final fromIdx = _wallets.indexWhere((w) => w.name == from);
    final toIdx = _wallets.indexWhere((w) => w.name == to);
    if (fromIdx == -1 || toIdx == -1 || amount <= 0) return;

    _wallets[fromIdx].balance -= amount;
    _wallets[toIdx].balance += amount;

    // Simpan sebagai transaksi
    _transactions.insert(
      0,
      TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Transfer $from → $to',
        category: 'Lainnya',
        wallet: from,
        amount: amount,
        type: 'EXPENSE',
        date: DateTime.now(),
      ),
    );
    _transactions.insert(
      0,
      TransactionModel(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        title: 'Terima dari $from',
        category: 'Lainnya',
        wallet: to,
        amount: amount,
        type: 'INCOME',
        date: DateTime.now(),
      ),
    );

    _saveData();
    notifyListeners();
  }

  // -- Budget --
  void updateBudget(String category, int newLimit) {
    _budgets[category] = newLimit;
    _saveData();
    notifyListeners();
  }

  void addBudget(String category, int limit) {
    _budgets[category] = limit;
    _saveData();
    notifyListeners();
  }

  void deleteBudget(String category) {
    _budgets.remove(category);
    _saveData();
    notifyListeners();
  }

  // -- Username --
  void updateUserName(String name) {
    _userName = name;
    _saveData();
    notifyListeners();
  }

  // -- Reset --
  Future<void> resetAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('transactions_v2');
    await prefs.remove('wallets_v2');
    await prefs.remove('budgets_v2');
    await prefs.remove('user_name');
    await loadData();
  }
}
