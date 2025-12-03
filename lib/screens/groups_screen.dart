import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp_tallypath/globals.dart';
import 'package:fyp_tallypath/user_data.dart';
import 'package:http/http.dart' as http;

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F9F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Groups',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
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
              // Personal Spending Section
              const Text(
                'Personal Spending',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(220, 255, 255, 255),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: InkWell(
                  onTap:(){
                    print('tapped personal spending');
                  }, 
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Spent',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const Text(
                            'RM 1,234.00',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00D4AA),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      _buildPersonalItem(
                        'Groceries',
                        'RM 450.00',
                        Icons.shopping_cart,
                      ),
                      _buildPersonalItem(
                        'Transport',
                        'RM 234.00',
                        Icons.directions_car,
                      ),
                      _buildPersonalItem(
                        'Entertainment',
                        'RM 550.00',
                        Icons.movie,
                      ),
                    ],
                  )
                ),
              ),
              const SizedBox(height: 32),
              
              // Group Spending Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Group Spending',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(//create group button
                        onPressed: () {
                            showDialog(
                            context: context,
                            builder: (_) => CreateGroupDialog(),
                          );
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Create', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(//join group button
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => JoinGroupDialog(),
                          );
                        },
                        icon: const Icon(Icons.group_add, size: 18),
                        label: const Text('Join', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4F4ED),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildGroupCard(
                'Weekend Trip',
                '4 members',
                'RM 850.00',
                'You owe RM 212.50',
                Icons.landscape,
              ),
              _buildGroupCard(
                'House Rent',
                '3 members',
                'RM 1,500.00',
                'Settled',
                Icons.home,
              ),
              _buildGroupCard(
                'Study Group',
                '5 members',
                'RM 320.00',
                'You are owed RM 64.00',
                Icons.school,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF00D4AA),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPersonalItem(String title, String amount, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00D4AA), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(
    String title,
    String members,
    String totalAmount,
    String status,
    IconData icon,
  ) {
    final bool isSettled = status == 'Settled';
    final bool isOwed = status.contains('owed');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(220, 255, 255, 255),
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap:(){
          print('tapped $title');
        },
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
                child: Icon(icon, color: const Color(0xFF00D4AA)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      members,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    totalAmount,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSettled
                      ? Colors.green.withOpacity(0.1)
                      : isOwed
                          ? const Color(0xFF00D4AA).withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isSettled
                        ? Colors.green
                        : isOwed
                            ? const Color(0xFF00D4AA)
                            : Colors.orange,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      )
      )
    );
  }
}




class CreateGroupDialog extends StatefulWidget {
  const CreateGroupDialog({super.key});

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final _groupNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              "Create New Group",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Group name
            TextFormField(
              decoration: InputDecoration(
                labelText: "Group Name",
                border: OutlineInputBorder(),
              ),
              controller: _groupNameController,
              validator: (value){
                if (value == null || value.isEmpty) {
                  return 'Group name can\'t be empty';
                }
                return null;
              }
            ),

            const SizedBox(height: 12),

            // Description
            TextField(
              maxLines: 2,
              decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Search people
            TextField(
              decoration: InputDecoration(
                labelText: "Search people to invite",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              height: 100,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  "Search results appear here",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if(_formKey.currentState!.validate()){
                     _createGroupApi();
                    }
                  },
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Create'),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }

  Future<void> _createGroupApi() async{
    setState(() => _isLoading = true);
    final url = Uri.parse("${Globals.baseUrl}/api/groups/create");
    final String body = jsonEncode(<String, dynamic>{
      "name": _groupNameController.text.trim(),
      "memberIds": ["${UserData().id}"]
    });
    try {
      final res = await http.post(
        url,
        headers: <String, String>{
          "Content-Type": "application/json",
          "Authorization": "Bearer ${UserData().token}",
        },
        body: body,
      );

      if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data != null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Successfully created group!")));
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      width: 400,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${data["name"]} - INVITE CODE",
                            style: Theme.of(context).textTheme.titleLarge,
                            softWrap: true,
                          ),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: SelectableText(data["inviteCode"], style: const TextStyle(fontSize: 14)),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                tooltip: "Copy to clipboard",
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: data["inviteCode"]));
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(const SnackBar(content: Text("Code copied!")));
                                },
                              ),
                            ],
                          ),
                        
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.link), 
                              SizedBox(width:4),
                              Flexible(
                                child: SelectableText(data["deepLink"], style: const TextStyle(fontSize: 12)),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                tooltip: "Copy to clipboard",
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: data["deepLink"]));
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(const SnackBar(content: Text("Link copied!")));
                                },
                              ),
                            ],
                          ),
                        

                          const SizedBox(height: 30),

                          // Close button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Close"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          }
      } else {
        ScaffoldMessenger.of(context,).showSnackBar(SnackBar(content: Text("Error: ${res.body}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context,).showSnackBar(SnackBar(content: Text("Network error: $e")));
    }finally{
      setState(() { _isLoading = false;});
    }
  }

}



class JoinGroupDialog extends StatefulWidget {
  final String? defaultCode;
  const JoinGroupDialog({super.key, this.defaultCode});

  @override
  State<JoinGroupDialog> createState() => _JoinGroupDialogState();
}

class _JoinGroupDialogState extends State<JoinGroupDialog> {
  late final _inviteCodeController = TextEditingController(text: widget.defaultCode);
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              "Join Group",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Invite Code 
            TextFormField(
              decoration: InputDecoration(
                labelText: "Invite Code",
                border: OutlineInputBorder(),
              ),
              controller: _inviteCodeController,
              validator: (value){
                if (value == null || value.isEmpty) {
                  return 'invalid code';
                }
                return null;
              }
            ),

            const SizedBox(height: 12),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if(_formKey.currentState!.validate()){
                     _joinGroup();
                    }
                  },
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Join'),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }


  Future<void> _joinGroup() async{
    setState(() => _isLoading = true);
    final url = Uri.parse("${Globals.baseUrl}/api/groups/join/${_inviteCodeController.text.trim()}");
    try {
      final res = await http.post(
        url,
        headers: <String, String>{
          "Content-Type": "application/json",
          "Authorization": "Bearer ${UserData().token}",
        },
      );

      if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data != null) {
            debugPrint("response : ${data.toString()}");
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Successfully joined group!")));
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(),
                    child: Column(
                      children: [
                        SizedBox(height:20),
                        Text(data["message"]),
                        SizedBox(height:20),
                        Text("Group ID : ${data["groupId"]}"),
                        SizedBox(height:20),
                        Text("Group Name: ${data["groupName"]}"),
                        ElevatedButton(onPressed:(){Navigator.pop(context);}, child: Text("Close"))
                      ]
                    )
                  );
                },
              );
            }
          }
      } else {
        ScaffoldMessenger.of(context,).showSnackBar(SnackBar(content: Text("Error: ${res.body}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context,).showSnackBar(SnackBar(content: Text("Network error: $e")));
    }finally{
      setState(() { _isLoading = false;});
    }

  }
}
