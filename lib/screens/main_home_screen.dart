import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fyp_tallypath/api.dart';
import 'package:fyp_tallypath/globals.dart';
import 'package:fyp_tallypath/screens/notification_screen.dart';
import 'package:fyp_tallypath/user_data.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
  List<dynamic> recentList = [];

  @override
  void initState() {
    for (int i = 1; i < UserData().balanceList.length; i++) {
      for (var balance in UserData().balanceList[i]) {
        if (balance["debtor"] == UserData().id) totalDebt += balance["amount"];
        if (balance["creditor"] == UserData().id) totalLent += balance["amount"];
      }
    }
    UserData().updateGroupList();
    _loadChart();
    super.initState();
  }

  void _loadChart() async {
    var rlist = await Api.getRecentExpenses();
    setState(() {recentList = rlist;});
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
              Container(
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
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFFD4F4ED),
                          child: const Icon(Icons.person, size: 24, color: Color(0xFF00D4AA)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              UserData().fullname ?? 'loading..',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "( ${UserData().username ?? 'loading..'} ) ${UserData().email ?? 'loading..'}",
                              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                            ),
                          ]
                        ),
                        Expanded(child:SizedBox()),
                        InkWell(
                          child:Icon(Icons.payment,color: Colors.grey[700]),
                          onTap:(){
                            print("TEST");
                          }
                        )
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height:14),
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
              const SizedBox(height: 14),
              

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
                          Text('Today, ${spendingData.isEmpty?"-":formatter.format(spendingData.first.year.add(Duration(hours:16)))}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
              
            

Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Theme(
    data: Theme.of(context).copyWith(
      dividerColor: Colors.transparent, // remove default divider
    ),
    child: ExpansionTile(
      initiallyExpanded: true,
      maintainState: true,
      tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      childrenPadding: const EdgeInsets.only(bottom: 12),
      iconColor: Colors.grey.shade600,
      collapsedIconColor: Colors.grey.shade600,
      title: Row(
        children: [
          Text(
            'Recent Transactions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
      children: [
        const Divider(height: 1),
        ..._buildRecentList(),
      ],
    ),
  ),
),


            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRecentList(){
    List<Widget> w = [];
    final DateFormat formatter = DateFormat("MMM, dd  HH:mm");
    final DateFormat formatterToday = DateFormat(" HH:mm");

    try{
    if(recentList.isNotEmpty && spendingData.isNotEmpty){
      for(var r in recentList) {
        if(!r["isMessage"]){
          String title, desc;
          IconData icon;
          if(r["isStatement"]){
            title = r["title"].split('@')[0] == "Waived" ? "Waived ${UserData().getNameById(groupId: r["groupId"], userId: r["paidBy"])}": "Payment | ${r["title"].split('@')[1]}";
            icon = r["title"].split('@')[0] == "Waived" ? Icons.handshake_outlined : Icons.payments_outlined; 
            desc = r["title"].split('@')[0] == "Waived" ? UserData().getNameById(groupId: r["groupId"],userId: r["title"].split('@')[1])
            : "From ${UserData().getNameById(groupId: r["groupId"], userId: r["paidBy"])} to ${UserData().getNameById(groupId: r["groupId"],userId: r["title"].split('@')[2])}";
          }else{
            title = r["title"];
            icon = (r["groupId"]==UserData().groupList[0]["groupId"] )? Icons.person : Icons.group;
            desc = UserData().groupList.firstWhere((g)=>g["groupId"]==r["groupId"])["name"];
          }
          var date = Globals.parseDateToLocal(r["createdAt"]);
          w.add(_buildTransactionItem(
            title,
            desc,
            date.isBefore(spendingData.first.year) ? formatter.format(date):"Today, ${formatterToday.format(date)}",
            Globals.formatCurrency(r["amount"]/100),
            icon
          ));
          if(w.length>=15)break;
        }
      }
    }
    }catch(e){
      print(e);
    }
    return w;
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
    String type,
    String date,
    String amount,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  type,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(children: [
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color:const Color(0xFF00D4AA),
            ),
          ),
          Text(date, style: TextStyle(color: Colors.grey[600], fontSize: 10))
          ],)
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


