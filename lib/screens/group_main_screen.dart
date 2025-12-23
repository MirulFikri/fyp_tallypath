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
  final TextEditingController _messageController = TextEditingController();
  List<dynamic> expenses = [];
  bool isLoading = true;
  var groupBalance = [];
  List<dynamic> members = [];
  dynamic you;

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
      //persistentFooterButtons: [BigAddButton(onPressed: _showAddExpenseDialog, height: 60)],
      backgroundColor: const Color(0xFFE8F9F5),
      appBar: AppBar(
        backgroundColor: Color(0xFF00D4AA),
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Text(
          UserData().groupList[widget.groupIndex]['name'],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {})],
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
                  colors: [Color(0xFF00A885), Color(0xFF00D4AA)],
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
                          color: Colors.white.withValues(alpha: 0.2),
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
                                Provider.of<UserData>(context).groupList[widget.groupIndex]["total"] / 100,
                              ),
                              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Wrap(children:balanceList(groupBalance)),
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

            SizedBox(height:5),
            FloatingMessageInputBar(
                controller: _messageController,
                onSend: () {
                  final text = _messageController.text.trim();
                  if (text.isEmpty) return;
                  // handle send
                  _messageController.clear();
                },
                buttonFunction: _showAddExpenseDialog,
              )

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
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
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
      var gb = await Api.getGroupBalance(UserData().groupList[widget.groupIndex]['groupId']);
      setState(() {
        groupBalance = gb;
      });

      if (newExpenses.isNotEmpty) {
        setState(() {
          expenses = [...newExpenses, ...expenses];
          UserData().updateGroupList();
        });
      }
    } catch (e) {
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  List<Widget> _buildExpenseListWithDates(List expenses) {
    List<Widget> widgets = [];
    String? lastDate;
    final formatter = DateFormat("dd MMM yyyy");

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

      widgets.add(_buildExpenseItem(expense));
    }

    return widgets;
  }

List<Widget> balanceList(List<dynamic> balance){
  List<Widget> w = [];
  var isSettled = true;

  for (var b in balance) {
    if(b["debtor"] == UserData().id){
      isSettled = false;
      w.add(Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 232, 198),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "You Owe ${UserData().getNameInGroup(groupIndex: widget.groupIndex, userId: b['creditor'])} ${Globals.formatCurrency(b['amount']/100)}",
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ));

    }else if(b["creditor"] == UserData().id){
      isSettled = false;
      w.add(Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 171, 255, 238),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "${UserData().getNameInGroup(groupIndex: widget.groupIndex, userId: b['debtor'])} Owes You ${Globals.formatCurrency(b['amount']/100)}",
          style: TextStyle(
          color: Color(0xFF00D4AA),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ));
    }
  }

  if(isSettled){
      w.add(Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 189, 255, 191),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "Settled",
          style: TextStyle(
          color: Colors.green,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ));
    }

  return w;
}



  Widget _buildExpenseItem(Map<String, dynamic> expense) {
    final formatter = DateFormat("HH:mm");
    DateTime dateTime = Globals.parseDateToLocal(expense["createdAt"]);
    String timeStr = formatter.format(dateTime);

    return ExpenseMessageBubble2(
      creatorName: UserData().getNameInGroup(groupIndex: widget.groupIndex, userId: expense["creatorId"]),
      paidByName: UserData().getNameInGroup(groupIndex: widget.groupIndex, userId: expense["paidBy"]),
      title: expense["title"],
      amount: Globals.formatCurrency(expense["amount"]/100),
      isMe:expense["creatorId"]==you["userId"],
      groupIndex: widget.groupIndex,
      splits: expense["splits"],
    );
/*
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 210, 232, 255),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add, color: Color.fromARGB(255, 255, 255, 255), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense['title'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  Globals.formatCurrency(expense['amount'] / 100),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF00D4AA)),
                ),
              ],
            ),
          ),

          Text(timeStr, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );

    */
  }
}

class SliderController extends ValueNotifier<double> {
  SliderController(double value) : super(value);

  double get value => super.value;
  set value(double newValue) => super.value = newValue;
}

class SliderFormField extends FormField<double> {
  SliderFormField({
    super.key,
    required double max,
    double min = 0,
    int? divisions,
    required SliderController controller,
    FormFieldValidator<double>? validator,
  }) : super(
         initialValue: controller.value,
         validator: validator,
         builder: (state) {
           return ValueListenableBuilder<double>(
             valueListenable: controller,
             builder: (_, value, __) {
               return Column(
                 children: [
                   Slider(
                     min: min,
                     max: max == 0 ? 1 : max,
                     divisions: divisions,
                     value: value.clamp(min, max),
                     onChanged: (v) {
                       controller.value = v;
                       state.didChange(v);
                     },
                     label: (value.toInt() / 100).toString(),
                   ),
                 ],
               );
             },
           );
         },
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
  final sliderController = SliderController(0);
  final splitController = NumberEditingTextController.currency(value:0, currencyName: 'MYR', allowNegative: false);
  final sliderControllers = [];
  final splitControllers = [];
  int amt = 0;
  String? selectedName;
  List<String> names = [];

  @override
  void initState() {
    amountController.addListener(() {
      final amount = ((amountController.number ?? 0) * 100).toDouble();
      sliderController.value = sliderController.value.clamp(0, amount);
    });
    sliderController.addListener(() {
      final amount = sliderController.value;
      splitController.number = amount / 100;
    });
    names.add(UserData().id.toString());
    for (var member in widget.members) {names.add(member['userId'].toString());}
    super.initState();
  }

  List<Widget> _buildExpenseSplit() {
    List<Widget> widgets = [];

    for (int index = 0; index < widget.members.length; index++) {
      sliderControllers.add(SliderController(0));
      splitControllers.add(NumberEditingTextController.currency(value:0, currencyName: 'MYR', allowNegative: false));
      amountController.addListener(() {
        final amount = ((amountController.number ?? 0) * 100).toDouble();
        sliderControllers[index].value = sliderControllers[index].value.clamp(0, amount);
      });
      sliderControllers[index].addListener(() {
        final amount = sliderControllers[index].value;
        splitControllers[index].number = amount / 100;
      });

      var w = Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(height:16),
          //Divider(thickness: 1,),
          Row(
            children: [
              Text("${widget.members[index]['nameInGroup']}:"),
              Expanded(
                child: SliderFormField(
                  max: amt.toDouble(),
                  divisions: 200,
                  controller: sliderControllers[index],
                  validator: (v){
                    return null;
                  },
                ),
              ),
            ],
          ),
          Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) {
                splitControllers[index].number = (splitControllers[index].number ?? 0).clamp(0, amt / 100);
                setState(() {
                  sliderControllers[index].value = ((splitControllers[index].number ?? 0) * 100).toDouble();
                });
              }
            },
            child: SizedBox(
              width: 120,
              child: TextFormField(
                controller: splitControllers[index],
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.all(12),
                  hintText: 'RM 0.00',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFF00D4AA)),
                    gapPadding: 2,
                  ),
                ),
                validator: (value) {
                  return null;
                },
              ),
            ),
          ),
        ],
      );
      widgets.add(w);
    }
    return widgets;
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
              SizedBox(height: 16),
              Divider(thickness: 1),
              const Text('Paid By', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),              
              DropdownButtonFormField<String>(
                initialValue: selectedName,
                decoration: const InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  labelText: 'Select person',
                  border: OutlineInputBorder(),
                ),
                items: names.map((name) {
                  return DropdownMenuItem<String>(
                    value: name,
                    child: name == UserData().id ? Text("You") : Text(widget.members.firstWhere((m)=>m["userId"]==name)["nameInGroup"]),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedName = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Divider(thickness: 1),
              const SizedBox(height: 8),
              const Text('Cost Split', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              Row(
                children: [
                  Text("You:"),
                  Expanded(
                    child: SliderFormField(
                      max: amt.toDouble(),
                      divisions: 200,
                      controller: sliderController,
                      validator: (v){return null;},
                    ),
                  ),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.end, children:[
                Focus(
                onFocusChange: (hasFocus) {
                  if (!hasFocus) {
                    splitController.number = (splitController.number ?? 0).clamp(0, amt / 100);
                    setState(() {
                      sliderController.value = ((splitController.number ?? 0) * 100).toDouble();
                    });
                  }
                },
                child: SizedBox(
                  width: 120,
                  child: TextFormField(
                    controller: splitController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.all(12),
                      hintText: 'RM 0.00',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFF00D4AA)),
                        gapPadding: 2,
                      ),
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'Amount can\'t be empty';
                      }
                      return null;
                    },
                  ),
                ),
              ),]),
              Column(children: _buildExpenseSplit()),
              const SizedBox(height: 8),
              Divider(thickness: 1),
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
      ),
      actions: [
        TextButton(
          onPressed: () {
            amountController.clear();
            splitController.clear();
            Navigator.pop(context);
          },
          child: const Text('Cancel', style:TextStyle(fontWeight: FontWeight.bold)),
        ),
        FloatingActionButton(
          backgroundColor: const Color(0xFF00D4AA),
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () async{
            FocusScope.of(context).unfocus();
            await Future<void>.delayed(Duration.zero);
            if (formKey.currentState!.validate()) {
              var num = amountController.number ?? 0;
              var amt = (num * 100).toInt();
              var amts = [];
              var n = splitController.number ?? 0;
              amts.add((n*100).toInt());
              splitControllers.forEach((sc){
                var n = sc.number ?? 0;
                amts.add((n*100).toInt());
              });
              var splits = [{"userId": UserData().id, "share": amts[0]}];
              for(var i = 0; i < widget.members.length; i++){
                splits.add({"userId":widget.members[i]["userId"], "share":amts[i+1]});
              }
              final String body = jsonEncode({
                "groupId": UserData().groupList[widget.groupIndex]["groupId"],
                "title": titleController.text.trim(),
                "amount": amt,
                "paidBy": selectedName,
                "splits":splits
              });

              try {
                await Api.createExpense(body, UserData().groupList[widget.groupIndex]["groupId"]);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
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
        )
      ],
    );
  }
}


class ExpenseMessageBubble2 extends StatelessWidget {
  final String creatorName;
  final String paidByName;
  final String title;
  final String amount;
  final int groupIndex;
  final String? description;
  final bool isMe;
  final List<dynamic> splits;

  const ExpenseMessageBubble2({
    super.key,
    required this.creatorName,
    required this.paidByName,
    required this.title,
    required this.amount,
    required this.groupIndex,
    required this.splits,
    this.description,
    this.isMe = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isMe
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : Colors.white,
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
            /// Creator / payer info (low emphasis)
            Text(
              isMe ? 'Paid by $paidByName' :'$creatorName • Paid by $paidByName',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 8),

            /// Title + Amount (HIGH emphasis)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
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

            if (description != null && description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: theme.textTheme.bodySmall,
              ),
            ],

            SharePreviewList(
              groupIndex: groupIndex,
              shares: splits,
              previewCount: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class SharePreviewList extends StatefulWidget {
  final List<dynamic> shares;
  final int previewCount;
  final int groupIndex;

  const SharePreviewList({
    super.key,
    required this.shares,
    this.previewCount = 2,
    required this.groupIndex,
  });

  @override
  State<SharePreviewList> createState() => _SharePreviewListState();
}

class _SharePreviewListState extends State<SharePreviewList> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = widget.shares.length;
    final visibleCount = _expanded
        ? total
        : total.clamp(0, widget.previewCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(visibleCount, (index) {
          final item = widget.shares[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    UserData().getNameInGroup(groupIndex: widget.groupIndex, userId: item['userId']),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                Text(
                  Globals.formatCurrency(item['share']/100),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }),

        if (total > widget.previewCount)
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _expanded
                    ? 'Show less'
                    : '+ ${total - widget.previewCount} more',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}



class FloatingMessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final String hintText;
  final VoidCallback buttonFunction;

  const FloatingMessageInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.hintText = 'Add messages, receipts, etc',
    required this.buttonFunction,
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
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 6))],
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
                      onPressed: (){}, // 4. Assign your action to onPressed
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
              SizedBox(width:18),
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

