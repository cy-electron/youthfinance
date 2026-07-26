import 'package:flutter/material.dart';

import 'pattern_card.dart';

class SpendingPatterns extends StatelessWidget {
  const SpendingPatterns({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,

      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),

      mainAxisSpacing: 16,

      crossAxisSpacing: 16,

      childAspectRatio: 1.25,

      children: const [
        PatternCard(
          title: "Weekend",
          value: "+18%",
          subtitle: "Higher than weekday",
          color: Colors.orange,
        ),

        PatternCard(
          title: "Food",
          value: "-12%",
          subtitle: "Great job cooking!",
          color: Colors.green,
        ),

        PatternCard(
          title: "Subscriptions",
          value: "+6%",
          subtitle: "Netflix price update",
          color: Colors.orange,
        ),

        PatternCard(
          title: "Top Buy",
          value: "₹8,500",
          subtitle: "Nike Air Max",
          color: Colors.black,
        ),
      ],
    );
  }
}
