import 'package:flutter/material.dart';

import '../../../../design_system/cards/app_card.dart';
import '../../../../core/theme/app_text_styles.dart';

class PatternCard extends StatelessWidget {
  final String title;

  final String value;

  final String subtitle;

  final Color color;

  const PatternCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(title.toUpperCase(), style: AppTextStyles.caption),

          const SizedBox(height: 12),

          Text(value, style: AppTextStyles.heading.copyWith(color: color)),

          const SizedBox(height: 6),

          Text(subtitle, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
