
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fyp_tallypath/api.dart';
import 'package:fyp_tallypath/globals.dart';
import 'package:fyp_tallypath/user_data.dart';

class AddSettlementDialog extends StatefulWidget {
  final String groupId;
  final String userId;
  final bool isWaive;
  final int amount;
  const AddSettlementDialog({super.key,required this.amount, required this.groupId, required this.userId,  this.isWaive = false});

  @override
  State<AddSettlementDialog> createState() => _AddSettlementDialogState();
}

class _AddSettlementDialogState extends State<AddSettlementDialog> {
  final TextEditingController titleController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  int amt = 0;
  dynamic group = {};

  @override
  void initState() {
    group = UserData().groupList.firstWhere((g) => g["groupId"] == widget.groupId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: widget.isWaive ? Text('Waive', textAlign: TextAlign.center,) : Text('Payment', textAlign: TextAlign.center,),
      titleTextStyle: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.isWaive ? SizedBox() : const Text('Payment Option', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              widget.isWaive ? SizedBox() : const SizedBox(height: 8),
              widget.isWaive ? SizedBox() : TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  hintText: 'Cash',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00D4AA)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Payment Option can't be empty";
                  }
                  return null;
                },
              ),
              SizedBox(height:16),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Amount Lent', style: TextStyle(color: Color.fromARGB(255, 0, 56, 45), fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      Globals.formatCurrency(widget.amount / 100),
                      style: const TextStyle(color: Colors.green, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
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
            titleController.clear();
            Navigator.pop(context);
          },
          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        FloatingActionButton.extended(
          heroTag: null,
          backgroundColor: const Color(0xFF00D4AA),
          label: Text(widget.isWaive ? "WAIVE" : "PAID", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 16)),
          onPressed: () async {
            if(formKey.currentState!.validate()){
              if(widget.isWaive){

              }else{

              }
              var splits = [
                {
                  "userId": widget.isWaive ? UserData().id : widget.userId,
                  "share": widget.amount} 
              ];
              final String body = jsonEncode({
                "groupId": widget.groupId,
                "title": widget.isWaive ? "Waived@${UserData().id}"
                          : "Payment@${titleController.text.trim()}@${widget.userId}",
                "amount": widget.amount,
                "paidBy": widget.isWaive ? widget.userId : UserData().id,
                "splits": splits,
                "isStatement":true
              });

              try {
                await Api.createExpense(body, widget.groupId);
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
        ),
      ],
    );
  }
}
