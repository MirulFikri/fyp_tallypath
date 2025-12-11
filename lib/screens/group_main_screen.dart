import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fyp_tallypath/api.dart';
import 'package:fyp_tallypath/globals.dart';
import 'package:fyp_tallypath/user_data.dart';
import 'package:intl/intl.dart';
import 'package:number_editing_controller/number_editing_controller.dart';
import 'package:provider/provider.dart';

class GroupMainScreen extends StatefulWidget {
  final int groupIndex;

  const GroupMainScreen({super.key, required this.groupIndex});

  @override
  State<GroupMainScreen> createState() => _GroupMainScreenState();
}

class _GroupMainScreenState extends State<GroupMainScreen> {

  List<dynamic> expenses = [];
  bool isLoading = true;

  @override
  void initState(){
    super.initState();
    _loadExpenses();
    _startAutoRefresh();
  }

  Timer? _refreshTimer;

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => _loadNewExpenses());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      persistentFooterButtons: [BigAddButton(onPressed: _addExpenseDialog, height: 60)],
      backgroundColor: const Color(0xFFE8F9F5),
      appBar: AppBar(
        backgroundColor: Color(0xFF00D4AA),
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Text(
          UserData().groupList[widget.groupIndex]['name'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              // Progress Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [ Color(0xFF00A885), Color(0xFF00D4AA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.payments_sharp, color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Spending', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(
                                Globals.formatCurrency(
                                Provider.of<UserData>(context).groupList[widget.groupIndex]["total"]/100),
                                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    

                    SizedBox(height: 36),
                    SegmentedProgressBar(
                      segments: [
                        Segment(label: 'Foodd', value: 40, color: const Color.fromARGB(255, 156, 255, 159)),
                        Segment(label: 'Rent', value: 30, color: const Color.fromARGB(255, 130, 199, 255)),
                        Segment(label: 'Transport', value: 20, color: const Color.fromARGB(255, 249, 201, 129)),
                        Segment(label: 'Other', value: 10, color: const Color.fromARGB(255, 235, 235, 235)),
                      ],
                      borderRadius: 4,
                      height: 12,
                    ),
                    //const SizedBox(height:20),
                  ],
                ),
              ),

              const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildExpenseListWithDates(expenses),
                ),
              ),
            ),

            ],
          ),
        ),

    );
  }

  Future<void> _loadExpenses() async {
    try{
      final expenses = await Api.getLatestExpenses(UserData().groupList[widget.groupIndex]["groupId"]);
      setState(() {
        this.expenses = expenses;
        UserData().updateGroupList();
        isLoading = false;
      });
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

  }

  Future<void> _loadNewExpenses() async {
    try{
      String lastTimestamp = UserData().groupList[widget.groupIndex]["membership"]["joinedAt"] ;

      if (expenses.isNotEmpty){lastTimestamp = expenses.last['createdAt'];}

      final newExpenses = await Api.getExpensesAfter(UserData().groupList[widget.groupIndex]["groupId"], lastTimestamp);

      if (newExpenses.isNotEmpty) {
        setState(() {
          expenses = [...expenses, ...newExpenses];
          UserData().updateGroupList();
        });
      }
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  List<Widget> _buildExpenseListWithDates(List expenses) {
    List<Widget> widgets = [];
    String? lastDate;
    final formatter = DateFormat("dd MMM yyyy");

    for (final expense in expenses) {
      final currentDate = formatter.format(Globals.parseDateToLocal(expense["createdAt"]));
      final today = formatter.format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day ));

      if (lastDate == null || currentDate != lastDate) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0), 
            child: Center(child: Text(
              currentDate == today ? 'Today' : currentDate,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Color(0xFF00A885)),
            ),
          ),),
        );
        lastDate = currentDate;
      }

      widgets.add(_buildExpenseItem(expense));
    }

    return widgets;
  }


  Widget _buildExpenseItem(Map<String, dynamic> expense) {
    final formatter = DateFormat("HH:mm");
    DateTime dateTime = Globals.parseDateToLocal(expense["createdAt"]);
    String timeStr = formatter.format(dateTime);
    
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
              color: Color.fromARGB(255, 210, 232, 255),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.add,
              color: Color.fromARGB(255, 255, 255, 255),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Globals.formatCurrency(expense['amount']/100),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF00D4AA)),
                ),
              ],
            ),
          ),

          Text(timeStr, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }


  void _addExpenseDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController= TextEditingController();
    final amountController = NumberEditingTextController.currency(currencyName: 'MYR', allowNegative: false);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Add to ${UserData().groupList[widget.groupIndex]['name']}'),
          content: Form(
            key: formKey,
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Title', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'New Expense',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00D4AA)),
                  ),
                ),
                validator: (value){
                  if(value == null || value.isEmpty){
                    return "Expense title can't be empty";
                  }
                },
              ),
              const SizedBox(height:16),
              const Text('Amount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'RM 0.00',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00D4AA)),
                  ),
                ),
                validator: (value){
                  if(value==null){return 'Amount can\'t be empty';}
                },
              ),
              const SizedBox(height: 16),
              const Text('Description (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: descController,
                decoration: InputDecoration(
                  hintText: 'Expense details',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00D4AA)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.watch_later_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${DateTime.now().hour}:${DateTime.now().minute}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  var num = amountController.number ?? 0;
                  var amt = (num * 100).toInt();
                  final String body = jsonEncode({
                    "groupId": UserData().groupList[widget.groupIndex]["groupId"],
                    "title": titleController.text.trim(),
                    "amount": amt,
                  });

                  try{
                    await Api.createExpense(body,UserData().groupList[widget.groupIndex]["groupId"]);
                    _loadNewExpenses();
                  }catch(e){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  }

                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid value'), backgroundColor: Colors.red),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA)),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class BigAddButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final double height;
  final Widget? icon;
  final BorderRadiusGeometry borderRadius;
  final Gradient? gradient;
  final EdgeInsetsGeometry padding;
  final List<BoxShadow>? boxShadow;

  const BigAddButton({
    super.key,
    required this.onPressed,
    this.label = 'Add',
    this.height =  50,
    this.icon,
    this.borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(10),
      topRight: Radius.circular(10),
      bottomLeft: Radius.circular(10),
      bottomRight: Radius.circular(10),
    ),
    this.gradient,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.boxShadow,
  });



  @override
  Widget build(BuildContext context) {
    final Gradient effectiveGradient = gradient ??
        LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        );

    final List<BoxShadow> effectiveShadow = boxShadow ??
        [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            offset: const Offset(0, -2),
            blurRadius: 12,
          )
        ];

    // Use SafeArea + Material+InkWell to get ripple and proper accessibility
    return SafeArea(
      top: false,
      child: Container(
        height: height,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          gradient: effectiveGradient,
          borderRadius: borderRadius,
          boxShadow: effectiveShadow,
        ),
        // Material gives elevation/ripple surface for InkWell
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: borderRadius is BorderRadius
                ? borderRadius as BorderRadius
                : BorderRadius.circular(16),
            onTap: onPressed,
            child: Padding(
              padding: padding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Optional icon
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 12),
                  ] else ...[
                    const Icon(
                      Icons.add_circle_outline,
                      size: 30,
                      semanticLabel: 'Add',
                    ),
                    const SizedBox(width: 12),
                  ],
                  // Label
                  Flexible(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                  ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class Segment {
  final double value;
  final Color color;
  final String label;

  Segment({required this.value, required this.color, required this.label});
}

class SegmentedProgressBar extends StatefulWidget {
  final List<Segment> segments;
  final double height;
  final double borderRadius;
  final Color backgroundColor;

  const SegmentedProgressBar({
    super.key,
    required this.segments,
    this.height = 14,
    this.borderRadius = 5,
    this.backgroundColor = const Color(0xFFE0E0E0),
  });

  @override
  State<SegmentedProgressBar> createState() => _SegmentedProgressBarState();
}

class _SegmentedProgressBarState extends State<SegmentedProgressBar> {
  @override
  Widget build(BuildContext context) {
    final total = widget.segments.fold<double>(0, (sum, item) => sum + item.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          //borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            height: widget.height,
            
            child: Row(
              children:
                widget.segments.map((s) {
                  final percent = s.value / total;

                  return Expanded(
                    flex: (percent * 1000).round(),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(widget.borderRadius),
                          color: s.color, ),
                    ),
                  );
                }
              ).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children:
              widget.segments.map((s) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 8, height: 8, color: s.color),
                    const SizedBox(width: 4),
                    Text(' ${s.label} ${s.value}% ', style: TextStyle(color: Colors.white)),
                  ],
                );
              }).toList(),
        ),
      ],
    );

  }

}

