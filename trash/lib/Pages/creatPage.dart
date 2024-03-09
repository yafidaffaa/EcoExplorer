import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class createPage extends StatefulWidget {
  const createPage({Key? key});

  @override
  State<createPage> createState() => _CreatePageState();
}

class _CreatePageState extends State<createPage> {
  late TextEditingController _addressController;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController();
  }

  Future _getImageFromCamera() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) return;
    setState(() {
      _selectedImage = File(image.path);
    });
  }

  Future<void> _getImageFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      _selectedImage = File(image.path);
    });
  }

  Future<void> _uploadImageAndAddress() async {
    try {
      final address = _addressController.text;
      final timestamp = Timestamp.now();

      final imageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await imageRef.putFile(_selectedImage!);

      final imageUrl = await imageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('reports').add({
        'imageUrl': imageUrl,
        'address': address,
        'timestamp': timestamp,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report submitted successfully')),
      );
    } catch (e) {
      print('Error submitting report: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Report Trash',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[800],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _getImageFromCamera();
                  },
                  icon: Icon(Icons.camera_alt, color: Colors.white),
                  label: Text(
                    'Camera',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _getImageFromGallery,
                  icon: Icon(
                    Icons.image,
                    color: Colors.white,
                  ),
                  label: Text('Gallery', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _selectedImage != null
                ? Image.file(_selectedImage!)
                : Text("No images have been captured yet"),
            SizedBox(height: 20),
            TextField(
              controller: _addressController,
              maxLines: null,
              minLines: 1,
              decoration: InputDecoration(
                labelText: 'Enter Address',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedImage != null ? _uploadImageAndAddress : null,
              child: Text('Report', style: TextStyle(color: Colors.white)),
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
