import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../utils/constants.dart';
import '../widgets/quick_input_sheet.dart';
import 'analytics_screen.dart';
import 'home_screen.dart';
import 'wallets_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const MainNavigationScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _dataService.loadData();
  }

  void _openQuickInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickInputSheet(
        wallets: _dataService.wallets,
        onSave: (tx) => _dataService.addTransaction(tx),
      ),
    );
  }

  void _showResetConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Reset Data?'),
        content: const Text(
          'Tindakan ini akan mengembalikan data ke kondisi awal (sample demo).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _dataService.resetAllData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data berhasil di-reset ke sample demo'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset Data'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _dataService,
      builder: (context, _) {
        final screens = [
          HomeScreen(
            dataService: _dataService,
            onOpenAddTransaction: _openQuickInput,
          ),
          AnalyticsScreen(dataService: _dataService),
          WalletsScreen(dataService: _dataService),
        ];

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            scrolledUnderElevation: 1,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.primaryDark,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DompetKu',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: -0.5,
                      ),
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
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  widget.isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  size: 22,
                ),
                tooltip: 'Ganti Tema',
                onPressed: widget.onToggleTheme,
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (val) {
                  if (val == 'reset') _showResetConfirmDialog();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'reset',
                    child: Row(
                      children: [
                        Icon(Icons.refresh_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Reset ke Data Sample'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: screens[_currentIndex],
          floatingActionButton: FloatingActionButton(
            onPressed: _openQuickInput,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(Icons.add_rounded, size: 32),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            elevation: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  label: 'Home',
                ),
                _navItem(
                  index: 1,
                  icon: Icons.pie_chart_rounded,
                  label: 'Statistik',
                ),
                const SizedBox(width: 48), // Gap for FAB center
                _navItem(
                  index: 2,
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Dompet',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _navItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.primary : Colors.grey;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
