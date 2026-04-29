import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:muc_jomtravel/src/shared/widgets/widgets.dart';
import 'redeem_voucher.dart';
import 'my_voucher.dart';
import 'points_history_view.dart';

class ViewVoucherPoints extends StatefulWidget {
  const ViewVoucherPoints({super.key});
  @override
  State<ViewVoucherPoints> createState() => _ViewVoucherPointsState();
}

class _ViewVoucherPointsState extends State<ViewVoucherPoints> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('No user logged in')));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Rewards', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (userSnapshot.hasError) {
            return Center(child: Text('Error: ${userSnapshot.error}'));
          }
          
          final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
          final totalPoints = (userData?['total_points'] ?? 0).toInt();

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  balanceWidget(context, totalPoints),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      const Text(
                        "Points Activity",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PointsHistoryView(),
                            ),
                          );
                        },
                        child: const Text(
                          "View All",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('point_history')
                        .orderBy('timestamp', descending: true)
                        .limit(5) // Show top 5 on dashboard
                        .snapshots(),
                    builder: (context, historySnapshot) {
                      if (historySnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: LinearProgressIndicator());
                      }
                      
                      final docs = historySnapshot.data?.docs ?? [];
                      
                      if (docs.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(40),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Icon(Icons.history_toggle_off, size: 48, color: Colors.grey[300]),
                              const SizedBox(height: 12),
                              Text("No recent activity", style: TextStyle(color: Colors.grey[400])),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          var data = docs[index].data() as Map<String, dynamic>;
                          bool isEarn = (data['amount'] ?? 0) > 0;

                          return PointsActivityCard(
                            isEarn: isEarn,
                            title: data['title'] ?? 'Transaction',
                            timestamp: data['timestamp'] ?? Timestamp.now(),
                            amount: (data['amount'] ?? 0).abs().toInt(),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget balanceWidget(BuildContext context, int points) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CA1AF), Color(0xFF2C3E50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Available Points",
            style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stars_rounded, color: Colors.amber, size: 32),
              const SizedBox(width: 8),
              Text(
                points.toString(),
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RedeemVoucherView(userPoints: points),
                      ),
                    );
                  },
                  icon: const Icon(Icons.local_offer, size: 18),
                  label: const Text("Redeem"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2C3E50),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyVoucher()),
                    );
                  },
                  icon: const Icon(Icons.card_giftcard, size: 18),
                  label: const Text("My Vouchers"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
