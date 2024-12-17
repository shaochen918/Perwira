import 'package:flutter/material.dart';
import 'student_drawer.dart';
import 'items_page.dart';
import 'booking_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = 100.0; // Adjust the icon size as needed

    return StudentDrawer(
      title: 'Home',
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Handle Items tap
              },
              child: Container(
                margin: const EdgeInsets.all(8.0),
                color: Colors.grey,
                width: double.infinity, // Ensure full width
                child: Center(
                  child: SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: IconButton(
                      iconSize: iconSize,
                      icon: const Icon(
                        Icons.inventory,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const ItemsPage()),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Handle Booking tap
              },
              child: Container(
                margin: const EdgeInsets.all(8.0),
                color: Colors.grey,
                width: double.infinity, // Ensure full width
                child: Center(
                  child: SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: IconButton(
                      iconSize: iconSize,
                      icon: const Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const BookingPage()),
                        );
                        // Handle Booking tap
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
