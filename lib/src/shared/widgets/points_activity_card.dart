import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PointsActivityCard extends StatelessWidget {
  bool isEarn;
  String title;
  Timestamp timestamp;
  int amount;

  PointsActivityCard({
    super.key,
    required this.isEarn,
    required this.title,
    required this.timestamp,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: isEarn ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(Icons.local_offer, color: Colors.white),
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "${timestamp.toDate().day.toString().padLeft(2, '0')}-${timestamp.toDate().month.toString().padLeft(2, '0')}-${timestamp.toDate().year}",
        ), // Convert Timestamp to readable date
        trailing: Text(
          "${isEarn ? '+' : '-'}$amount pts",
          style: TextStyle(fontSize: 12, color: Colors.green),
        ),
      ),
    );
  }
}
