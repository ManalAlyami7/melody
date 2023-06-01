import 'package:cloud_firestore/cloud_firestore.dart' show DocumentReference, DocumentSnapshot, FieldValue, FirebaseFirestore, QuerySnapshot;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import 'add_item_screen.dart';

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({Key? key}) : super(key: key);

  @override
  _ItemListScreenState createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _itemsStream;

  final _auth  = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    _itemsStream = FirebaseFirestore.instance.collection('items').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item List'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              setState(() {
              });
            },
            icon: const Icon(Icons.exit_to_app),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _itemsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load items: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!.docs;

          if (items.isEmpty) {
            return const Center(child: Text('No items found.'));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index].data();

              return ListTile(
                leading: SizedBox(
                  width: 100,
                  child: item['imageUrls'].isNotEmpty ? Image.network(item['imageUrls'][0]) : Container(),
                ),
                title: Text(item['itemName']),
                subtitle: Text(item['description']),
                trailing: ElevatedButton(
                  onPressed: () => _showDeleteConfirmationDialog(context, items[index].reference),
                  child: const Text('Delete'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddItemScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, DocumentReference<Map<String, dynamic>> itemRef) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Item?'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await itemRef.delete();
    }
  }
}

