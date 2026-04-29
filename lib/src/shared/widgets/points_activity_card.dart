import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PointsActivityCard extends StatelessWidget {
  final bool isEarn;
  final String title;
  final Timestamp timestamp;
  final int amount;

  const PointsActivityCard({
    super.key,
    required this.isEarn,
    required this.title,
    required this.timestamp,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final date = timestamp.toDate();
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isEarn ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEarn ? Icons.trending_up : Icons.trending_down,
              color: isEarn ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${isEarn ? '+' : '-'}$amount",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isEarn ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            "pts",
            style: TextStyle(
              fontSize: 12,
              color: isEarn ? Colors.green[300] : Colors.red[300],
            ),
          ),
        ],
      ),
    );
  }
}
