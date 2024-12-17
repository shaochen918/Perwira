import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Correctly import firebase_storage
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'student_drawer.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({Key? key}) : super(key: key);

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _feedbackController = TextEditingController();
  bool isBookingSelected = true;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.reference();
  File? _image;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(String feedbackId) async {
    if (_image == null) return null;
    try {
      final storageRef = FirebaseStorage.instance.ref().child('feedbacks/$feedbackId.jpg');
      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _saveBooking() async {
    if (_selectedDate == null || _selectedTime == null) {
      // Handle validation
      return;
    }

    String bookingId = 'ai210210'; // This should be dynamically generated or fetched

    await _databaseRef.child('bookings').child(bookingId).set({
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'time': _selectedTime!.format(context),
      'status': 'null',
    });

    // Clear fields after saving
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
    });
  }

  Future<void> _saveFeedback() async {
    final String feedback = _feedbackController.text;

    if (feedback.isEmpty) {
      // Handle validation
      return;
    }

    String feedbackId = _databaseRef.child('feedback_complaint').push().key!;
    final imageUrl = await _uploadImage(feedbackId);

    await _databaseRef.child('feedback_complaint').child(feedbackId).set({
      'text': feedback,
      'reply': 'null', // Initial reply set to null
      'image': imageUrl, // Store the image URL
    });

    // Clear fields after saving
    _feedbackController.clear();
    setState(() {
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StudentDrawer(
      title: 'Booking',
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
            if (isBookingSelected) ...[
              // Booking Form
              if (_selectedDate != null && _selectedTime != null) ...[
                Text('Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}'),
                Text('Selected Time: ${_selectedTime!.format(context)}'),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Select Date'),
                ),
                ElevatedButton(
                  onPressed: () => _selectTime(context),
                  child: Text('Select Time'),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _saveBooking,
                  child: Text('Save Booking'),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Select Date'),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () => _selectTime(context),
                  child: Text('Select Time'),
                ),
              ],
            ] else ...[
              // Feedback/Complaint Form
              TextField(
                controller: _feedbackController,
                decoration: InputDecoration(
                  labelText: 'Feedback/Complaint',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              _image != null
                  ? Image.file(_image!)
                  : Text("No image selected"),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveFeedback,
                child: Text('Save Feedback/Complaint'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
}
