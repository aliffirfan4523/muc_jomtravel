import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:muc_jomtravel/auth_gate.dart';
import 'package:muc_jomtravel/firebase_options.dart';
import 'package:muc_jomtravel/src/screen/admin/view_booking.dart';
import 'package:muc_jomtravel/src/screen/admin/view_packages.dart';
import 'package:muc_jomtravel/src/screen/admin/view_user_data.dart';
import 'package:muc_jomtravel/src/screen/booking/booking_info.dart';
import 'package:muc_jomtravel/src/screen/booking/booking_succesful.dart';
import 'package:muc_jomtravel/src/screen/homepage/user_navigation_view.dart';
import 'package:muc_jomtravel/src/screen/homepage/user_profile.dart';
import 'package:muc_jomtravel/src/service/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await GoogleSignIn.instance.initialize(
    clientId:
        '731804815132-dskle869v9jsjpq62rkdb9gh6e90bggd.apps.googleusercontent.com',
  );

  await AuthService().handleAutoLogoutIfNeeded();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        "/userProfile": (_) => UserProfileScreen(),
        // "/bookingForm" is handled in onGenerateRoute
        "/bookingHistory": (_) => UserNavigationView(selectedIndex: 1),
        "/bookingInfo": (_) => BookingInfoScreen(),
        "/bookingSuccesful": (_) => BookingSuccessfulScreen(),
        "/adminViewBooking": (_) => AdminViewBooking(),
        "/adminViewPackages": (_) => AdminViewPackages(),
        "/adminViewUserData": (_) => AdminViewUserData(),

        "/userDashboard": (_) => UserNavigationView(selectedIndex: 0),
      },
      home: AuthGate(),
    );
  }
}
