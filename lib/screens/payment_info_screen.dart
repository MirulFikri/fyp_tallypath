import 'dart:io';
import 'package:fyp_tallypath/api.dart';
import 'package:fyp_tallypath/user_data.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';


class PaymentInfoScreen extends StatefulWidget {
  const PaymentInfoScreen ({super.key});

  @override
  State<PaymentInfoScreen> createState() => _PaymentInfoScreenState();
}

class _PaymentInfoScreenState extends State<PaymentInfoScreen> {
List<Map<String,dynamic>> paymentInfo = [
  {"title": "Cash", "isEnabled":true, "detail":"", "imageLink":"", "publicId":""},
  ];
  String dispImageLink = "";
  int selectedPayment = 0;
  bool isLoading = false;
  bool isEditing = false;
  String details = "Bank Transfer:\nABC BANK\n1234123412\n\nQR Payment: ";
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<File> _images = [];


@override
void initState(){
  _controller.value = TextEditingValue(text:details);
  super.initState();
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
              // SizedBox(height:16),
              // Container(
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(16),
              //     boxShadow: [
              //       BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
              //     ],
              //   ),
              //   child: Theme(
              //     data: Theme.of(context).copyWith(
              //       dividerColor: Colors.transparent, // remove default divider
              //     ),
              //     child: ExpansionTile(
              //       initiallyExpanded: true,
              //       maintainState: true,
              //       tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              //       childrenPadding: const EdgeInsets.only(bottom: 12),
              //       iconColor: Colors.grey.shade600,
              //       collapsedIconColor: Colors.grey.shade600,
              //       title: Row(
              //         children: [
              //           Text(
              //             'Payment Options',
              //             style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              //           ),
              //         ],
              //       ),
              //       children: [const Divider(height: 1), ..._buildPaymentList()],
              //     ),
              //   ),
              // ),
              isEditing ? buildUpdateDetail(): showPaymentDetails(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPaymentList() {
    List<Widget> w = [];
    for(var i = 0; i < paymentInfo.length; i++){
      w.add(_buildPaymentItem(paymentInfo[i]["title"], paymentInfo[i]["isEnabled"], i));
    }

    return w;
  }

  Widget _buildPaymentItem(
    String title,
    bool isEnabled,
    int index,
  ) {
    return InkWell(child:Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: selectedPayment == index ?  const Color.fromARGB(255, 238, 255, 247): Colors.white,
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
            child: Icon(Icons.payment, color: const Color(0xFF00D4AA)),
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
              ],
            ),
          ),
          isEnabled ? Icon(Icons.done) : SizedBox(),
        ],
      ),
    ),
    onTap:(){
      setState((){selectedPayment = index;});
    }
    );
  }

 
  Widget showPaymentDetails() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          const SizedBox(width: 12),
          Row(
            children: [
              Text(
                'Payment Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Expanded(child: SizedBox(height: 4)),
            ],
          ),
          Divider(),
          const SizedBox(width: 12),
          Text(details, ),
          const SizedBox(width: 12),
          Column(children:[...imagesBuilder(_images)]),
          const SizedBox(height: 16),
          ElevatedButton(child:Text("Update", style: TextStyle(color: Colors.white)), onPressed: (){
            setState((){
              isEditing = true;
            });
          })
        ],
      ),
    );
  }




  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _submit() {
    final text = _controller.text.trim();

    details = text;

    setState((){isEditing = false;});
  }

  List<Widget> imagesBuilder(List<File> images){
    List<Widget> w = [];
    for(var i in images){
      w.add(Image.file(
            i!,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
      ));
    } 
    return w;
  }

  Widget buildUpdateDetail() {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Payment Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            // 📝 Text input
            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: InputDecoration(
                fillColor: const Color.fromARGB(255, 234, 255, 246),
                hintText: 'How can people pay you...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 12),

            // 🖼 Image previews
            if (_images.isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(_images[index], width: 80, height: 80, fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black54,
                              child: Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

            const SizedBox(height: 12),

            // 🔘 Actions
            Row(
              children: [
                IconButton(icon: const Icon(Icons.image_outlined), onPressed: _pickImage),
                const Spacer(),
                ElevatedButton(onPressed: _submit, child: const Text('Submit', style: TextStyle(color: Colors.white))),
              ],
            ),
          ],
        ),
      ),
    );
  }


}

