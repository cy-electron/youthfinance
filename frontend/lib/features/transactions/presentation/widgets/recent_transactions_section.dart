import 'package:flutter/material.dart';

import '../../../../design_system/cards/app_card.dart';
import '../../../../design_system/typography/section_header.dart';
import '../../../transactions/presentation/widgets/transaction_tile.dart';

class RecentTransactionsSection extends StatelessWidget {
  const RecentTransactionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "Recent Transactions",
          actionText: "View All",
          onPressed: () {},
        ),

        const SizedBox(height: 16),

        AppCard(
          child: Column(
            children: const [
              TransactionTile(
                icon: Icons.shopping_cart,
                title: "Grocery Store",
                subtitle: "Today • Food",
                amount: 1250,
                isIncome: false,
              ),

              Divider(),

              TransactionTile(
                icon: Icons.account_balance_wallet,
                title: "Monthly Salary",
                subtitle: "Yesterday",
                amount: 50000,
                isIncome: true,
              ),

              Divider(),

              TransactionTile(
                icon: Icons.local_taxi,
                title: "Uber",
                subtitle: "Yesterday",
                amount: 380,
                isIncome: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
