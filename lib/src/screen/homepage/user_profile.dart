import 'package:flutter/material.dart';

/// UserProfileScreen
/// This screen displays the user's profile information,
/// including name, email, and phone number.
/// It also provides a logout button for the user to exit the app.
class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  /// build()
  /// This method builds the UI layout for the profile screen.
  /// It returns a Scaffold widget that contains the AppBar,
  /// user information, logout button, and bottom navigation bar.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// AppBar displays the title and back navigation
      appBar: AppBar(
        title: const Text('Profile'),
        leading: const BackButton(),
      ),

      /// Main content of the profile screen
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// Profile image placeholder
            /// This icon represents the user's avatar
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.person,
                size: 60,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 20),

            /// User information container
            /// Displays user's name, email, and phone number
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: Ali bin Abu'),
                  Text('Email: Ali@gmail.com'),
                  Text('Phone Number: 0166767676767'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Logout button
            /// When pressed, it should log the user out
            /// and redirect to the login screen
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement logout logic (Firebase/AuthGate)
                },
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),

      /// Bottom navigation bar
      /// Allows navigation between Home, Booking, and Profile screens
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Profile tab is selected
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],

        /// Handles navigation when user taps a navigation item
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/history');
          }
        },
      ),
    );
  }
}
