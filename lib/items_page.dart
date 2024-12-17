import 'package:flutter/material.dart';
import 'student_drawer.dart';
import 'add_item_page.dart'; // Import the AddItemPage
import 'items_list.dart'; // Import the ItemsList widget

class ItemsPage extends StatelessWidget {
  const ItemsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = 100.0; // Adjust the icon size as needed

    return StudentDrawer(
      title: 'Items',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to AddItemPage when "Add Item" button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddItemPage()),
                );
              },
              child: const Text('Add Item'),
            ),
          ),
          Expanded(
            child: ItemsList(), // Display ItemsList widget to show list of items
          ),
        ],
      ),
    );
  }
}
