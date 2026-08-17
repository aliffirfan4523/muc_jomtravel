import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:muc_jomtravel/auth_gate.dart';
import 'package:muc_jomtravel/firebase_options.dart';
import 'package:muc_jomtravel/src/screen/admin/admin_vouchers.dart';
import 'package:muc_jomtravel/src/screen/admin/view_booking.dart';
import 'package:muc_jomtravel/src/screen/admin/view_packages.dart';
import 'package:muc_jomtravel/src/screen/admin/view_user_data.dart';
import 'package:muc_jomtravel/src/screen/booking/booking_info.dart';
import 'package:muc_jomtravel/src/screen/booking/booking_succesful.dart';
import 'package:muc_jomtravel/src/screen/homepage/user_navigation_view.dart';
import 'package:muc_jomtravel/src/screen/homepage/user_profile.dart';
import 'package:muc_jomtravel/src/service/services.dart';
import 'package:muc_jomtravel/src/screen/admin/admin_reviews_feedback.dart';
import 'package:muc_jomtravel/src/shared/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enable offline disk persistence & caching for instantaneous data loading
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Initialize background services concurrently
  Future.wait([
    GoogleSignIn.instance.initialize(
      clientId:
          '731804815132-dskle869v9jsjpq62rkdb9gh6e90bggd.apps.googleusercontent.com',
    ),
    AuthService().handleAutoLogoutIfNeeded(),
  ]);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JomTravel',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.cardBackground,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.cardBackground,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      routes: {
        "/home": (_) => const UserNavigationView(selectedIndex: 0),
        "/userProfile": (_) => const UserProfileScreen(),
        "/bookingHistory": (_) => const UserNavigationView(selectedIndex: 1),
        "/bookingInfo": (_) => const BookingInfoScreen(),
        "/bookingSuccesful": (_) => const BookingSuccessfulScreen(),
        "/adminViewBooking": (_) => AdminViewBooking(),
        "/adminViewPackages": (_) => AdminViewPackages(),
        "/adminViewUserData": (_) => AdminViewUserData(),
        "/adminViewVouchers": (_) => AdminVoucherScreen(),
        "/adminReviewsFeedback": (_) => const AdminReviewsFeedbackScreen(),
        "/points_reward_page": (_) => const UserNavigationView(selectedIndex: 2),
        "/userDashboard": (_) => const UserNavigationView(selectedIndex: 0),
      },
      home: AuthGate(),
    );
  }
}
