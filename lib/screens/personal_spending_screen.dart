import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fyp_tallypath/api.dart';
import 'package:fyp_tallypath/globals.dart';
import 'package:fyp_tallypath/screens/add_settlement_screen.dart';
import 'package:fyp_tallypath/screens/group_info_screen.dart';
import 'package:fyp_tallypath/user_data.dart';
import 'package:intl/intl.dart';
import 'package:number_editing_controller/number_editing_controller.dart';
import 'package:provider/provider.dart';


class PersonalSpendingScreen extends StatefulWidget {
  final groupIndex = 0;
  const PersonalSpendingScreen({super.key});

  @override
  State<PersonalSpendingScreen> createState() => _PersonalSpendingScreenState();
}

class _PersonalSpendingScreenState extends State<PersonalSpendingScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<dynamic> expenses = [];
  bool isLoading = true;
  var groupBalance = [];
  List<dynamic> members = [];
  dynamic you;
  bool isPay = false;
  bool isWaive = false;
  int totalBalance = 0;
  bool isDebtState = false;

  @override
  void initState() {
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

  void _showAddExpenseDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddExpenseDialog(groupIndex: widget.groupIndex, members: members);
      },
    );
    _loadNewExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F9F5),
      appBar: AppBar(
        backgroundColor: Color(0xFF00D4AA),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    UserData().groupList[widget.groupIndex]['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
                Container(
              constraints: BoxConstraints(),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 240, 247, 245),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black38, offset: Offset(0, 4), blurRadius: 6, spreadRadius: -4),
                  BoxShadow(color: Colors.black38, offset: Offset(0, -4), blurRadius: 6, spreadRadius: -4),
                  //BoxShadow(color: Color.fromARGB(255, 24, 255, 151).withOpacity(0.25), blurRadius: 16, spreadRadius: 1),
                ],
                border: Border.all(color: Color(0xFF00D4AA), width: 0.2),
              ),
              padding: const EdgeInsets.all(16),
              child: _content(context),),
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

            //TransactionCard(context, title: "Payment@Cash", payer: "You", receiver: "John", amount: 431.21, time: "12:12"),

            SizedBox(height: 5),
            FloatingMessageInputBar(
              groupIndex: widget.groupIndex,
              controller: _messageController,
              onSend: () {
                _loadNewExpenses();
              },
              buttonFunction: _showAddExpenseDialog,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadExpenses() async {
    try {
      final expenses = await Api.getLatestExpenses(UserData().groupList[widget.groupIndex]["groupId"]);
      await UserData().updateGroupList();
      setState(() {
        this.expenses = expenses;
        UserData().updateGroupList();
        isLoading = false;
      });
      _loadNewExpenses();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loadNewExpenses() async {
    try {
      members = [...UserData().groupList[widget.groupIndex]["members"]];
      you ??= members.firstWhere((m) => m["userId"] == UserData().id, orElse: () => null);
      members.removeWhere((m) => m["userId"] == you["userId"]);
      String lastTimestamp = you["joinedAt"];
      if (expenses.isNotEmpty) {
        lastTimestamp = expenses.first['createdAt'];
      }

      final newExpenses = await Api.getExpensesAfter(UserData().groupList[widget.groupIndex]["groupId"], lastTimestamp);
      if (newExpenses.isNotEmpty) {
        setState(() {
          expenses = [...newExpenses, ...expenses];
          UserData().updateGroupList();
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
  }

  List<Widget> _buildExpenseListWithDates(List expenses) {
    List<Widget> widgets = [];
    String? lastDate;
    final formatter = DateFormat("dd MMM yyyy");
    String prevId = "";

    for (final expense in expenses.reversed.toList()) {
      final currentDate = formatter.format(Globals.parseDateToLocal(expense["createdAt"]));
      final today = formatter.format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));

      if (lastDate == null || currentDate != lastDate) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Center(
              child: Text(
                currentDate == today ? 'Today' : currentDate,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Color(0xFF00A885)),
              ),
            ),
          ),
        );
        lastDate = currentDate;
      }
      if (prevId != expense["creatorId"]) {
        widgets.add(SizedBox(height: 16));
      }
      widgets.add(_buildExpenseItem(expense, expense["creatorId"] == prevId));
      prevId = expense["creatorId"];
    }

    return widgets;
  }

  Widget _buildExpenseItem(Map<String, dynamic> expense, bool link) {
    final formatter = DateFormat("H:mm");
    DateTime dateTime = Globals.parseDateToLocal(expense["createdAt"]);
    String timeStr = formatter.format(dateTime);

    return expense["isMessage"]
        ? _regularBubble(
          context,
          name: UserData().getNameInGroup(groupIndex: widget.groupIndex, userId: expense["creatorId"]),
          content: expense["title"],
          isMe: expense["creatorId"] == you["userId"],
          link: link,
          time: timeStr
        ) : ExpenseMessageBubble2(
              title: expense["title"],
              amount: Globals.formatCurrency(expense["amount"] / 100),
              time: timeStr
            );
  }
  
  Widget? _content(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF00D4AA).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.payments_sharp, color: Color(0xFF00D4AA), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Spending',
                        style: TextStyle(color: Color.fromARGB(255, 0, 56, 45), fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Globals.formatCurrency(
                          Provider.of<UserData>(context).groupList[widget.groupIndex]["total"] / 100,
                        ),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 56, 45),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(thickness: 0.6),
          ]
        )
        ]
    );
  }
}

bool willTextWrap(BuildContext context, {required String text, required TextStyle style, required double maxWidth, int maxLines = 1}) {
  final textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: maxLines,
    textDirection:Directionality.of(context),
  )..layout(maxWidth: maxWidth);

  return textPainter.didExceedMaxLines;
}

Widget _regularBubble(
  BuildContext context, {
  required String name,
  required String content,
  required String time,
  required bool isMe,
  required bool link,
}) {
  final theme = Theme.of(context);
  final long = willTextWrap(context, text: content, style: theme.textTheme.bodyMedium!, maxWidth: 300);
  return Align(
    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      constraints: const BoxConstraints(maxWidth: 300),
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 12),
      padding:
          link ? EdgeInsets.symmetric(vertical: 10, horizontal: 18) : EdgeInsets.symmetric(vertical: 6, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: const Radius.circular(20),
          bottomLeft: const Radius.circular(20),
          topLeft: Radius.circular(isMe ? 20 : 2),
          bottomRight: Radius.circular(isMe ? 2 : 20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMe || link ? SizedBox(height: 0) : Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
          isMe || link
              ? SizedBox(height: 0)
              : SizedBox(width: name.length * 5, height: 7, child: Divider(thickness: 0.3)),
          SizedBox(height:2),
          Wrap(children: [
            Text(content, style: theme.textTheme.bodyMedium,),
            if(!long)Text("\n  $time", style:TextStyle(color: Colors.grey[500], fontSize: 9),)
          ]),
            if(long) Align(alignment: Alignment.bottomRight,child: Text(time, style:TextStyle(color: Colors.grey[500], fontSize: 9), softWrap: false,)),
        ],
      ),
    ),
  );
}

class AddExpenseDialog extends StatefulWidget {
  final int groupIndex;
  final List<dynamic> members;
  const AddExpenseDialog({super.key, required this.groupIndex, required this.members});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final amountController = NumberEditingTextController.currency(currencyName: 'MYR', allowNegative: false);
  final formKey = GlobalKey<FormState>();
  final splitController = NumberEditingTextController.currency(value: 0, currencyName: 'MYR', allowNegative: false);
  int amt = 0;
  List<String> names = [];

  @override
  void initState() {
    names.add(UserData().id.toString());
    for (var member in widget.members) {
      names.add(member['userId'].toString());
    }
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Add to ${UserData().groupList[widget.groupIndex]['name']}'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Title', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  hintText: 'New Expense',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00D4AA)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Expense title can't be empty";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Amount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  hintText: 'RM 0.00',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00D4AA)),
                  ),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Amount can\'t be empty';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    amt = ((amountController.number ?? 0) * 100).toInt();
                  });
                },
              ),

              const SizedBox(height: 16),
              Divider(thickness: 1),
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
      ),
      actions: [
        TextButton(
          onPressed: () {
            amountController.clear();
            splitController.clear();
            Navigator.pop(context);
          },
          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        FloatingActionButton(
          heroTag: null,
          backgroundColor: const Color(0xFF00D4AA),
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              var num = amountController.number ?? 0;
              var amt = (num * 100).toInt();
              var splits = [
                {"userId": UserData().id, "share": amt},
              ];
              final String body = jsonEncode({
                "groupId": UserData().groupList[widget.groupIndex]["groupId"],
                "title": titleController.text.trim(),
                "amount": amt,
                "paidBy": UserData().id,
                "splits": splits,
              });

              try {
                await Api.createExpense(body, UserData().groupList[widget.groupIndex]["groupId"]);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Network Error'), backgroundColor: Colors.red));
                }
              }

              Navigator.pop(context);
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid value'), backgroundColor: Colors.red),
                );
              }
            }
          },
        ),
      ],
    );
  }
}

class ExpenseMessageBubble2 extends StatelessWidget {
  final String title;
  final String amount;
  final String time;

  const ExpenseMessageBubble2({
    super.key,

    required this.title,
    required this.amount,


    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600))),
                const SizedBox(width: 8),
                Text(
                  amount,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),

            SizedBox(height:10),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 9)),
            ),
          ],
        ),
      ),
    );
  }
}


class FloatingMessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final String hintText;
  final VoidCallback buttonFunction;
  final int groupIndex;

  const FloatingMessageInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.hintText = 'Add messages, receipts, etc',
    required this.buttonFunction,
    required this.groupIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 15, color: Colors.black),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 10.0),
                    isDense: true, // Helps remove extra default padding
                    filled: true,
                    fillColor: Colors.white,
                    hintText: hintText,
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    // border: InputBorder.none,
                    isCollapsed: true,
                    suffixIcon: IconButton(
                      iconSize: 20,
                      icon: const Icon(Icons.send_sharp),
                      onPressed: () async {
                        final String body = jsonEncode({
                          "groupId": UserData().groupList[groupIndex]["groupId"],
                          "title": controller.text.trim(),
                          "isMessage": true,
                        });
                        try {
                          await Api.createExpense(body, UserData().groupList[groupIndex]["groupId"]);
                          onSend();
                          controller.clear();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Network Error')));
                        }
                      },
                      tooltip: 'Send Message',
                    ),
                    // prefixIcon: IconButton(
                    //   icon: const Icon(Icons.add),
                    //   onPressed: () {}, // 4. Assign your action to onPressed
                    //   tooltip: 'Attach photos',
                    // ),
                  ),
                ),
              ),
              SizedBox(width: 18),
              FloatingActionButton(
                onPressed: buttonFunction,
                backgroundColor: const Color(0xFF00D4AA),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}