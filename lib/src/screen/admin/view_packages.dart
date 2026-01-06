import 'package:flutter/material.dart';

class AdminViewPackages extends StatefulWidget {
  const AdminViewPackages({super.key});

  @override
  State<AdminViewPackages> createState() => _AdminViewPackagesState();
}

class _AdminViewPackagesState extends State<AdminViewPackages> {
  /// List of packages (dummy local state for now)
  final List<Map<String, String>> _packages = [];

  /// Track which package is being edited (null = none)
  int? _editingIndex;

  /// Controllers for editing
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  /// Create empty package card
  void _addPackage() {
    setState(() {
      _packages.add({
        "name": "",
        "price": "",
      });
    });
  }

  /// Start editing selected package
  void _startEdit(int index) {
    setState(() {
      _editingIndex = index;
      _nameController.text = _packages[index]["name"] ?? "";
      _priceController.text = _packages[index]["price"] ?? "";
    });
  }

  /// Confirm edit
  void _confirmEdit() {
    setState(() {
      _packages[_editingIndex!] = {
        "name": _nameController.text,
        "price": _priceController.text,
      };
      _editingIndex = null;
    });
  }

  /// Cancel edit
  void _cancelEdit() {
    setState(() {
      _editingIndex = null;
    });
  }

  /// Delete with confirmation
  void _deletePackage(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Package"),
        content: const Text("Are you sure you want to delete this package?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _packages.removeAt(index);
                if (_editingIndex == index) {
                  _editingIndex = null;
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
      appBar: AppBar(title: const Text("View Packages")),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPackage,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _packages.length,
        itemBuilder: (context, index) {
          final isEditing = _editingIndex == index;

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

                /// Dynamic title
                Text(
                  "Package ${index + 1}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 12),

                /// Package Name
                const Text("Package Name:"),
                isEditing
                    ? TextField(controller: _nameController)
                    : Text(_packages[index]["name"]!.isEmpty
                        ? "-"
                        : _packages[index]["name"]!),

                const SizedBox(height: 8),

                /// Price
                const Text("Price:"),
                isEditing
                    ? TextField(controller: _priceController)
                    : Text(_packages[index]["price"]!.isEmpty
                        ? "-"
                        : _packages[index]["price"]!),

                const SizedBox(height: 16),

                /// Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: isEditing
                      ? [
                          _linkButton("Cancel", _cancelEdit),
                          const SizedBox(width: 16),
                          _linkButton("Confirm", _confirmEdit),
                        ]
                      : [
                          _linkButton("Edit", () => _startEdit(index)),
                          const SizedBox(width: 16),
                          _linkButton(
                            "Delete",
                            () => _deletePackage(index),
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

  /// Reusable link-style button
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