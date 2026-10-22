import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/data_service.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/donut_chart.dart';
import '../widgets/transaction_card.dart';

class AnalyticsScreen extends StatefulWidget {
  final DataService dataService;

  const AnalyticsScreen({super.key, required this.dataService});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late DateTime _selectedMonth;
  String _viewType = 'EXPENSE'; // 'EXPENSE' or 'INCOME'

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  void _prevMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ds = widget.dataService;

    // Filter transactions for this month and selected type
    final monthTransactions = ds.transactions.where((t) =>
        t.date.year == _selectedMonth.year &&
        t.date.month == _selectedMonth.month);

    final filteredTx =
        monthTransactions.where((t) => t.type == _viewType).toList();

    // Calculate totals
    final totalExpense = ds.expenseForMonth(_selectedMonth);
    final totalIncome = ds.incomeForMonth(_selectedMonth);
    final currentTotal = _viewType == 'EXPENSE' ? totalExpense : totalIncome;

    // Category breakdown
    Map<String, int> categoryTotals = {};
    for (var tx in filteredTx) {
      categoryTotals[tx.category] =
          (categoryTotals[tx.category] ?? 0) + tx.amount;
    }

    // Sort categories descending
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Prepare segments for DonutChart
    List<DonutSegment> segments = [];
    int colorIdx = 0;
    for (var entry in sortedCategories) {
      Color c = CategoryHelper.getColor(entry.key);
      if (c == const Color(0xFF6B7280)) {
        c = AppColors.chartColors[colorIdx % AppColors.chartColors.length];
      }
      segments.add(DonutSegment(
        label: entry.key,
        value: entry.value.toDouble(),
        color: c,
      ));
      colorIdx++;
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Title
        const Center(
          child: Text(
            'Analisis Keuangan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),

        // Month Selector: < Oktober 2026 >
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded, size: 28),
              onPressed: _prevMonth,
              tooltip: 'Bulan sebelumnya',
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.18)),
              ),
              child: Text(
                Formatters.monthYear(_selectedMonth),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded, size: 28),
              onPressed: _nextMonth,
              tooltip: 'Bulan berikutnya',
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Segmented Switcher: Pengeluaran vs Pemasukan
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'EXPENSE',
              label: Text('Pengeluaran'),
              icon: Icon(Icons.arrow_downward_rounded, size: 16),
            ),
            ButtonSegment(
              value: 'INCOME',
              label: Text('Pemasukan'),
              icon: Icon(Icons.arrow_upward_rounded, size: 16),
            ),
          ],
          selected: {_viewType},
          onSelectionChanged: (val) => setState(() => _viewType = val.first),
          style: ButtonStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Donut Chart Container (Mockup Phone 3)
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.grey.withOpacity(0.12)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                DonutChart(
                  segments: segments,
                  totalValue: currentTotal.toDouble(),
                  centerTitle: Formatters.rupiah(currentTotal),
                  centerSubtitle: _viewType == 'EXPENSE'
                      ? 'Total Keluar'
                      : 'Total Masuk',
                  strokeWidth: 34,
                  size: 210,
                ),
                const SizedBox(height: 16),
                // Summary pills
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSummaryPill(
                      'Pemasukan',
                      totalIncome,
                      AppColors.income,
                    ),
                    _buildSummaryPill(
                      'Pengeluaran',
                      totalExpense,
                      AppColors.expense,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Kategori Breakdown Header
        const Text(
          'Kategori',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),

        if (sortedCategories.isEmpty)
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
                  'Belum ada data ${_viewType == "EXPENSE" ? "pengeluaran" : "pemasukan"} di bulan ini.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        else
          ...sortedCategories.map((entry) {
            final cat = entry.key;
            final amount = entry.value;
            final pct = currentTotal > 0 ? (amount / currentTotal) : 0.0;
            final catColor = CategoryHelper.getColor(cat);
            final icon = CategoryHelper.getIcon(cat);

            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.withOpacity(0.12)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: catColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$icon $cat',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${Formatters.rupiah(amount)}  (${ (pct * 100).toInt() }%)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: catColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 8,
                        backgroundColor: Colors.grey.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(catColor),
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

  Widget _buildSummaryPill(String label, int amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            Formatters.rupiah(amount),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
