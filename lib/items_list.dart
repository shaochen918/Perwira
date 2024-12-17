import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

class ItemsList extends StatelessWidget {
  final DatabaseReference _database = FirebaseDatabase.instance.reference().child('items');

  @override
  Widget build(BuildContext context) {
    return FirebaseAnimatedList(
      query: _database,
      itemBuilder: (context, snapshot, animation, index) {
        // Check if the snapshot exists and has data
        if (!snapshot.exists || snapshot.value == null) {
          return SizedBox(); // Return an empty SizedBox if no data
        }

        // Cast snapshot value to Map<dynamic, dynamic>
        Map<dynamic, dynamic> item = snapshot.value as Map<dynamic, dynamic>;
        item['key'] = snapshot.key;

        // Get item details from the map
        String itemName = item['item_name'] ?? '';
        int itemQuantity = item['item_quantity'] ?? 0;

        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(itemName),
            subtitle: Text('Quantity: $itemQuantity'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _editItem(context, item);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await _database.child(item['key']).remove();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Item deleted successfully')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editItem(BuildContext context, Map<dynamic, dynamic> item) {
    TextEditingController itemNameController = TextEditingController(text: item['item_name']);
    TextEditingController itemQuantityController = TextEditingController(text: item['item_quantity'].toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: itemNameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                controller: itemQuantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String newName = itemNameController.text.trim();
                int newQuantity = int.tryParse(itemQuantityController.text.trim()) ?? 0;

                if (newName.isNotEmpty && newQuantity >= 0) {
                  await _database.child(item['key']).update({
                    'item_name': newName,
                    'item_quantity': newQuantity,
                  });
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item updated successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter valid values')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
