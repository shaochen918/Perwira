import 'package:flutter/material.dart';
import 'package:perwirastoremanage/admin_booking_page.dart';
import 'package:perwirastoremanage/admin_drawer.dart';
import 'main.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double iconSize = 100.0; // Adjust the icon size as needed
    return AdminDrawer(
      title: 'Admin Home',

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
                      icon: Icon(
                        Icons.account_circle,
                        color: Colors.white,),
                      onPressed: () {
                        // Handle Items tap
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
                      icon: Icon(
                        Icons.calendar_month,
                        color: Colors.white,),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminBookingPage()),
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
