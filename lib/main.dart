import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:muc_jomtravel/auth_gate.dart';
import 'package:muc_jomtravel/firebase_options.dart';
import 'package:muc_jomtravel/src/screen/admin/view_booking.dart';
import 'package:muc_jomtravel/src/screen/admin/view_packages.dart';
import 'package:muc_jomtravel/src/screen/admin/view_user_data.dart';
import 'package:muc_jomtravel/src/screen/booking/booking_form.dart';
import 'package:muc_jomtravel/src/screen/booking/booking_history.dart';
import 'package:muc_jomtravel/src/screen/booking/booking_info.dart';
import 'package:muc_jomtravel/src/screen/booking/booking_succesful.dart';
import 'package:muc_jomtravel/src/screen/booking/booking_summary.dart';
import 'package:muc_jomtravel/src/screen/homepage/user_profile.dart';
import 'package:muc_jomtravel/src/screen/package/view_package.dart';
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
      routes: {
        "/userProfile": (_) => UserProfiles(),
        "/viewPackages": (_) => ViewPackages(),
        "/bookingForm": (_) => BookingForm(),
        "/bookingHistory": (_) => BookingHistory(),
        "/bookingInfo": (_) => BookingInfo(),
        "/bookingSuccesful": (_) => BookingSuccesful(),
        "/priceSummary": (_) => BookingSummary(),
        "/adminViewBooking": (_) => AdminViewBooking(),
        "/adminViewPackages": (_) => AdminViewPackages(),
        "/adminViewUserData": (_) => AdminViewUserData(),
      },
      home: AuthGate(),
    );
  }
}
