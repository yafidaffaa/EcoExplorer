import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trash/Pages/updatePage.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class readPage extends StatefulWidget {
  const readPage({Key? key}) : super(key: key);

  @override
  State<readPage> createState() => _readPageState();
}

Future<void> deleteImage(String imageUrl) async {
  firebase_storage.Reference imageRef =
      firebase_storage.FirebaseStorage.instance.refFromURL(imageUrl);

  await imageRef.delete();
}

class _readPageState extends State<readPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Rubbish History',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('you haven\'t submitted a report yet'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              Map<String, dynamic>? data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>?;

              String imageUrl = data?['imageUrl'] ?? '';
              String address = data?['address'] ?? '';
              String docId = snapshot.data!.docs[index].id;

              return Card(
                margin: EdgeInsets.all(10),
                color: Colors.green[600],
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageUrl.isNotEmpty)
                          Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            address,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: PopupMenuButton(
                        icon: Icon(Icons.more_vert, color: Colors.green),
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            child: ListTile(
                              leading: Icon(Icons.edit, color: Colors.green),
                              title: Text('Update',
                                  style: TextStyle(color: Colors.green)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => updatePage(
                                      currentAddress: address,
                                      currentImageUrl: imageUrl,
                                      docId: docId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          PopupMenuItem(
                            child: ListTile(
                              leading: Icon(Icons.delete, color: Colors.red),
                              title: Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                              onTap: () {
                                deleteImage(imageUrl);
                                FirebaseFirestore.instance
                                    .collection('reports')
                                    .doc(docId)
                                    .delete();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
