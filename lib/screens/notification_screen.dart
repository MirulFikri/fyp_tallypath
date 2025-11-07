import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<NotificationItem> notifications = [
    NotificationItem(
      title: 'Payment Received',
      message: 'Sarah paid you RM 200.00 for dinner',
      time: '2 hours ago',
      isRead: false,
      icon: Icons.account_balance_wallet,
      iconColor: Color(0xFF00D4AA),
    ),
    NotificationItem(
      title: 'Payment Reminder',
      message: 'John is waiting for your payment of RM 150.00',
      time: '5 hours ago',
      isRead: false,
      icon: Icons.notification_important,
      iconColor: Colors.orange,
    ),
    NotificationItem(
      title: 'Group Activity',
      message: 'You were added to "Weekend Trip" group',
      time: '1 day ago',
      isRead: true,
      icon: Icons.group_add,
      iconColor: Colors.blue,
    ),
    NotificationItem(
      title: 'Savings Goal',
      message: 'You reached 70% of your "New Laptop" goal!',
      time: '2 days ago',
      isRead: true,
      icon: Icons.savings,
      iconColor: Color(0xFF00D4AA),
    ),
    NotificationItem(
      title: 'Payment Sent',
      message: 'Your payment of RM 45.50 to Group Dinner was successful',
      time: '3 days ago',
      isRead: true,
      icon: Icons.check_circle,
      iconColor: Colors.green,
    ),
    NotificationItem(
      title: 'New Group Request',
      message: 'Mike invited you to join "House Rent" group',
      time: '4 days ago',
      isRead: true,
      icon: Icons.mail,
      iconColor: Colors.purple,
    ),
  ];

  void _markAsRead(int index) {
    setState(() {
      notifications[index].isRead = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification.isRead = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications.where((n) => !n.isRead).length;

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
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: Color(0xFF00D4AA),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                if (unreadCount > 0) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      'New ($unreadCount)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  ...notifications
                      .asMap()
                      .entries
                      .where((entry) => !entry.value.isRead)
                      .map((entry) => _buildNotificationItem(
                            entry.value,
                            entry.key,
                          ))
                      .toList(),
                  const SizedBox(height: 24),
                ],
                if (notifications.any((n) => n.isRead)) ...[
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      'Earlier',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  ...notifications
                      .asMap()
                      .entries
                      .where((entry) => entry.value.isRead)
                      .map((entry) => _buildNotificationItem(
                            entry.value,
                            entry.key,
                          ))
                      .toList(),
                ],
              ],
            ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : const Color(0xFFD4F4ED),
        borderRadius: BorderRadius.circular(16),
        border: notification.isRead
            ? null
            : Border.all(
                color: const Color(0xFF00D4AA).withOpacity(0.3),
                width: 2,
              ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (!notification.isRead) {
              _markAsRead(index);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: notification.iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    notification.icon,
                    color: notification.iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: notification.isRead
                                    ? FontWeight.w600
                                    : FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF00D4AA),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.time,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationItem {
  final String title;
  final String message;
  final String time;
  bool isRead;
  final IconData icon;
  final Color iconColor;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.icon,
    required this.iconColor,
  });
}
