import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fyp_tallypath/api.dart';
import 'package:fyp_tallypath/globals.dart';
import 'package:fyp_tallypath/screens/notification_screen.dart';
import 'package:fyp_tallypath/user_data.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  num totalDebt = 0;
  num totalLent = 0;
  List<SalesData> spendingData = [];

  @override
  void initState() {
    for (var groupBalance in UserData().balanceList) {
      for (var balance in groupBalance) {
        if (balance["debtor"] == UserData().id) totalDebt += balance["amount"];
        if (balance["creditor"] == UserData().id) totalLent += balance["amount"];
      }
    }

    _loadChart();
    
    super.initState();
  }

  void _loadChart() async {
    List<dynamic> sdlist = await Api.getDailySpending();
    List<SalesData> sd = [];
    var cur = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    int index = sdlist.length - 1;
    for(int day = 0; day < 30; day++){
      if(Globals.parseDateToLocal(sdlist[index]["date"]).compareTo(cur) != 0){
      sd.add(SalesData(cur, 0));
      }else{
        sd.add(SalesData(cur, sdlist[index]["amount"]/100 ));
        if(index>0) index-=1;
      }
      cur = cur.subtract(const Duration(days:1));
    }
    setState((){
      spendingData = sd;
    });

  }


  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('MMM dd');
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
                      Globals.formatCurrency(totalLent.toDouble()/100),
                      const Color(0xFF00D4AA),
                      Icons.arrow_upward,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Borrowed',
                      Globals.formatCurrency(totalDebt.toDouble()/100),
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
                        SizedBox(width: 40,),
                        Column(children:[
                          Text('Today, ${spendingData.isEmpty?"-":formatter.format(spendingData.first.year)}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          Text('This Month', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ]),
                        Column(children:[
                          Text(spendingData.isEmpty?"-":Globals.formatCurrency(spendingData.first.sales), style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal)),
                          Text(spendingData.isEmpty?"-":Globals.formatCurrency(spendingData.fold<double>(0, (sum, item)=>sum + item.sales)), style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal)),
                        ])
                      ],
                    ),
                    const SizedBox(height: 5),
                    Divider(thickness: 0.4,),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child: SfCartesianChart(
                        margin: EdgeInsets.all(5),
                        backgroundColor: Color.fromARGB(255, 250, 255, 254),
                        primaryXAxis: DateTimeAxis(minorTicksPerInterval: 4,dateFormat: DateFormat('MM/d'), desiredIntervals: 5),
                        primaryYAxis: NumericAxis(numberFormat: NumberFormat('0', 'en_US'), minorTicksPerInterval: 1,),
                        series: <CartesianSeries>[
                          // Renders line chart
                          LineSeries<SalesData, DateTime>(
                            dashArray: <double>[3, 3],
                            dataSource: spendingData,
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
                    child: Icon(Icons.filter_alt_sharp, color: Color(0xFF00D4AA),size: 25),
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



