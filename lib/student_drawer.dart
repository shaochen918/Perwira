import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:perwirastoremanage/booking_page.dart';
import 'package:perwirastoremanage/history_page.dart';
import 'package:perwirastoremanage/main.dart';
import 'package:perwirastoremanage/notification_page.dart';
import 'home_page.dart';
import 'items_page.dart';

class StudentDrawer extends StatefulWidget {
  final String title;
  final Widget body;

  const StudentDrawer({Key? key, required this.title, required this.body}) : super(key: key);

  @override
  _StudentDrawerState createState() => _StudentDrawerState();
}

class _StudentDrawerState extends State<StudentDrawer> {
  int _notificationCount = 0;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    _getNotificationCount();
  }

  Future<void> _getNotificationCount() async {
    DataSnapshot snapshot = await _databaseRef.child('notifications').orderByChild('state').equalTo('unread').get();
    if (snapshot.exists) {
      setState(() {
        _notificationCount = (snapshot.value as Map).length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.house),
            onPressed: () {
              FirebaseAuth.instance.signOut().then((_) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
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
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Items'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                if (!(widget.body is ItemsPage)) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ItemsPage()),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Booking'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                if (!(widget.body is BookingPage)) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const BookingPage()),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryPage()),
                ); // Handle History tap
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: Row(
                children: [
                  const Text('Notification'),
                  if (_notificationCount > 0)
                    Container(
                      margin: const EdgeInsets.only(left: 8.0),
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        '$_notificationCount',
                        style: const TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                    ),
                ],
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                if (!(widget.body is NotificationPage)) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationPage()),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                FirebaseAuth.instance.signOut().then((_) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                        (route) => false,
                  );
                });
              },
            ),
          ],
        ),
      ),
      body: widget.body, // Set the provided body widget here
    );
  }
}
