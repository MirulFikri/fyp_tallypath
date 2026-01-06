import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp_tallypath/api.dart';
import 'package:fyp_tallypath/globals.dart';
import 'package:fyp_tallypath/screens/group_info_screen.dart';
import 'package:fyp_tallypath/screens/group_main_screen.dart';
import 'package:fyp_tallypath/screens/personal_spending_screen.dart';
import 'package:fyp_tallypath/user_data.dart';
import 'package:fyp_tallypath/auth_service.dart';
import 'package:provider/provider.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  @override
  void initState() {
    UserData().updateGroupList();
    super.initState();
  }
Widget balanceList(List<dynamic> balance, int groupIndex) {
    List<Widget> w = [];
    var isSettled = true;
    var d = balance.where((b) => b["debtor"] == UserData().id).length;
    var c = balance.where((b) => b["creditor"] == UserData().id).length;

    for (var b in balance) {
      if (b["debtor"] == UserData().id) {
        isSettled = false;
        return SafeArea(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 190, 190),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "$d Pending Debt",
                        style: TextStyle(color: const Color.fromARGB(255, 255, 105, 94), fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
      } else if (b["creditor"] == UserData().id) {
        isSettled = false;
        return SafeArea(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 216, 255, 196),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "$c Pending Credit",
                        style: TextStyle(color: Color.fromARGB(255, 46, 212, 0), fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
      }
    }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text("Settled", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 14)),
      );
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
              Text(
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PersonalSpendingScreen()));
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
                          Text(
                            Globals.formatCurrency(Provider.of<UserData>(context).groupList[0]["total"]/100),
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
              
              Column(children: _buildGroupCardList()),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGroupCardList() {
    List<Widget> widgets = [];
    int index = 0;
    for (final group in Provider.of<UserData>(context).groupList) {
      if (index == 0) {
        index++;
        continue;
      }
      widgets.add(_buildGroupCard(UserData().balanceList[index],group['name'],"${group['members'].length} members",group['total'],[], Icons.group, index));
      index++;
    }

    return widgets;
  }

  Widget _buildGroupCard(
    dynamic balance,
    String title,
    String members,
    int totalAmount,
    List<Widget> status,
    IconData icon,
    [int index = 0]
  ) {
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(220, 255, 255, 255),
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap:(){
          Navigator.push(context, MaterialPageRoute(builder: (context) => GroupMainScreen(groupIndex : index)));
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

              balanceList(balance, index)
            ],
          ),
          // const SizedBox(height: 16),
          // const Divider(),
          // const SizedBox(height: 12),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text(
          //           'Total',
          //           style: TextStyle(
          //             fontSize: 12,
          //             color: Colors.grey[600],
          //           ),
          //         ),
          //         Text(
          //           Globals.formatCurrency(totalAmount/100),
          //           style: const TextStyle(
          //             fontSize: 18,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //       ],
          //     ),
          //     balanceList(balance, index),
          //   ],
          // ),
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
      final res = await authClient.post(
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
            setState(() {
              UserData().updateGroupList();
            });
              await UserData().updateGroupList();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Successfully created group!")));
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => GroupInfoScreen(groupId: data["id"])));
            }
          }
      } else {
        ScaffoldMessenger.of(context,).showSnackBar(SnackBar(content: Text("Network Error")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context,).showSnackBar(SnackBar(content: Text("Network Error")));
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
      final res = await authClient.post(
        url,
        headers: <String, String>{
          "Content-Type": "application/json",
          "Authorization": "Bearer ${UserData().token}",
        },
      );

      if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data != null) {
            if (mounted) {
              await UserData().updateGroupList();
              setState((){UserData().updateGroupList();});
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Successfully joined group!")));
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => GroupInfoScreen(groupId: data["groupId"])));
            }
          }
      } else {
        print("Status Code: Error ${res.statusCode}");
        ScaffoldMessenger.of(context,).showSnackBar(SnackBar(content: Text("Network Error")));
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context,).showSnackBar(SnackBar(content: Text("Network Error")));
    }finally{
      setState(() { _isLoading = false;});
    }

  }
}
