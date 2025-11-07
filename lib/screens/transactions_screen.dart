import 'package:flutter/material.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _transactions = [
    {
      'title': 'Grocery Store',
      'category': 'Food & Dining',
      'amount': -85.50,
      'date': DateTime.now(),
      'icon': Icons.shopping_cart,
      'color': Colors.orange,
    },
    {
      'title': 'Salary',
      'category': 'Income',
      'amount': 5000.00,
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'icon': Icons.work,
      'color': Colors.green,
    },
    {
      'title': 'Netflix Subscription',
      'category': 'Entertainment',
      'amount': -15.99,
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'icon': Icons.movie,
      'color': Colors.red,
    },
    {
      'title': 'Uber Ride',
      'category': 'Transportation',
      'amount': -22.50,
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'icon': Icons.local_taxi,
      'color': Colors.blue,
    },
    {
      'title': 'Freelance Project',
      'category': 'Income',
      'amount': 1500.00,
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'icon': Icons.computer,
      'color': Colors.green,
    },
    {
      'title': 'Restaurant',
      'category': 'Food & Dining',
      'amount': -68.75,
      'date': DateTime.now().subtract(const Duration(days: 6)),
      'icon': Icons.restaurant,
      'color': Colors.orange,
    },
    {
      'title': 'Electricity Bill',
      'category': 'Bills & Utilities',
      'amount': -120.00,
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'icon': Icons.bolt,
      'color': Colors.amber,
    },
    {
      'title': 'Amazon Purchase',
      'category': 'Shopping',
      'amount': -245.99,
      'date': DateTime.now().subtract(const Duration(days: 8)),
      'icon': Icons.shopping_bag,
      'color': Colors.purple,
    },
  ];

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_selectedFilter == 'All') {
      return _transactions;
    } else if (_selectedFilter == 'Income') {
      return _transactions.where((t) => t['amount'] > 0).toList();
    } else {
      return _transactions.where((t) => t['amount'] < 0).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Handle filter
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedFilter == 'All',
                  onTap: () {
                    setState(() {
                      _selectedFilter = 'All';
                    });
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Income',
                  isSelected: _selectedFilter == 'Income',
                  onTap: () {
                    setState(() {
                      _selectedFilter = 'Income';
                    });
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Expense',
                  isSelected: _selectedFilter == 'Expense',
                  onTap: () {
                    setState(() {
                      _selectedFilter = 'Expense';
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Transaction List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = _filteredTransactions[index];
                return _TransactionCard(
                  title: transaction['title'],
                  category: transaction['category'],
                  amount: transaction['amount'],
                  date: transaction['date'],
                  icon: transaction['icon'],
                  color: transaction['color'],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(label),
        backgroundColor: isSelected
            ? const Color(0xFF4CAF50)
            : Colors.grey[200],
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final IconData icon;
  final Color color;

  const _TransactionCard({
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.icon,
    required this.color,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = amount > 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '$category • ${_formatDate(date)}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}\$${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        onTap: () {
          // Show transaction details
          showModalBottomSheet(
            context: context,
            builder: (context) => _TransactionDetailSheet(
              title: title,
              category: category,
              amount: amount,
              date: date,
              icon: icon,
              color: color,
            ),
          );
        },
      ),
    );
  }
}

class _TransactionDetailSheet extends StatelessWidget {
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final IconData icon;
  final Color color;

  const _TransactionDetailSheet({
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = amount > 0;
    
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                radius: 30,
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      category,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _DetailRow(
            label: 'Amount',
            value: '${isIncome ? '+' : '-'}\$${amount.abs().toStringAsFixed(2)}',
            valueColor: isIncome ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            label: 'Date',
            value: '${date.day}/${date.month}/${date.year}',
          ),
          const SizedBox(height: 12),
          _DetailRow(
            label: 'Type',
            value: isIncome ? 'Income' : 'Expense',
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Handle edit
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Handle delete
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transaction deleted'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
