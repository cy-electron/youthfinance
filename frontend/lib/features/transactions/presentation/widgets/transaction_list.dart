import 'package:flutter/material.dart';

import 'transaction_group.dart';
import 'transaction_tile.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TransactionGroup(
          title: "Today",
          transactions: const [
            TransactionTile(
              icon: Icons.local_cafe,
              title: "Coffee",
              subtitle: "Food • 9:41 AM",
              amount: 250,
              isIncome: false,
            ),

            TransactionTile(
              icon: Icons.movie,
              title: "Netflix",
              subtitle: "Entertainment • 8:00 AM",
              amount: 199,
              isIncome: false,
            ),
          ],
        ),

        TransactionGroup(
          title: "Yesterday",
          transactions: const [
            TransactionTile(
              icon: Icons.account_balance_wallet,
              title: "Salary",
              subtitle: "Income • 6:00 PM",
              amount: 35000,
              isIncome: true,
            ),

            TransactionTile(
              icon: Icons.local_gas_station,
              title: "Fuel",
              subtitle: "Transport • 2:30 PM",
              amount: 850,
              isIncome: false,
            ),
          ],
        ),
      ],
    );
  }
}
