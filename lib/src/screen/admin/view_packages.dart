import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/model/app_package.dart';
import 'package:muc_jomtravel/src/screen/admin/manage_package_form.dart';
import 'package:muc_jomtravel/src/service/admin_service.dart';

class AdminViewPackages extends StatefulWidget {
  const AdminViewPackages({super.key});

  @override
  State<AdminViewPackages> createState() => _AdminViewPackagesState();
}

class _AdminViewPackagesState extends State<AdminViewPackages> {
  final AdminService _adminService = AdminService();

  void _navigateToForm({Package? package}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManagePackageForm(package: package),
      ),
    );
  }

  void _deletePackage(Package package) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Package"),
        content: Text("Are you sure you want to delete '${package.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await _adminService.deletePackage(package);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Packages")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('packages')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text("No packages found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              // Ensure ID is included if missing in document data (it might be redundant if toMap includes it)
              data['package_id'] = docs[index].id;

              // Safely parsing
              Package? package;
              try {
                // If package_id was saved in the document, use it. Otherwise use doc.id
                if (data['package_id'] == null || data['package_id'] == '') {
                  data['package_id'] = docs[index].id;
                }

                package = Package.fromMap(data);
              } catch (e) {
                return Card(
                  color: Colors.red.shade100,
                  child: ListTile(
                    title: const Text("Error parsing package"),
                    subtitle: Text(e.toString()),
                  ),
                );
              }

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: package.image.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(package.image.first),
                        )
                      : const CircleAvatar(child: Icon(Icons.travel_explore)),
                  title: Text(
                    package.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text("Location: ${package.location}"),
                      Text(
                        "Adult: RM${package.priceAdult} | Child: RM${package.priceChild}",
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _navigateToForm(package: package),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletePackage(package!),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
