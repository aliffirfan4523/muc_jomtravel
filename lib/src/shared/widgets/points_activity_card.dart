import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:muc_jomtravel/src/shared/theme/app_colors.dart';

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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isEarn
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEarn
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isEarn ? AppColors.success : AppColors.error,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${isEarn ? '+' : '-'}$amount',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: isEarn ? AppColors.success : AppColors.error,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                'pts',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isEarn ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
