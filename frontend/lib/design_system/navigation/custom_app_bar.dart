import 'package:flutter/material.dart';

//import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final String subtitle;

  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(title, style: AppTextStyles.heading),

              const SizedBox(height: 4),

              Text(subtitle, style: AppTextStyles.caption),
            ],
          ),
        ),

        if (actions != null) Row(children: actions!),
      ],
    );
  }
}
