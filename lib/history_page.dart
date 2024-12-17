import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'student_drawer.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
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

  Future<void> _deleteBooking(String id) async {
    await _databaseRef.child('bookings').child(id).remove();
    setState(() {}); // Refresh the UI
  }

  Future<void> _deleteFeedback(String id) async {
    await _databaseRef.child('feedback_complaint').child(id).remove();
    setState(() {}); // Refresh the UI
  }

  @override
  Widget build(BuildContext context) {
    return StudentDrawer(
      title: 'History',
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
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              if (isBookingSelected) {
                                await _deleteBooking(record['id']);
                              } else {
                                await _deleteFeedback(record['id']);
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
