import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:youthfinance/features/transactions/model/transaction_model.dart';
import 'package:youthfinance/features/transactions/model/transaction_provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/cards/app_card.dart';

class CashflowChart extends ConsumerWidget {
  const CashflowChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionState = ref.watch(transactionProvider);

    return AppCard(
      child: transactionState.when(
        loading: () {
          return const SizedBox(
            height: 320,
            child: Center(child: CircularProgressIndicator()),
          );
        },

        error: (error, stack) {
          return const SizedBox(
            height: 320,
            child: Center(child: Text('Unable to load cash flow')),
          );
        },

        data: (transactions) {
          final chartData = _buildChartData(transactions);

          if (chartData.isEmpty) {
            return const SizedBox(
              height: 260,
              child: Center(
                child: Text('Add transactions to see your cash flow'),
              ),
            );
          }

          return _CashFlowChartContent(data: chartData);
        },
      ),
    );
  }

  // ============================================================
  // Build Daily Chart Data
  // ============================================================

  List<_DailyCashFlow> _buildChartData(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return [];
    }

    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    // ----------------------------------------------------------
    // Ignore future transactions
    // ----------------------------------------------------------

    final validTransactions = transactions.where((transaction) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      return !date.isAfter(today);
    }).toList();

    if (validTransactions.isEmpty) {
      return [];
    }

    // ----------------------------------------------------------
    // Find first transaction date
    // ----------------------------------------------------------

    validTransactions.sort((a, b) => a.date.compareTo(b.date));

    final firstTransaction = validTransactions.first.date;

    final startDate = DateTime(
      firstTransaction.year,
      firstTransaction.month,
      firstTransaction.day,
    );

    // ----------------------------------------------------------
    // Group transactions by date
    // ----------------------------------------------------------

    final dailyTotals = <String, _DayTotal>{};

    for (final transaction in validTransactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      final key = _dateKey(date);

      final existing = dailyTotals[key];

      if (existing == null) {
        dailyTotals[key] = _DayTotal(
          income: transaction.isIncome ? transaction.amount : 0,
          expense: transaction.isIncome ? 0 : transaction.amount,
        );
      } else {
        dailyTotals[key] = _DayTotal(
          income:
              existing.income + (transaction.isIncome ? transaction.amount : 0),
          expense:
              existing.expense +
              (transaction.isIncome ? 0 : transaction.amount),
        );
      }
    }

    // ----------------------------------------------------------
    // Build every day from first transaction → today
    // ----------------------------------------------------------

    final result = <_DailyCashFlow>[];

    DateTime cursor = startDate;

    double cumulativeIncome = 0;
    double cumulativeExpense = 0;
    double cumulativeSavings = 0;

    while (!cursor.isAfter(today)) {
      final key = _dateKey(cursor);

      final totals = dailyTotals[key];

      final income = totals?.income ?? 0;
      final expense = totals?.expense ?? 0;

      cumulativeIncome += income;
      cumulativeExpense += expense;
      cumulativeSavings += income - expense;

      result.add(
        _DailyCashFlow(
          date: cursor,
          income: cumulativeIncome,
          expense: cumulativeExpense,
          savings: cumulativeSavings,
        ),
      );

      cursor = cursor.add(const Duration(days: 1));
    }

    return result;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }
}

// ============================================================
// Chart Content
// ============================================================

class _CashFlowChartContent extends StatelessWidget {
  final List<_DailyCashFlow> data;

  const _CashFlowChartContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final maximum = _getMaximumValue();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ------------------------------------------------------
        // Header
        // ------------------------------------------------------
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cash Flow Trend', style: AppTextStyles.sectionTitle),

                const SizedBox(height: 5),

                Text(
                  'Income, expenses & savings',
                  style: AppTextStyles.caption,
                ),
              ],
            ),

            Text(
              _periodLabel(),
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // ------------------------------------------------------
        // Chart
        // ------------------------------------------------------
        SizedBox(
          height: 260,
          child: LineChart(
            LineChartData(
              // ------------------------------------------------
              // X axis
              // ------------------------------------------------
              minX: 0,

              // Add some empty space after today's point.
              //
              // The lines stop at today, but the graph continues
              // slightly to the right to make it clear that the
              // chart is tracking an ongoing timeline.
              maxX: _getMaxX(),

              // ------------------------------------------------
              // Y axis
              // ------------------------------------------------
              minY: _getMinimumY(),

              maxY: _getChartMax(maximum),

              // ------------------------------------------------
              // Borders
              // ------------------------------------------------
              borderData: FlBorderData(show: false),

              // ------------------------------------------------
              // Grid
              // ------------------------------------------------
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _getGridInterval(maximum),

                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    strokeWidth: 1,
                    dashArray: [6, 5],
                    color: Colors.grey.shade300,
                  );
                },
              ),

              // ------------------------------------------------
              // Axis Titles
              // ------------------------------------------------
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),

                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),

                // Y axis
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
                    interval: _getGridInterval(maximum),

                    getTitlesWidget: (value, meta) {
                      return Text(
                        _formatAmount(value),
                        style: AppTextStyles.caption.copyWith(fontSize: 10),
                      );
                    },
                  ),
                ),

                // X axis
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,

                    interval: _getXAxisInterval(),

                    getTitlesWidget: (value, meta) {
                      final index = value.round();

                      if (index < 0 || index >= data.length) {
                        return const SizedBox.shrink();
                      }

                      // Only show selected dates.
                      if (!_shouldShowDate(index)) {
                        return const SizedBox.shrink();
                      }

                      return SideTitleWidget(
                        meta: meta,
                        space: 10,
                        child: Text(
                          _formatDate(data[index].date),
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // ------------------------------------------------
              // Touch / Tooltip
              // ------------------------------------------------
              lineTouchData: LineTouchData(
                enabled: true,
                handleBuiltInTouches: true,

                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) {
                    if (spots.isEmpty) {
                      return [];
                    }

                    return spots.map((spot) {
                      final index = spot.x.round();

                      if (index < 0 || index >= data.length) {
                        return null;
                      }

                      final point = data[index];

                      String title;

                      switch (spot.barIndex) {
                        case 0:
                          title = 'Income';
                          break;

                        case 1:
                          title = 'Expense';
                          break;

                        default:
                          title = 'Savings';
                      }

                      return LineTooltipItem(
                        '${_formatDate(point.date)}\n'
                        '$title  ₹${spot.y.toStringAsFixed(0)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),

              // ------------------------------------------------
              // Lines
              // ------------------------------------------------
              lineBarsData: [
                // ==================================================
                // Income
                // ==================================================
                LineChartBarData(
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,

                  dotData: FlDotData(
                    show: _shouldShowDots(),

                    getDotPainter: (spot, percent, bar, index) {
                      return FlDotCirclePainter(
                        radius: 3.5,
                        color: AppColors.primary,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),

                  spots: [
                    for (int i = 0; i < data.length; i++)
                      FlSpot(i.toDouble(), data[i].income),
                  ],
                ),

                // ==================================================
                // Expense
                // ==================================================
                LineChartBarData(
                  isCurved: true,
                  color: Colors.redAccent,
                  barWidth: 3,
                  isStrokeCapRound: true,

                  dotData: FlDotData(
                    show: _shouldShowDots(),

                    getDotPainter: (spot, percent, bar, index) {
                      return FlDotCirclePainter(
                        radius: 3.5,
                        color: Colors.redAccent,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),

                  spots: [
                    for (int i = 0; i < data.length; i++)
                      FlSpot(i.toDouble(), data[i].expense),
                  ],
                ),

                // ==================================================
                // Savings
                // ==================================================
                LineChartBarData(
                  isCurved: true,
                  color: Colors.blueAccent,
                  barWidth: 3,
                  isStrokeCapRound: true,

                  dotData: FlDotData(
                    show: _shouldShowDots(),

                    getDotPainter: (spot, percent, bar, index) {
                      return FlDotCirclePainter(
                        radius: 3.5,
                        color: Colors.blueAccent,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),

                  spots: [
                    for (int i = 0; i < data.length; i++)
                      FlSpot(i.toDouble(), data[i].savings),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ------------------------------------------------------
        // Legend
        // ------------------------------------------------------
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _ChartLegend(color: AppColors.primary, title: 'Income'),

            SizedBox(width: 20),

            _ChartLegend(color: Colors.redAccent, title: 'Expense'),

            SizedBox(width: 20),

            _ChartLegend(color: Colors.blueAccent, title: 'Savings'),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // Period
  // ============================================================

  String _periodLabel() {
    final first = data.first.date;
    final last = data.last.date;

    final days = last.difference(first).inDays + 1;

    if (days < 30) {
      return '$days Days';
    }

    final months = (days / 30).round();

    return '$months Months';
  }

  // ============================================================
  // X Axis Range
  // ============================================================

  double _getMaxX() {
    if (data.length <= 1) {
      return 2;
    }

    // Keep the actual data ending before the chart edge.
    //
    // This creates a small "future" area after today without
    // creating fake financial data.
    final padding = data.length < 15 ? 2.0 : data.length * 0.08;

    return (data.length - 1) + padding;
  }

  // ============================================================
  // X Axis Label Interval
  // ============================================================

  double _getXAxisInterval() {
    final length = data.length;

    if (length <= 7) {
      return 1;
    }

    if (length <= 14) {
      return 2;
    }

    if (length <= 30) {
      return 5;
    }

    if (length <= 60) {
      return 7;
    }

    return 10;
  }

  // ============================================================
  // Decide Which Date Labels To Show
  // ============================================================

  bool _shouldShowDate(int index) {
    if (index < 0 || index >= data.length) {
      return false;
    }

    final date = data[index].date;

    // Always show the first date.
    if (index == 0) {
      return true;
    }

    // Always show today's date.
    if (index == data.length - 1) {
      return true;
    }

    final interval = _getXAxisInterval();

    return index % interval == 0;
  }

  // ============================================================
  // Dots
  // ============================================================

  bool _shouldShowDots() {
    // With lots of daily data, showing every dot makes the chart
    // noisy. Only show dots when the history is reasonably short.
    return data.length <= 20;
  }

  // ============================================================
  // Y Axis Maximum
  // ============================================================

  double _getMaximumValue() {
    double maximum = 0;

    for (final point in data) {
      maximum = [
        maximum,
        point.income,
        point.expense,
        point.savings,
      ].reduce((a, b) => a > b ? a : b);
    }

    return maximum;
  }

  double _getChartMax(double maximum) {
    if (maximum <= 0) {
      return 1000;
    }

    final interval = _getGridInterval(maximum);

    return ((maximum / interval).ceil() + 1) * interval;
  }

  // ============================================================
  // Y Axis Minimum
  // ============================================================

  double _getMinimumY() {
    double minimum = 0;

    for (final point in data) {
      minimum = [minimum, point.savings].reduce((a, b) => a < b ? a : b);
    }

    if (minimum >= 0) {
      return 0;
    }

    final interval = _getGridInterval(_getMaximumValue());

    return ((minimum / interval).floor() - 1) * interval;
  }

  // ============================================================
  // Grid Interval
  // ============================================================

  double _getGridInterval(double maximum) {
    if (maximum <= 5000) {
      return 1000;
    }

    if (maximum <= 10000) {
      return 2500;
    }

    if (maximum <= 30000) {
      return 5000;
    }

    if (maximum <= 60000) {
      return 10000;
    }

    if (maximum <= 100000) {
      return 20000;
    }

    return 25000;
  }

  // ============================================================
  // Amount Formatting
  // ============================================================

  String _formatAmount(double value) {
    final absolute = value.abs();

    if (absolute >= 100000) {
      return '${value < 0 ? '-' : ''}'
          '₹${(absolute / 100000).toStringAsFixed(1)}L';
    }

    if (absolute >= 1000) {
      return '${value < 0 ? '-' : ''}'
          '₹${(absolute / 1000).toStringAsFixed(0)}K';
    }

    return '₹${value.toStringAsFixed(0)}';
  }

  // ============================================================
  // Date Formatting
  // ============================================================

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]}';
  }
}

// ============================================================
// Daily Cash Flow
// ============================================================

class _DailyCashFlow {
  final DateTime date;

  final double income;
  final double expense;
  final double savings;

  const _DailyCashFlow({
    required this.date,
    required this.income,
    required this.expense,
    required this.savings,
  });
}

// ============================================================
// Daily Transaction Totals
// ============================================================

class _DayTotal {
  final double income;
  final double expense;

  const _DayTotal({required this.income, required this.expense});
}

// ============================================================
// Legend
// ============================================================

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String title;

  const _ChartLegend({required this.color, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),

        const SizedBox(width: 6),

        Text(title, style: AppTextStyles.caption),
      ],
    );
  }
}
