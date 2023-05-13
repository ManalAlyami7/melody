import 'package:cloud_firestore/cloud_firestore.dart' show DocumentReference, DocumentSnapshot, FieldValue, FirebaseFirestore, QuerySnapshot;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


class AddItemScreen extends StatefulWidget {
  const AddItemScreen({Key? key}) : super(key: key);

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _itemNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sizeController = TextEditingController();
  final _qualityController = TextEditingController();
  final _priceController = TextEditingController();
  final _picker = ImagePicker();
  final _images = <File>[];
  final _imageUrls = <String>[];
  bool _isUploading = false;

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _sizeController.dispose();
    _qualityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Item'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAddImageButton(),
              _buildImagePreview(),
              TextField(
                controller: _itemNameController,
                decoration: InputDecoration(labelText: 'Item Name'),
              ),TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _sizeController,
                decoration: InputDecoration(labelText: 'Size'),
              ),
              TextField(
                controller: _qualityController,
                decoration: InputDecoration(labelText: 'Quality'),
              ),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _isUploading ? null : _addItem,
                child: _isUploading ? CircularProgressIndicator() : Text('Add Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddImageButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: _isUploading ? null : _pickImage,
          icon: Icon(Icons.add),
          label: Text('Add Image'),
        ),
        SizedBox(width: 16.0),
        ElevatedButton.icon(
          onPressed: _isUploading ? null : _clearImages,
          icon: Icon(Icons.delete),
          label: Text('Clear Images'),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    if (_images.isEmpty) {
      return Container();
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Stack(
            children: [
              Image.file(_images[index]),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _isUploading ? null : () => _removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isUploading ? Colors.grey : Colors.red,
                    ),
                    child: Icon(
                      _isUploading ? Icons.hourglass_empty : Icons.close,
                      size: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _clearImages() {
    setState(() {
      _images.clear();
    });
  }

  Future<void> _addItem() async {
    final itemName = _itemNameController.text.trim();
    final description = _descriptionController.text.trim();
    final size = _sizeController.text.trim();
    final quality = _qualityController.text.trim();
    final price =_priceController.text.trim();

    if (itemName.isEmpty || description.isEmpty || size.isEmpty || quality.isEmpty || price.isEmpty || _images.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please provide all the required information.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final itemRef = FirebaseFirestore.instance.collection('items');

      final docRef = await itemRef.add({
        'itemName': itemName,
        'description': description,
        'size': size,
        'quality': quality,
        'price': double.parse(price),
        'createdAt': FieldValue.serverTimestamp(),
        'imageUrls': []
      });

      final storage = FirebaseStorage.instance;
      final reference = storage.ref().child('items').child(docRef.id);

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'itemName': itemName,
          'description': description,
          'size': size,
          'quality': quality,
          'price': price,
        },
      );

      final imageUrls = <String>[];
      for (var i = 0; i < _images.length; i++) {
        final task = reference.child('image$i.jpg').putFile(_images[i], metadata);
        final snapshot = await task.whenComplete(() {});
        final url = await snapshot.ref.getDownloadURL();
        imageUrls.add(url);
      }

      await docRef.update({
        'imageUrls': imageUrls,
      });




      setState(() {
        _isUploading = false;
        _itemNameController.clear();
        _descriptionController.clear();
        _sizeController.clear();
        _qualityController.clear();
        _priceController.clear();
        _images.clear();
        _imageUrls.clear();
      });

      Navigator.of(context).pop();
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
}
// you can hear me ?
//no