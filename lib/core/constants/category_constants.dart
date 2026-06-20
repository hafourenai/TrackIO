import 'package:flutter/material.dart';

class CategoryConstants {
  static const List<String> incomeCategories = [
    'gaji',
    'bonus',
    'freelance',
  ];

  static const List<String> expenseCategories = [
    'makan',
    'transportasi',
    'belanja',
    'hiburan',
    'kesehatan',
    'pendidikan',
    'lainnya',
  ];

  static IconData getIcon(String category) {
    switch (category.toLowerCase()) {
      case 'gaji':
        return Icons.work_rounded;
      case 'bonus':
        return Icons.card_giftcard_rounded;
      case 'freelance':
        return Icons.computer_rounded;
      case 'makan':
        return Icons.fastfood_rounded;
      case 'transportasi':
        return Icons.directions_car_rounded;
      case 'belanja':
        return Icons.shopping_bag_rounded;
      case 'hiburan':
        return Icons.sports_esports_rounded;
      case 'kesehatan':
        return Icons.medical_services_rounded;
      case 'pendidikan':
        return Icons.school_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  static Color getColor(String category) {
    switch (category.toLowerCase()) {
      case 'gaji':
        return Colors.green;
      case 'bonus':
        return Colors.amber;
      case 'freelance':
        return Colors.teal;
      case 'makan':
        return Colors.orange;
      case 'transportasi':
        return Colors.blue;
      case 'belanja':
        return Colors.pink;
      case 'hiburan':
        return Colors.purple;
      case 'kesehatan':
        return Colors.red;
      case 'pendidikan':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}
