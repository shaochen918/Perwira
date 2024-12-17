import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Correctly import firebase_storage
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddItemPage extends StatefulWidget {
  const AddItemPage({Key? key}) : super(key: key);

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemQuantityController = TextEditingController();
  final DatabaseReference _database = FirebaseDatabase.instance.reference().child('items'); // Specify child node 'items'
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(String itemId) async {
    if (_image == null) return null;
    try {
      final storageRef = FirebaseStorage.instance.ref().child('items/$itemId.jpg');
      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _saveItem() async {
    String itemName = _itemNameController.text.trim();
    String itemQuantityText = _itemQuantityController.text.trim();
    int itemQuantity = int.tryParse(itemQuantityText) ?? 0; // Parse quantity as integer, default to 0 if parsing fails

    if (itemName.isEmpty || itemQuantityText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    String itemId = _database.push().key!; // Generate a unique ID for the item
    final imageUrl = await _uploadImage(itemId); // Upload the image and get the URL

    // Save item data to Firebase Realtime Database
    await _database.child(itemId).set({
      'item_name': itemName,
      'item_quantity': itemQuantity,
      'image': imageUrl, // Store the image URL
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item saved successfully')),
    );

    _itemNameController.clear();
    _itemQuantityController.clear();
    setState(() {
      _image = null; // Clear the image
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _itemNameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _itemQuantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number, // Ensure numeric keyboard
            ),
            const SizedBox(height: 16),
            _image != null
                ? Image.file(_image!)
                : Text("No image selected"),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveItem,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemQuantityController.dispose();
    super.dispose();
  }
}
