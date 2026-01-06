import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/screen/booking/booking_history.dart';
import 'package:muc_jomtravel/src/screen/homepage/user_profile.dart';

import 'user_dashboard.dart';

class UserNavigationView extends StatefulWidget {
  UserNavigationView({super.key, this.selectedIndex = 0});
  int selectedIndex;
  @override
  State<UserNavigationView> createState() => _UserNavigationViewState();
}

class _UserNavigationViewState extends State<UserNavigationView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: widget.selectedIndex,
        children: [
          UserDashboardScreen(),
          BookingHistoryScreen(),
          UserProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.selectedIndex,
        onTap: (index) {
          setState(() {
            widget.selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Booking'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
