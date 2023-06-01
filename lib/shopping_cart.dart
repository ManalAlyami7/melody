
import 'package:cloud_firestore/cloud_firestore.dart' show DocumentReference, DocumentSnapshot, FieldValue, FirebaseFirestore, QuerySnapshot;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'informationOfItem.dart';


class ShoppingCartHome extends StatefulWidget {
  const ShoppingCartHome({Key? key}) : super(key: key);

  @override
  ShoppingCartState createState() => ShoppingCartState();
}

class ShoppingCartState extends State<ShoppingCartHome> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _itemsTenantStream;

  @override
  void initState() {
    super.initState();
    _itemsTenantStream = FirebaseFirestore.instance.collection('items').snapshots();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _itemsTenantStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Failed to load items: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!.docs;

          if (items.isEmpty) {
            return const Center(child: Text('No items found.'));
          }
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('Users').snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> sp) {
              if (sp.hasError) {
                return Center(
                    child: Text('Failed to load items: ${snapshot.error}'));
              }

              if (sp.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              var users = sp.data!.docs;
              var user = users.firstWhere((element) =>
              element['uid'] == FirebaseAuth.instance.currentUser!.uid);
              List<dynamic> x = user?['items'] ?? [];

              var fiItems = items.where((element) =>
                  x.contains(element.data()?['itemName'])).toList();
              return ListView.builder(
                itemCount: fiItems.length,
                itemBuilder: (context, index) {
                  final item = fiItems[index].data();

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () =>
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => InformationOfItem(item: item,))),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(width: 2, color: Colors.blue)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                                height: 100,
                                width: 150,
                                child: item['imageUrls'].isNotEmpty
                                    ? Image.network(
                                  item['imageUrls'][0], fit: BoxFit.contain,)
                                    : Container()),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(item['itemName'],
                                    style: TextStyle(fontSize: 20),),
                                  Text(item['price'].toString() + ' \$',
                                    style: TextStyle(fontSize: 20),),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        }),
    );
  }
}

