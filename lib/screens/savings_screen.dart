import 'package:flutter/material.dart';
import 'package:fyp_tallypath/api.dart';
import 'package:fyp_tallypath/globals.dart';
import 'savings_detail_screen.dart';
import 'create_goal_screen.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> with RouteAware{
  String selectedFilter = 'All'; // All, Active, Completed

  @override
  void initState() {
    _loadUserGoals();
    super.initState();
  }

  void _loadUserGoals()async{
    try{
      final goals = await Api.getUserPlans();
      setState(() {
        allGoals = [...goals];
      });
    }catch(e){
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Network Error")));
    }
  }

  //  subscribe/unsubscribe to route observer
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    // This page was pushed
    _loadUserGoals();
  }

  @override
  void didPopNext() {
    // Returned to this page (another page popped)
    _loadUserGoals();
  }


  // All savings goals - simple structure
  List<Map<String, dynamic>> allGoals = [

  ];

  // Filter goals based on selected filter
  List<Map<String, dynamic>> get filteredGoals {
    if (selectedFilter == 'Active') {
      return allGoals.where((goal) {
        double progress = goal['current'] / goal['target'];
        return progress < 1.0;
      }).toList();
    } else if (selectedFilter == 'Completed') {
      return allGoals.where((goal) {
        double progress = goal['current'] / goal['target'];
        return progress >= 1.0;
      }).toList();
    }
    return allGoals; // All
  }

  // Calculate total savings from all goals
  double get totalSavings {
    return allGoals.fold(0.0, (sum, goal) => sum + goal['current']);
  }

  // Calculate total target from all goals
  double get totalTarget {
    return allGoals.fold(0.0, (sum, goal) => sum + goal['target']);
  }

  // Calculate number of active goals (goals with progress < 100%)
  int get activeGoals {
    return allGoals.where((goal) {
      double progress = goal['current'] / goal['target'];
      return progress < 1.0;
    }).length;
  }

  // Calculate completed goals (goals with progress >= 100%)
  int get completedGoals {
    return allGoals.where((goal) {
      double progress = goal['current'] / goal['target'];
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
                      Globals.formatCurrency(totalSavings/100),
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
                        _buildSavingsStat('Target', Globals.formatCurrency(totalTarget/100)),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white30,
                        ),
                        _buildSavingsStat('Active', '$activeGoals'),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white30,
                        ),
                        _buildSavingsStat('Completed', '$completedGoals'),
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
              
              // Savings Goals
              ...filteredGoals.map((goal) => _buildSavingsCard(goal)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateGoalScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF00D4AA),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Goal',
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

  Widget _buildSavingsCard(Map<String, dynamic> goal) {
    final tempIcon = Icons.savings_outlined;
    double progress = goal['current'] / goal['target'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SavingsDetailScreen(plan: goal),
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
                  child: Icon(tempIcon, color: const Color(0xFF00D4AA)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                        goal['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(children: [
                      Text(
                        goal['due']==null ? "Not Set" : getDeadlineText(Globals.parseDateToLocal(goal['due'])),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(width:8),
                      goal["hasReminder"] ? Icon(Icons.notifications_active, size: 16, color: Colors.grey[600]) : SizedBox(),
                      ],)
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
                  Globals.formatCurrency(goal['current']/100),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00D4AA),
                  ),
                ),
                Text(
                  'of ${Globals.formatCurrency(goal['target']/100)}',
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
