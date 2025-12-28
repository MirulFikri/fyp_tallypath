import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fyp_tallypath/screens/notification_screen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  final Map<String, num> rawData = {"May": 10, "Jun": 53, "July": 61};


  @override
  Widget build(BuildContext context) {
        final List<SalesData> chartData = [
            // SalesData(DateTime(2010, 1, 23), 0),
            // SalesData(DateTime(2010, 1, 24), 0),
            SalesData(DateTime(2010, 1, 25), 0),
            SalesData(DateTime(2010, 1, 26), 110),
            SalesData(DateTime(2010, 1, 27), 3210),
            SalesData(DateTime(2010, 1, 28), 40),
            SalesData(DateTime(2010, 1, 29), 90),
            SalesData(DateTime(2010, 1, 30), 7060),
            SalesData(DateTime(2010, 1, 31), 100),
            SalesData(DateTime(2010, 2, 1), 920),
            SalesData(DateTime(2010, 2, 2), 4080),
            // SalesData(DateTime(2010, 2, 3), 0),
            // SalesData(DateTime(2010, 2, 4), 0),
            // SalesData(DateTime(2010, 2, 5), 0),
            // SalesData(DateTime(2010, 2, 6), 0),
            // SalesData(DateTime(2010, 2, 7), 0),
            // SalesData(DateTime(2010, 2, 8), 0),

        ];



    // final List<SalesData> chartData = [
    //     SalesData(DateTime(2010, 3), 0),
    //     SalesData(DateTime(2010, 4), 0),
    //     SalesData(DateTime(2010, 5), 402),
    //     SalesData(DateTime(2010, 6), 40),
    //     SalesData(DateTime(2010, 7), 40),
    //     SalesData(DateTime(2010, 8), 60),
    //     SalesData(DateTime(2010, 9), 40),
    //     SalesData(DateTime(2010, 10), 310),
    //     SalesData(DateTime(2010, 11), 210),
    //     SalesData(DateTime(2010, 12), 10),
    //     SalesData(DateTime(2011, 1), 110),
    //     SalesData(DateTime(2011, 2), 210),
    // ];
    return Scaffold(
      backgroundColor: const Color(0xFFE8F9F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'TallyPath',
          style: TextStyle(
            color: Color(0xFF00D4AA),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lending/Borrowing Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Lent',
                      'RM 1,234.00',
                      const Color(0xFF00D4AA),
                      Icons.arrow_upward,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Borrowed',
                      'RM 567.00',
                      Colors.red,
                      Icons.arrow_downward,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              

              // Monthly Spending Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Spending Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Icon(Icons.calendar_today_outlined),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Divider(thickness: 0.4,),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child: SfCartesianChart(
                        primaryXAxis: DateTimeAxis(),
                        series: <CartesianSeries>[
                          // Renders line chart
                          LineSeries<SalesData, DateTime>(
                            dataSource: chartData,
                            xValueMapper: (SalesData sales, _) => sales.year,
                            yValueMapper: (SalesData sales, _) => sales.sales,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
             
              const SizedBox(height: 24),
              
              // Recent Transactions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              _buildTransactionItem(
                'Payment to John',
                'Oct 30, 2025',
                'RM 150.00',
                true,
                Icons.person,
              ),
              _buildTransactionItem(
                'Received from Sarah',
                'Oct 29, 2025',
                'RM 200.00',
                false,
                Icons.person,
              ),
              _buildTransactionItem(
                'Group Dinner',
                'Oct 28, 2025',
                'RM 45.50',
                true,
                Icons.restaurant,
              ),
              _buildTransactionItem(
                'Loan Repayment',
                'Oct 27, 2025',
                'RM 500.00',
                false,
                Icons.account_balance_wallet,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF00D4AA),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    String title,
    String date,
    String amount,
    bool isExpense,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD4F4ED),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF00D4AA)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isExpense ? "-" : "+"}$amount',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isExpense ? Colors.red : const Color(0xFF00D4AA),
            ),
          ),
        ],
      ),
    );
  }
}

    class SalesData {
        SalesData(this.year, this.sales);
        final DateTime year;
        final double sales;
    }



