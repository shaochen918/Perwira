import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:perwirastoremanage/admin_booking_page.dart';
import 'package:perwirastoremanage/admin_home_page.dart';
import 'package:perwirastoremanage/booking_page.dart';
import 'package:perwirastoremanage/main.dart';
import 'admin_home_page.dart'; // Import for navigation after logout
import 'items_page.dart';

class AdminDrawer extends StatelessWidget {
  final String title;
  final Widget body; // Add body widget

  const AdminDrawer({Key? key, required this.title, required this.body}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.house),
            onPressed: () {
              FirebaseAuth.instance.signOut().then((_) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminHomePage()),
                      (route) => false,
                );
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Admin Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Student Record'),
              onTap: () {
                Navigator.pop(context); // Close the drawer

              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Booking'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                if (!(body is ItemsPage)) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminBookingPage()),
                  );
                  // Handle Booking tap
                }
              },
            ),
            /*ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Feedback/Complaint'),
              onTap: () {
                // Handle History tap
              },
            ),*/
            ListTile(
              leading: const Icon(Icons.post_add),
              title: const Text('Report'),
              onTap: () {
                // Handle Notification tap
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {

                  // Navigate to login page and clear the navigation stack
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MyApp()),
                        (Route<dynamic> route) => false,
                  );
              },
            ),
          ],
        ),
      ),
      body: body, // Set the provided body widget here
    );
  }
}
