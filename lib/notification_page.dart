import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:perwirastoremanage/student_drawer.dart';


class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.reference();

  Future<List<Map<String, dynamic>>> _getNotifications() async {
    DataSnapshot snapshot = await _databaseRef.child('notifications').orderByChild('state').equalTo('unread').get();
    List<Map<String, dynamic>> notifications = [];
    if (snapshot.exists) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        notifications.add({'id': key, ...Map<String, dynamic>.from(value)});
      });
    }
    return notifications;
  }

  Future<void> _markAsRead(String id) async {
    await _databaseRef.child('notifications').child(id).update({'state': 'read'});
    await _databaseRef.child('notifications').child(id).remove();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StudentDrawer(
      title: 'Notifications',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _getNotifications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No unread notifications.'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var notification = snapshot.data![index];
                  return ListTile(
                    title: Text('Original Data: ${notification['original_data']}'),
                    subtitle: Text('Updated Data: ${notification['updated_data']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () {
                        _markAsRead(notification['id']);
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
