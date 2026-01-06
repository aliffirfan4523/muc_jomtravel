import 'package:flutter/material.dart';

class AdminViewUserData extends StatefulWidget {
  const AdminViewUserData({super.key});

  @override
  State<AdminViewUserData> createState() => _AdminViewUserDataState();
}

class _AdminViewUserDataState extends State<AdminViewUserData> {
  /// Dummy user data
  final List<Map<String, String>> _users = [
    {
      "userId": "U101",
      "name": "Ahmad Ali",
      "email": "ahmad@email.com",
      "phone": "012-3456789",
    },
    {
      "userId": "U102",
      "name": "Siti Aminah",
      "email": "siti@email.com",
      "phone": "013-9876543",
    },
  ];

  /// Track expanded card
  int? _expandedIndex;

  void _toggleView(int index) {
    setState(() {
      _expandedIndex = (_expandedIndex == index) ? null : index;
    });
  }

  void _deleteUser(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete User"),
        content: const Text("Are you sure you want to delete this user?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _users.removeAt(index);
                if (_expandedIndex == index) {
                  _expandedIndex = null;
                }
              });
              Navigator.pop(context);
            },
            child: const Text(
              "Confirm",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Data")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          final isExpanded = _expandedIndex == index;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Default view
                Text(
                  "User ID: ${user["userId"]}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("Name: ${user["name"]}"),

                /// Expanded details
                if (isExpanded) ...[
                  const SizedBox(height: 10),
                  Text("Email: ${user["email"]}"),
                  Text("Phone: ${user["phone"]}"),
                ],

                const SizedBox(height: 12),

                /// Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _linkButton(
                      isExpanded ? "Minimize" : "View",
                      () => _toggleView(index),
                    ),
                    const SizedBox(width: 16),
                    _linkButton(
                      "Delete",
                      () => _deleteUser(index),
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Underlined clickable text button
  Widget _linkButton(
    String text,
    VoidCallback onTap, {
    Color color = Colors.blue,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}