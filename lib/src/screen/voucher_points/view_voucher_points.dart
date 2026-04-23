import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/service/services.dart';

import 'package:muc_jomtravel/src/shared/widgets/widgets.dart';
import 'redeem_voucher.dart';
import 'my_voucher.dart';

class ViewVoucherPoints extends StatefulWidget {
  const ViewVoucherPoints({super.key});
  @override
  State<ViewVoucherPoints> createState() => _ViewVoucherPointsState();
}

class _ViewVoucherPointsState extends State<ViewVoucherPoints> {
  final user = FirebaseAuth.instance.currentUser;

  Future<int> getUserPoints() async {
    try {
      if (user == null) return 0;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      // The 'exists' check is good, but also ensure the data is there
      if (doc.exists && doc.data() != null) {
        return (doc.data()!['total_points'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint("Error fetching points: $e");
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userService = UserService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Rewards'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.card_giftcard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyVoucher()),
              );
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('No user logged in'))
          : FutureBuilder<int>(
              future: getUserPoints(),
              builder: (context, asyncSnapshot) {
                /// Show loading if data is not ready
                if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (asyncSnapshot.hasError) {
                  return Center(child: Text('Error: ${asyncSnapshot.error}'));
                }
                if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
                  return const Center(child: Text('No user data found'));
                }

                final totalPoints = asyncSnapshot.data!;

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                    child: Column(
                      spacing: 20,
                      mainAxisAlignment: MainAxisAlignment.start,

                      children: [
                        balanceWidget(context, totalPoints),
                        Row(
                          children: [
                            Text(
                              "Points Activity",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Text(
                              "View All",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(user!.uid)
                              .collection('point_history')
                              .orderBy('timestamp', descending: true)
                              .limit(10) // Show last 10 activities
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData)
                              return LinearProgressIndicator();

                            return ListView.builder(
                              shrinkWrap: true,
                              physics:
                                  NeverScrollableScrollPhysics(), // Keep this since you're inside a scroll view
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                var data = snapshot.data!.docs[index];
                                bool isEarn = data['amount'] > 0;

                                return PointsActivityCard(
                                  isEarn: isEarn,
                                  title: data['title'],
                                  timestamp: data['timestamp'],
                                  amount: data['amount'],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Container balanceWidget(BuildContext context, int points) {
    return Container(
      padding: const EdgeInsets.all(16.0),

      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        spacing: 12,
        children: [
          Text(
            "Available Balance",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                points.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(" pts", style: TextStyle(fontSize: 16, color: Colors.white)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Navigate to redeem voucher page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RedeemVoucherView(userPoints: points),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.local_offer, size: 16, color: Colors.blue),
                    SizedBox(width: 4),
                    Text("Redeem", style: TextStyle(color: Colors.blue)),
                  ],
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyVoucher()),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.card_giftcard, size: 16, color: Colors.blue),
                    SizedBox(width: 4),
                    Text("View Voucher", style: TextStyle(color: Colors.blue)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
