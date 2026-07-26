import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    {'icon': Icons.home_rounded, 'label': 'Home'},
    {'icon': Icons.receipt_long_rounded, 'label': 'Transactions'},
    {'icon': Icons.flag_rounded, 'label': 'Goals'},
    {'icon': Icons.insights_rounded, 'label': 'Insights'},
    {'icon': Icons.person_rounded, 'label': 'Profile'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (index) {
            final selected = currentIndex == index;

            return Expanded(
              child: InkWell(
                onTap: () => onTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _items[index]['icon'] as IconData,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: selected ? 28 : 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _items[index]['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
