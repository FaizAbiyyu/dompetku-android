import 'package:flutter/material.dart';

// Warna utama
class AppColors {
  static const Color primary = Color(0xFF10B981);
  static const Color primaryDark = Color(0xFF059669);
  static const Color primaryDeep = Color(0xFF0F766E);
  static const Color expense = Color(0xFFE11D48);
  static const Color income = Color(0xFF059669);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color darkBg = Color(0xFF0F172A);

  // Warna untuk pie chart
  static const List<Color> chartColors = [
    Color(0xFF10B981),
    Color(0xFF3B82F6),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
    Color(0xFFFF6B35),
  ];
}

// Ikon dan warna untuk setiap kategori
class CategoryHelper {
  static const Map<String, String> icons = {
    'Makan': '🍔',
    'Transport': '🚗',
    'Belanja': '🛒',
    'Hiburan': '🎬',
    'Tagihan': '💡',
    'Gaji': '💰',
    'Freelance': '💻',
    'Investasi': '📈',
    'Lainnya': '📌',
  };

  static const Map<String, Color> colors = {
    'Makan': Color(0xFF10B981),
    'Transport': Color(0xFF3B82F6),
    'Belanja': Color(0xFFF59E0B),
    'Hiburan': Color(0xFF8B5CF6),
    'Tagihan': Color(0xFFEF4444),
    'Gaji': Color(0xFF059669),
    'Freelance': Color(0xFF06B6D4),
    'Investasi': Color(0xFFEC4899),
    'Lainnya': Color(0xFF6B7280),
  };

  static const Map<String, IconData> materialIcons = {
    'Makan': Icons.restaurant_rounded,
    'Transport': Icons.directions_car_rounded,
    'Belanja': Icons.shopping_bag_rounded,
    'Hiburan': Icons.movie_rounded,
    'Tagihan': Icons.receipt_long_rounded,
    'Gaji': Icons.payments_rounded,
    'Freelance': Icons.laptop_mac_rounded,
    'Investasi': Icons.trending_up_rounded,
    'Lainnya': Icons.more_horiz_rounded,
  };

  static const List<String> expenseCategories = [
    'Makan',
    'Transport',
    'Belanja',
    'Hiburan',
    'Tagihan',
    'Lainnya',
  ];

  static const List<String> incomeCategories = [
    'Gaji',
    'Freelance',
    'Investasi',
    'Lainnya',
  ];

  static String getIcon(String category) => icons[category] ?? '📌';
  static Color getColor(String category) => colors[category] ?? const Color(0xFF6B7280);
  static IconData getMaterialIcon(String category) =>
      materialIcons[category] ?? Icons.more_horiz_rounded;
}

// Ikon dompet
class WalletHelper {
  static const Map<String, IconData> icons = {
    'Bank BCA': Icons.account_balance_rounded,
    'Bank BRI': Icons.account_balance_rounded,
    'Bank Mandiri': Icons.account_balance_rounded,
    'GoPay': Icons.phone_android_rounded,
    'OVO': Icons.phone_android_rounded,
    'DANA': Icons.phone_android_rounded,
    'ShopeePay': Icons.phone_android_rounded,
    'Tunai': Icons.wallet_rounded,
  };

  static IconData getIcon(String walletName) {
    for (var entry in icons.entries) {
      if (walletName.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return Icons.account_balance_wallet_rounded;
  }
}
