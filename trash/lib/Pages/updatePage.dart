import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class updatePage extends StatefulWidget {
  final String currentAddress;
  final String currentImageUrl;
  final String docId;

  const updatePage({
    Key? key,
    required this.currentAddress,
    required this.currentImageUrl,
    required this.docId,
  }) : super(key: key);

  @override
  State<updatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<updatePage> {
  late TextEditingController _addressController;
  late String docId;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.currentAddress);
    docId = widget.docId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.green[800],
        title: Text(
          'Update Report',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(widget.currentImageUrl),
            SizedBox(height: 20),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Update Address',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String updatedAddress = _addressController.text;
                await FirebaseFirestore.instance
                    .collection('reports')
                    .doc(docId)
                    .update({
                  'address': updatedAddress,
                });
                Navigator.pop(context, updatedAddress);
              },
              child: Text(
                'Update',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
