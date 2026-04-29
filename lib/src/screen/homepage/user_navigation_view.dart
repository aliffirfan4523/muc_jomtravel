import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/screen/booking/booking_history.dart';
import 'package:muc_jomtravel/src/screen/homepage/user_profile.dart';
import 'package:muc_jomtravel/src/screen/voucher_points/view_voucher_points.dart';
import 'package:muc_jomtravel/src/shared/notifications.dart';

import 'user_dashboard.dart';

class UserNavigationView extends StatefulWidget {
  UserNavigationView({super.key, this.selectedIndex = 2});
  int selectedIndex;

  @override
  State<UserNavigationView> createState() => _UserNavigationViewState();
}

class _UserNavigationViewState extends State<UserNavigationView> {
  late int _currentIndex;
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  // Logic to change index
  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ChangeTabNotification>(
      onNotification: (notification) {
        _changeTab(notification.index);
        return true;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            UserDashboardScreen(),
            BookingHistoryScreen(),
            ViewVoucherPoints(),
            UserProfileScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          onTap: _changeTab,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Booking'),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_offer),
              label: 'Rewards',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
