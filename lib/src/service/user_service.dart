import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muc_jomtravel/src/model/app_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<AppUser?> getUserData(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();

    if (!doc.exists) return null;
    print(doc.data());
    return AppUser.fromMap(doc.data()!);
  }

  Future<void> savePendingProfile({required String name}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_name', name);
  }

  Future<String> returnPendingProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final name = prefs.getString('pending_name');

    // 🔴 Clear immediately after reading
    await prefs.remove('pending_name');

    return name ?? '';
  }
}
