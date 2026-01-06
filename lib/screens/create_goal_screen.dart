import 'package:flutter/material.dart';
import 'package:fyp_tallypath/api.dart';
import 'package:fyp_tallypath/globals.dart';
import 'package:number_editing_controller/number_editing_controller.dart';

class CreateGoalScreen extends StatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final TextEditingController titleController = TextEditingController();
  final NumberEditingTextController targetController = NumberEditingTextController.currency(
    currencyName: 'MYR',
    allowNegative: false,
  );
  DateTime? selectedDeadline;
  IconData selectedIcon = Icons.savings;
  int interval = 1, intervalDays = 1; 
  String reminder = "";
  bool hasReminder = false;

  // Available goal icons
  final List<Map<String, dynamic>> goalIcons = [
    {'icon': Icons.laptop_mac, 'label': 'Laptop'},
    {'icon': Icons.security, 'label': 'Emergency Fund'},
    {'icon': Icons.flight, 'label': 'Vacation'},
    {'icon': Icons.account_balance_wallet, 'label': 'General Savings'},
    {'icon': Icons.trending_up, 'label': 'Investment'},
    {'icon': Icons.home, 'label': 'House'},
    {'icon': Icons.car_rental, 'label': 'Car'},
    {'icon': Icons.shopping_bag, 'label': 'Shopping'},
    {'icon': Icons.school, 'label': 'Education'},
    {'icon': Icons.favorite, 'label': 'Personal'},
    {'icon': Icons.music_note, 'label': 'Music Equipment'},
    {'icon': Icons.sports_baseball, 'label': 'Sports'},
  ];

  String formatCurrency(double amount) {
    String amountStr = amount.toStringAsFixed(2);
    List<String> parts = amountStr.split('.');
    String integerPart = parts[0];
    String decimalPart = parts[1];
    
    String result = '';
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = ',$result';
        count = 0;
      }
      result = integerPart[i] + result;
      count++;
    }
    
    return 'RM $result.$decimalPart';
  }

  Future<void> _selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDeadline) {
      setState(() {
        selectedDeadline = picked;
      });
    }
  }

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Goal Icon',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: goalIcons.length,
                itemBuilder: (context, index) {
                  final iconData = goalIcons[index];
                  final bool isSelected = selectedIcon == iconData['icon'];
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIcon = iconData['icon'];
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF00D4AA)
                            : const Color(0xFFD4F4ED),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(
                                color: const Color(0xFF00D4AA),
                                width: 2,
                              )
                            : null,
                      ),
                      child: Icon(
                        iconData['icon'],
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF00D4AA),
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _createGoal() async {
    // Validate inputs
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a goal title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    double? target = targetController.number?.toDouble();
    if (target == null || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid target amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    //use integer cents format before uploading to database
    target *= 100;
    String r = hasReminder ? "${Globals.formatCurrency(target/interval/100)} $reminder" : "";


    String? due = Globals.parseDateToUtc(selectedDeadline);
    if(due != null) due = "\"$due\"";
    // Create goal object
    final newGoal = """{
      "title": "${titleController.text}",
      "target": ${target.toInt()},
      "current": 0,
      "due": $due,
      "hasReminder": $hasReminder,
      "reminder": "$r"
      }
    """;

    try{
      await Api.createPlan(newGoal);
    }catch(e){
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Network Error')));
    }

    Navigator.pop(context, newGoal);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Goal "${titleController.text}" created successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F9F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create New Goal',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Selection
              Center(
                child: GestureDetector(
                  onTap: _showIconPicker,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF00D4AA),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          selectedIcon,
                          size: 64,
                          color: const Color(0xFF00D4AA),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap to change icon',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Goal Title
              const Text(
                'Goal Title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'e.g., New Laptop',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF00D4AA),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Target Amount
              const Text(
                'Target Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: targetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged:(value){
                  setState((){
                    hasReminder = !hasReminder;
                    hasReminder = !hasReminder;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'RM0.00',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF00D4AA),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Deadline
              const Text(
                'Target Deadline (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectDeadline,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedDeadline != null
                          ? const Color(0xFF00D4AA)
                          : Colors.grey.shade300,
                      width: selectedDeadline != null ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF00D4AA),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedDeadline != null
                              ? '${selectedDeadline!.day}/${selectedDeadline!.month}/${selectedDeadline!.year}'
                              : 'Select a date',
                          style: TextStyle(
                            fontSize: 14,
                            color: selectedDeadline != null
                                ? Colors.black
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Row(
                    //   children: [
                        IntervalSelector(
                          onChanged: (value) {
                            if(!value.enabled)return;
                            setState((){
                              selectedDeadline = value.getDeadline();
                              interval = value.amount;
                              hasReminder = value.enabled;
                              intervalDays = value.amount * value.unit.days;
                              reminder = value.toString();
                            });
                          },
                        ),
                        // Expanded(child:SizedBox()),
                      // ],
                    // ),
                    hasReminder ? Text("Recurring Amount:\n${Globals.formatCurrency((targetController.number??0).toInt()/interval)}", textAlign: TextAlign.center,) : SizedBox(),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Create Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createGoal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D4AA),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Create Goal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IntervalSelector extends StatefulWidget {
  const IntervalSelector({super.key, this.onChanged});

  final void Function(IntervalValue value)? onChanged;

  @override
  State<IntervalSelector> createState() => _IntervalSelectorState();
}

class _IntervalSelectorState extends State<IntervalSelector> {
  bool _enabled = false;
  IntervalUnit _unit = IntervalUnit.daily;
  int _amount = 1;

  final _controller = TextEditingController(text: '1');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged?.call(IntervalValue(_amount, _unit, _enabled));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: Colors.white70,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.greenAccent)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Switch.adaptive(
                  value: _enabled,
                  onChanged: (v) {
                    setState(() => _enabled = v);
                    if (v) _notify();
                  },
                ),
                Text('  Add Reminder', style: theme.textTheme.titleMedium),
                Expanded(child: SizedBox()),
                Icon(Icons.notification_add)
              ],
            ),
            const SizedBox(height: 12),

            /// Segmented control (Daily / Weekly / Monthly)
            Opacity(
              opacity: _enabled ? 1 : 0.4,
              child: IgnorePointer(
                ignoring: !_enabled,
                child: SegmentedButton<IntervalUnit>(
              segments: const [
                ButtonSegment(value: IntervalUnit.daily, label: Text('Daily')),
                ButtonSegment(value: IntervalUnit.weekly, label: Text('Weekly')),
                ButtonSegment(value: IntervalUnit.monthly, label: Text('Monthly')),
              ],
              selected: {_unit},
              onSelectionChanged: (value) {
                setState(() => _unit = value.first);
                _notify();
              },
            ),
              ),
            ),

            const SizedBox(height: 16),

            /// Amount selector
            Opacity(
              opacity: _enabled ? 1 : 0.4,
              child: IgnorePointer(
                ignoring: !_enabled,
                child: Row(
                  children: [
                IconButton.filledTonal(
                  icon: const Icon(Icons.remove),
                  onPressed: _amount > 1
                      ? () {
                          setState(() {
                            _amount--;
                            _controller.text = _amount.toString();
                          });
                          _notify();
                        }
                      : null,
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onChanged: (v) {
                      final parsed = int.tryParse(v);
                      if (parsed != null && parsed >= 1) {
                        setState(() => _amount = parsed);
                        _notify();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      _amount++;
                      _controller.text = _amount.toString();
                    });
                    _notify();
                  },
                ),
                const SizedBox(width: 12),
                Text(_unit.label),
                  ],
                ),
              ),
        )],
        ),
      ),
    );
  }
}

/// Value object you can store or send to backend
class IntervalValue {
  final int amount;
  final IntervalUnit unit;
  final bool enabled;

  const IntervalValue(this.amount, this.unit, this.enabled);

  @override
  String toString() => 'x $amount ${unit.label}';
  DateTime getDeadline() => DateTime.now().add(Duration(days: amount * unit.days));
}

enum IntervalUnit { daily, weekly, monthly }

extension IntervalUnitLabel on IntervalUnit {
  String get label {
    switch (this) {
      case IntervalUnit.daily:
        return 'day(s)';
      case IntervalUnit.weekly:
        return 'week(s)';
      case IntervalUnit.monthly:
        return 'month(s)';
    }
  }
}
extension IntervalUnitDays on IntervalUnit {
  int get days{
    switch (this) {
      case IntervalUnit.daily:
        return 1;
      case IntervalUnit.weekly:
        return 7;
      case IntervalUnit.monthly:
        return 30;
    }
  }
}

/// Example usage:
/// IntervalSelector(
///   onChanged: (value) {
///     debugPrint(value.toString());
///   },
/// )
