import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp_tallypath/api.dart';
import 'package:fyp_tallypath/globals.dart';
import 'package:fyp_tallypath/user_data.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupInfoScreen extends StatefulWidget {
  final String groupId;
  const GroupInfoScreen ({super.key, required this.groupId});

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  final DateFormat formatter = DateFormat('MMM dd');
dynamic group = {};
String inviteLink = "";
String inviteCode = "";
String expiryDate = "_";

@override
void initState(){
  group = UserData().groupList.firstWhere((g)=>g["groupId"] == widget.groupId);
  initGroup();
  super.initState();
}

  Future<void> initGroup() async {
    final prefs = await SharedPreferences.getInstance();

    var g = prefs.getString(group["groupId"]);
    if(g==null) return;

    var groupData = jsonDecode(g);

    setState((){
      inviteLink = groupData["inviteLink"];
      inviteCode = groupData["inviteCode"];
      expiryDate = groupData["expiryDate"];
    });
  }

  Future<void> _loadInvite() async{
    try{
      var res = await Api.createGroupInvite(group["groupId"]);

      setState((){
        inviteCode = res["inviteId"];
        inviteLink = res["deepLink"];
        expiryDate = res["expiresAt"];
      });
      //save locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        group["groupId"],
        jsonEncode({"inviteLink": inviteLink, "inviteCode": inviteCode, "expiryDate": expiryDate}),
      );
    }catch(e){
      debugPrint(e.toString());
    }
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFFD4F4ED),
                          child: const Icon(Icons.group, size: 40, color: Color(0xFF00D4AA)),
                        ),
                        SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group["name"] ?? 'loading..',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              group["description"] ?? "no description\n",
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              overflow: TextOverflow.ellipsis,
                          ),
                          ],
                        ),
                        Expanded(child: SizedBox()),
                        Column(
                          children: [
                          FloatingActionButton.extended(
                              backgroundColor: Colors.white70,
                              heroTag: null,
                              onPressed: (){
                                _loadInvite();
                              },
                              label: Icon(Icons.group_add_outlined, color: Colors.grey[800],)//Text(textAlign: TextAlign.center, "Generate\nInvites")
                              ),
                            SizedBox(height:8),
                            Text("Expires", style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                            Text(expiryDate == "_" ? "_" : formatter.format(Globals.parseDateToLocal(expiryDate)), style: TextStyle(color: Colors.grey[600], fontSize: 10))
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height:16),
              Row(
                children: [
                  Expanded(
                    child:               Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Invite Code',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Divider(thickness: 0.4, color: Colors.grey[600]),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(child: Text(
                                  overflow: TextOverflow.ellipsis,
                                  inviteCode, style: const TextStyle(fontSize: 14))),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                tooltip: "Copy to clipboard",
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: inviteCode));
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(const SnackBar(content: Text("Code copied!")));
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child:               Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Invite Link',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Divider(thickness: 0.4, color: Colors.grey[600]),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(child: Text(overflow: TextOverflow.ellipsis, inviteLink,style: const TextStyle(fontSize: 12))),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                tooltip: "Copy to clipboard",
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: inviteLink));
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(const SnackBar(content: Text("Link copied!")));
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height:16),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent, // remove default divider
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    maintainState: true,
                    tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    childrenPadding: const EdgeInsets.only(bottom: 12),
                    iconColor: Colors.grey.shade600,
                    collapsedIconColor: Colors.grey.shade600,
                    title: Row(
                      children: [
                        Text(
                          'Group Members',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    children: [const Divider(height: 1), ..._buildMemberList()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton:
      //   FloatingActionButton.extended(
      //     heroTag: null,
      //     onPressed: (){},
      //     backgroundColor: Colors.redAccent,
      //     label: Text("Leave",textAlign: TextAlign.center, style: TextStyle(fontSize: 20,color: Colors.white, fontWeight: FontWeight.bold)),
      //   ),
    );
  }

   List<Widget> _buildMemberList() {
    List<Widget> w = [];
    final DateFormat formatter = DateFormat("MMM, dd  HH:mm");
    final DateFormat formatterToday = DateFormat(" HH:mm");
    final DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

      for (var m in group["members"]) {
        var date = Globals.parseDateToLocal(m["joinedAt"]);
        w.add(
          _buildTransactionItem(
            m["nameInGroup"],
            m["isAdmin"], 
            date.isBefore(today) ? formatter.format(date) : "Today, ${formatterToday.format(date)}",
            Icons.person
          ),
        );
      }
    return w.reversed.toList();
  }

  Widget _buildTransactionItem(
    String title,
    bool isAdmin,
    String date,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: BoxBorder.all(width:0.4, color: const Color.fromARGB(214, 158, 158, 158))
            ),
            child: Icon(icon, color: const Color(0xFF00D4AA)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height:4),
                isAdmin ? Text(
                  "Admin",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ):SizedBox(),
              ],
            ),
          ),
          Column(children: [
          Text("Joined", style: TextStyle(color: Colors.grey[600], fontSize: 10)),
          Text(date, style: TextStyle(color: Colors.grey[600], fontSize: 10))
          ],)
        ],
      ),
    );
  }
}
