import 'package:flutter/material.dart';

class GroupMainScreen extends StatefulWidget {
  final Map<String, dynamic> plan;

  const GroupMainScreen({super.key, required this.plan});

  @override
  State<GroupMainScreen> createState() => _GroupMainScreenState();
}

class _GroupMainScreenState extends State<GroupMainScreen> {
  // Mock contribution history (will come from database later)

  @override
  Widget build(BuildContext context) {
    double progress = widget.plan['current'] / widget.plan['target'];
    DateTime? deadline = widget.plan['deadline'];

    return Scaffold(
      persistentFooterButtons: [BigAddButton(onPressed: () {}, height: 60)],
      backgroundColor: const Color(0xFFE8F9F5),
      appBar: AppBar(
        backgroundColor: Color(0xFF00D4AA),
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Text(
          widget.plan['title'],
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
                          child: Icon(
                            widget.plan['icon'],
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current Savings',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatCurrency(widget.plan['current']),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(progress * 100).toInt()}% completed',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Goal: ${formatCurrency(widget.plan['target'])}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    if (deadline != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            getDeadlineText(deadline),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [...contributions.map((contribution) => _buildContributionItem(contribution)),]
                  )
                ),
              ),

            ],
          ),
        ),

    );
  }

  Widget _buildContributionItem(Map<String, dynamic> contribution) {
    DateTime date = contribution['date'];
    String dateStr = '${date.day}/${date.month}/${date.year}';
    
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
              color: const Color(0xFFD4F4ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.add,
              color: Color(0xFF00D4AA),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contribution['note'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+${formatCurrency(contribution['amount'])}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF00D4AA),
            ),
          ),
        ],
      ),
    );
  }

    List<Map<String, dynamic>> contributions = [
    {'amount': 500.00, 'note': 'Initial deposit', 'date': DateTime(2025, 10, 1)},
    {'amount': 800.00, 'note': 'October savings', 'date': DateTime(2025, 10, 15)},
    {'amount': 300.00, 'note': 'Bonus monney', 'date': DateTime(2025, 11, 1)},
    {'amount': 500.00, 'note': 'November savings', 'date': DateTime(2025, 11, 10)},
        {'amount': 500.00, 'note': 'November savings', 'date': DateTime(2025, 11, 10)},
            {'amount': 500.00, 'note': 'November savings', 'date': DateTime(2025, 11, 10)},
                {'amount': 500.00, 'note': 'November savings', 'date': DateTime(2025, 11, 10)},
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

  String getDeadlineText(DateTime? deadline) {
    if (deadline == null) return 'No deadline';

    DateTime now = DateTime.now();
    int daysRemaining = deadline.difference(now).inDays;

    String dateStr = '${deadline.day}/${deadline.month}/${deadline.year}';

    if (daysRemaining < 0) {
      return '$dateStr (overdue)';
    } else if (daysRemaining == 0) {
      return '$dateStr (today)';
    } else if (daysRemaining <= 30) {
      return '$dateStr ($daysRemaining days left)';
    } else {
      return dateStr;
    }
  }

  void _showAddContributionDialog() {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Add to ${widget.plan['title']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Amount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixText: 'RM ',
                  hintText: '0.00',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00D4AA)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Note (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  hintText: 'e.g., November savings',
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
                    'Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                double? amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  // TODO: Save contribution to database
                  setState(() {
                    widget.plan['current'] += amount;
                    contributions.insert(0, {
                      'amount': amount,
                      'note': noteController.text.isEmpty ? 'Contribution' : noteController.text,
                      'date': DateTime.now(),
                    });
                  });

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added ${formatCurrency(amount)} to ${widget.plan['title']}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid amount'), backgroundColor: Colors.red),
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