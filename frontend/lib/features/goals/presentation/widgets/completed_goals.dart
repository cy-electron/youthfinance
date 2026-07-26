import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class CompletedGoals extends StatelessWidget {
  const CompletedGoals({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text("Completed Goals (2)", style: AppTextStyles.sectionTitle),
      children: const [],
    );
  }
}
