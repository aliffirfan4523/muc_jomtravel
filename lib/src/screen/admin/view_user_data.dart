import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/shared/theme/app_colors.dart';

class AdminViewUserData extends StatefulWidget {
  const AdminViewUserData({super.key});

  @override
  State<AdminViewUserData> createState() => _AdminViewUserDataState();
}

class _AdminViewUserDataState extends State<AdminViewUserData> {
  final TextEditingController _searchController = TextEditingController();

  String? _expandedUserDocId;
  String _selectedRole = 'all';

  final List<String> _roleFilters = [
    'all',
    'admin',
    'customer',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _usersStream() {
    return FirebaseFirestore.instance.collection('users').snapshots();
  }

  void _toggleView(String userDocId) {
    setState(() {
      _expandedUserDocId = _expandedUserDocId == userDocId ? null : userDocId;
    });
  }

  Future<void> _updateAdminStatus({
    required String userDocId,
    required String userId,
    required String userName,
    required bool makeAdmin,
  }) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (!makeAdmin && (currentUserId == userDocId || currentUserId == userId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot remove your own admin access.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(makeAdmin ? 'Make Admin?' : 'Remove Admin Role?'),
          content: Text(
            makeAdmin
                ? 'Are you sure you want to make "$userName" an admin?'
                : 'Are you sure you want to remove admin access from "$userName"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    makeAdmin ? AppColors.success : AppColors.warning,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userDocId)
          .update({
        'is_admin': makeAdmin,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            makeAdmin
                ? '$userName is now an admin.'
                : 'Admin role removed from $userName.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update user role: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _deleteUserRecord({
    required String userDocId,
    required String userId,
    required String userName,
  }) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == userDocId || currentUserId == userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot delete your own user record.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete User Record'),
          content: Text(
            'Are you sure you want to delete "$userName"?\n\n'
            'This removes the user document, point history, and user vouchers from Firestore. '
            'It does not delete the Firebase Authentication account.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final firestore = FirebaseFirestore.instance;
      final userRef = firestore.collection('users').doc(userDocId);

      final pointHistorySnapshot =
          await userRef.collection('point_history').get();

      final myVouchersSnapshot = await userRef.collection('my_vouchers').get();

      final batch = firestore.batch();

      for (final doc in pointHistorySnapshot.docs) {
        batch.delete(doc.reference);
      }

      for (final doc in myVouchersSnapshot.docs) {
        batch.delete(doc.reference);
      }

      batch.delete(userRef);

      await batch.commit();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$userName deleted successfully.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete user: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Manage Users',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchAndFilterSection(),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _usersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Error loading users:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  );
                }

                final docs =
                    List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
                  snapshot.data?.docs ?? [],
                );

                docs.sort((a, b) {
                  final aTime = _getTimestamp(a.data());
                  final bTime = _getTimestamp(b.data());

                  if (aTime == null && bTime == null) return 0;
                  if (aTime == null) return 1;
                  if (bTime == null) return -1;

                  return bTime.toDate().compareTo(aTime.toDate());
                });

                final filteredDocs = docs.where((doc) {
                  final data = doc.data();

                  final query = _searchController.text.trim().toLowerCase();

                  final name = _getText(
                    data,
                    ['name', 'fullName', 'displayName'],
                    '',
                  ).toLowerCase();

                  final email = _getText(
                    data,
                    ['email'],
                    '',
                  ).toLowerCase();

                  final provider = _getText(
                    data,
                    ['provider'],
                    '',
                  ).toLowerCase();

                  final userId = _getText(
                    data,
                    ['user_id', 'uid'],
                    doc.id,
                  ).toLowerCase();

                  final isAdmin = _isAdmin(data);

                  final roleMatches = _selectedRole == 'all'
                      ? true
                      : _selectedRole == 'admin'
                          ? isAdmin
                          : !isAdmin;

                  final searchMatches = query.isEmpty ||
                      name.contains(query) ||
                      email.contains(query) ||
                      provider.contains(query) ||
                      userId.contains(query) ||
                      doc.id.toLowerCase().contains(query);

                  return roleMatches && searchMatches;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data();

                    return _buildUserCard(
                      userDocId: doc.id,
                      data: data,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search name, email, provider, user ID...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    ),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: _roleFilters.map((role) {
              final selected = _selectedRole == role;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_formatRole(role)),
                  selected: selected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.background,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selectedRole = role;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard({
    required String userDocId,
    required Map<String, dynamic> data,
  }) {
    final userId = _getText(
      data,
      ['user_id', 'uid'],
      userDocId,
    );

    final name = _getText(
      data,
      ['name', 'fullName', 'displayName'],
      'Unknown User',
    );

    final email = _getText(
      data,
      ['email'],
      'No email',
    );

    final provider = _getText(
      data,
      ['provider'],
      'unknown',
    );

    final isAdmin = _isAdmin(data);
    final currentPoints = _getInt(data['total_points']);
    final lifetimePoints = _getInt(data['lifetime_points']);
    final createdAt = _formatDate(_getTimestamp(data));

    final isExpanded = _expandedUserDocId == userDocId;

    final initials =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: isAdmin
                    ? Colors.deepPurple.shade100
                    : AppColors.primaryLight,
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isAdmin ? Colors.deepPurple : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildRoleBadge(isAdmin),
              IconButton(
                onPressed: () => _toggleView(userDocId),
                icon: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ),
            ],
          ),
          if (isExpanded) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPointBox(
                    title: 'Current Points',
                    value: currentPoints.toString(),
                    icon: Icons.stars_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildPointBox(
                    title: 'Lifetime Points',
                    value: lifetimePoints.toString(),
                    icon: Icons.history,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.badge_outlined,
              label: 'User ID',
              value: userId,
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.login_outlined,
              label: 'Provider',
              value: provider,
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Joined',
              value: createdAt,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateAdminStatus(
                      userDocId: userDocId,
                      userId: userId,
                      userName: name,
                      makeAdmin: !isAdmin,
                    ),
                    icon: Icon(
                      isAdmin
                          ? Icons.admin_panel_settings_outlined
                          : Icons.admin_panel_settings,
                      size: 18,
                    ),
                    label: Text(
                      isAdmin ? 'Remove Admin' : 'Make Admin',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isAdmin ? AppColors.warning : AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () => _deleteUserRecord(
                    userDocId: userDocId,
                    userId: userId,
                    userName: name,
                  ),
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.error,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.error.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoleBadge(bool isAdmin) {
    final color = isAdmin ? Colors.deepPurple : AppColors.info;
    final label = isAdmin ? 'ADMIN' : 'CUSTOMER';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPointBox({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.trim().isEmpty ? 'N/A' : value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: AppColors.textLight.withOpacity(0.8),
            ),
            const SizedBox(height: 16),
            const Text(
              'No users found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try changing the filter or search keyword.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getText(
    Map<String, dynamic> data,
    List<String> keys,
    String defaultValue,
  ) {
    for (final key in keys) {
      final value = data[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return defaultValue;
  }

  bool _isAdmin(Map<String, dynamic> data) {
    return data['is_admin'] == true || data['isAdmin'] == true;
  }

  int _getInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;

    return 0;
  }

  Timestamp? _getTimestamp(Map<String, dynamic> data) {
    final possibleKeys = [
      'createdAt',
      'created_at',
      'createdDate',
      'joinedAt',
    ];

    for (final key in possibleKeys) {
      final value = data[key];

      if (value is Timestamp) {
        return value;
      }
    }

    return null;
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'No date';

    final date = timestamp.toDate();

    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatRole(String role) {
    if (role == 'all') return 'All';
    if (role == 'admin') return 'Admin';
    if (role == 'customer') return 'Customer';

    return role;
  }
}
