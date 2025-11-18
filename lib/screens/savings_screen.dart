import 'package:flutter/material.dart';
import 'savings_detail_screen.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  String selectedFilter = 'All'; // All, Active, Completed

  // Number formatter with comma separators
  String formatCurrency(double amount) {
    // Simple implementation without external package
    String amountStr = amount.toStringAsFixed(2);
    List<String> parts = amountStr.split('.');
    String integerPart = parts[0];
    String decimalPart = parts[1];
    
    // Add commas to integer part
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

  // All savings goals - simple structure
  final List<Map<String, dynamic>> allPlans = [
    {
      'title': 'New Laptop',
      'target': 3000.00,
      'current': 2100.00,
      'deadline': DateTime(2025, 12, 31),
      'icon': Icons.laptop_mac,
    },
    {
      'title': 'Emergency Fund',
      'target': 10000.00,
      'current': 4500.00,
      'deadline': DateTime(2026, 6, 30),
      'icon': Icons.security,
    },
    {
      'title': 'Vacation Trip',
      'target': 5000.00,
      'current': 1200.00,
      'deadline': DateTime(2026, 3, 15),
      'icon': Icons.flight,
    },
    {
      'title': 'General Savings',
      'target': 2000.00,
      'current': 800.00,
      'deadline': null, // No deadline
      'icon': Icons.account_balance_wallet,
    },
    {
      'title': 'Investment Fund',
      'target': 5000.00,
      'current': 1500.00,
      'deadline': DateTime(2027, 6, 30),
      'icon': Icons.trending_up,
    },
  ];

  // Filter plans based on selected filter
  List<Map<String, dynamic>> get filteredPlans {
    if (selectedFilter == 'Active') {
      return allPlans.where((plan) {
        double progress = plan['current'] / plan['target'];
        return progress < 1.0;
      }).toList();
    } else if (selectedFilter == 'Completed') {
      return allPlans.where((plan) {
        double progress = plan['current'] / plan['target'];
        return progress >= 1.0;
      }).toList();
    }
    return allPlans; // All
  }

  // Calculate total savings from all plans
  double get totalSavings {
    return allPlans.fold(0.0, (sum, plan) => sum + plan['current']);
  }

  // Calculate total target from all plans
  double get totalTarget {
    return allPlans.fold(0.0, (sum, plan) => sum + plan['target']);
  }

  // Calculate number of active plans (plans with progress < 100%)
  int get activePlans {
    return allPlans.where((plan) {
      double progress = plan['current'] / plan['target'];
      return progress < 1.0;
    }).length;
  }

  // Calculate completed plans (plans with progress >= 100%)
  int get completedPlans {
    return allPlans.where((plan) {
      double progress = plan['current'] / plan['target'];
      return progress >= 1.0;
    }).length;
  }

  // Format deadline display
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F9F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Savings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Savings Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D4AA), Color(0xFF00A885)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Savings',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatCurrency(totalSavings),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSavingsStat('Target', formatCurrency(totalTarget).substring(3)),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white30,
                        ),
                        _buildSavingsStat('Active', '$activePlans'),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white30,
                        ),
                        _buildSavingsStat('Completed', '$completedPlans'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Filter Chips
              Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Active'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completed'),
                ],
              ),
              const SizedBox(height: 24),
              
              // Savings Plans
              ...filteredPlans.map((plan) => _buildSavingsCard(plan)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF00D4AA),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Plan',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSavingsStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00D4AA) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF00D4AA) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSavingsCard(Map<String, dynamic> plan) {
    double progress = plan['current'] / plan['target'];
    DateTime? deadline = plan['deadline'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SavingsDetailScreen(plan: plan),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4F4ED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(plan['icon'], color: const Color(0xFF00D4AA)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        getDeadlineText(deadline),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progress section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatCurrency(plan['current']),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00D4AA),
                  ),
                ),
                Text(
                  'of ${formatCurrency(plan['target'])}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: const Color(0xFFD4F4ED),
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0 ? Colors.green : const Color(0xFF00D4AA),
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toInt()}% completed',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
