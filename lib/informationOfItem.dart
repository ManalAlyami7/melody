import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InformationOfItem extends StatefulWidget {
  const InformationOfItem({Key? key, this.item}) : super(key: key);
  final item;
  @override
  State<InformationOfItem> createState() => _InformationOfItemState();
}

class _InformationOfItemState extends State<InformationOfItem> {

  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {

    return  Scaffold(
      appBar: AppBar(
        title: Text(widget.item['itemName']),
        centerTitle: true,
      ),
      body:Column(
        children: [
          Center(
            child: SizedBox(
              height: 300,
              child: widget.item['imageUrls'].isNotEmpty ? Image.network(widget.item['imageUrls'][0]) : Container(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Name : '+ widget.item['itemName'],style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          ),
         Padding(
           padding: const EdgeInsets.all(8.0),
           child: Text('Description : '+ widget.item['description'],style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
         ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Quality : '+ widget.item['quality'],style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Size : '+ widget.item['size'],style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Price : '+ widget.item['price'].toString() + " \$ ",style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          ),

        ],
      ) ,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_auth.currentUser == null){
              return;
          }
          final docUser = FirebaseFirestore.instance.collection('Users').doc(_auth.currentUser!.uid);
          var user = (await docUser.get()).data();
          var items = user?['items'] ?? [];
          docUser.update({
            'items': [widget.item['itemName'], ...items ]
          });
        },
        child: const Icon(Icons.add_shopping_cart_rounded),
      ),
    );
  }
}
