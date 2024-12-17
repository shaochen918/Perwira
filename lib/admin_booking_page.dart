import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'admin_drawer.dart';

class AdminBookingPage extends StatefulWidget {
  const AdminBookingPage({Key? key}) : super(key: key);

  @override
  _AdminBookingPageState createState() => _AdminBookingPageState();
}

class _AdminBookingPageState extends State<AdminBookingPage> {
  bool isBookingSelected = true;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.reference();

  Future<List<Map<String, dynamic>>> _getBookings() async {
    DataSnapshot snapshot = await _databaseRef.child('bookings').get();
    List<Map<String, dynamic>> bookings = [];
    if (snapshot.exists) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        bookings.add({'id': key, ...Map<String, dynamic>.from(value)});
      });
    }
    return bookings;
  }

  Future<List<Map<String, dynamic>>> _getFeedbacks() async {
    DataSnapshot snapshot = await _databaseRef.child('feedback_complaint').get();
    List<Map<String, dynamic>> feedbacks = [];
    if (snapshot.exists) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        feedbacks.add({'id': key, ...Map<String, dynamic>.from(value)});
      });
    }
    return feedbacks;
  }

  Future<void> _editBooking(String id) async {
    final TextEditingController statusController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Booking Status'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: statusController,
              decoration: InputDecoration(labelText: 'Status (accept/reject)'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a status';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final originalData = (await _databaseRef.child('bookings').child(id).get()).value;
                  await _databaseRef.child('bookings').child(id).update({
                    'status': statusController.text,
                  });
                  await _databaseRef.child('notifications').push().set({
                    'original_data': originalData,
                    'updated_data': {'status': statusController.text},
                    'state': 'unread',
                  });
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editFeedback(String id) async {
    final TextEditingController replyController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reply to Feedback'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: replyController,
              decoration: InputDecoration(labelText: 'Reply'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a reply';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final originalData = (await _databaseRef.child('feedback_complaint').child(id).get()).value;
                  await _databaseRef.child('feedback_complaint').child(id).update({
                    'reply': replyController.text,
                  });
                  await _databaseRef.child('notifications').push().set({
                    'original_data': originalData,
                    'updated_data': {'reply': replyController.text},
                    'state': 'unread',
                  });
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminDrawer(
      title: 'Admin Booking',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            ToggleButtons(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text("Booking"),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text("Feedback/Complaint"),
                ),
              ],
              isSelected: [isBookingSelected, !isBookingSelected],
              onPressed: (int index) {
                setState(() {
                  isBookingSelected = index == 0;
                });
              },
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: isBookingSelected ? _getBookings() : _getFeedbacks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No records found.'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var record = snapshot.data![index];
                        return ListTile(
                          title: Text(isBookingSelected
                              ? 'Date: ${record['date']}, Time: ${record['time']}'
                              : 'Feedback: ${record['text']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isBookingSelected && record['image'] != null && record['image'].isNotEmpty)
                                Image.network(record['image']),
                              if (isBookingSelected)
                                Text('Status: ${record['status']}'),
                              if (!isBookingSelected)
                                Text('Reply: ${record['reply']}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              if (isBookingSelected) {
                                _editBooking(record['id']);
                              } else {
                                _editFeedback(record['id']);
                              }
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
