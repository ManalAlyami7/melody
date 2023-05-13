
import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id;
  final String itemName;
  final String description;
  final String size;
  final String quality;
  final double price;
  final List<String> imageUrls;

  Item({
    required this.id,
    required this.itemName,
    required this.description,
    required this.size,
    required this.quality,
    required this.price,
    required this.imageUrls,
  });

  Item.fromSnapshot(DocumentSnapshot snapshot)
      : id = snapshot.id,
        itemName = snapshot.get('itemName'),
        description = snapshot.get('description'),
        size = snapshot.get('size'),
        quality = snapshot.get('quality'),
        price = snapshot.get('price'),
        imageUrls = List<String>.from(snapshot.get('imageUrls'));

  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'description': description,
      'size': size,
      'quality': quality,
      'price': price,
      'imageUrls': imageUrls,
    };
  }
}