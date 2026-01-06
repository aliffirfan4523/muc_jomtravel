// Helper function to convert a 24h string (HH:mm) to TimeOfDay
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

TimeOfDay stringToTimeOfDay(String time) {
  final format = DateFormat("HH:mm");
  // Use an arbitrary date as DateTime requires one for parsing the time string
  final DateTime dateTime = format.parse(time);
  return TimeOfDay.fromDateTime(dateTime);
}

// Helper function to format TimeOfDay to "h.mma" format (e.g., "4.30pm")

String formatTimeOfDay24(TimeOfDay timeOfDay) {
  final now = DateTime.now();
  final dateTime = DateTime(
    now.year,
    now.month,
    now.day,
    timeOfDay.hour,
    timeOfDay.minute,
  );

  return DateFormat('HH:mm').format(dateTime);
}
