import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/model/models.dart';
import 'package:muc_jomtravel/src/shared/notifications.dart';
import 'package:muc_jomtravel/src/service/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muc_jomtravel/src/shared/theme/app_colors.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _userService = UserService();
  final _authService = AuthService();
  final _user = FirebaseAuth.instance.currentUser;

  Future<void> _showEditNameDialog(AppUser appUser) async {
    final controller = TextEditingController(text: appUser.fullName);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Full Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(appUser.userId)
                    .update({'name': controller.text.trim()});
                if (mounted) Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Save', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'New Password'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              try {
                if (controller.text.length < 6) {
                  throw Exception("Password must be at least 6 characters");
                }
                await _user?.updatePassword(controller.text);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password updated successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppColors.error),
                );
              }
            },
            child: const Text('Update', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    if (_user == null || _isLoggingOut)
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final data = snapshot.data?.data() as Map<String, dynamic>?;
          if (data == null) return const Center(child: Text('User not found'));

          final appUser = AppUser.fromMap(data);
          final totalPoints = (data['total_points'] ?? 0).toInt();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white24,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          appUser.fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          appUser.email,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Rewards & Points'),
                      _buildRewardCard(totalPoints),

                      const SizedBox(height: 24),
                      _buildSectionTitle('Account Settings'),
                      _buildMenuCard([
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          title: 'Edit Profile Name',
                          onTap: () => _showEditNameDialog(appUser),
                        ),
                        _buildMenuItem(
                          icon: Icons.lock_outline,
                          title: 'Change Password',
                          onTap: _showChangePasswordDialog,
                        ),
                        _buildMenuItem(
                          icon: Icons.email_outlined,
                          title: 'Account Email',
                          subtitle: appUser.email,
                          onTap: null, // Static item
                        ),
                      ]),

                      const SizedBox(height: 24),
                      _buildSectionTitle('Support'),
                      _buildMenuCard([
                        _buildMenuItem(
                          icon: Icons.help_outline,
                          title: 'Help Center',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.description_outlined,
                          title: 'Terms of Service',
                          onTap: () {},
                        ),
                      ]),

                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            setState(() => _isLoggingOut = true);
                            await _authService.signOut();
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildRewardCard(int points) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: AppColors.warning,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available Balance',
                style: TextStyle(color: AppColors.textLight, fontSize: 13),
              ),
              Text(
                '$points pts',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              ChangeTabNotification(2).dispatch(context);
            },
            child: const Text('Details', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> items) {
    return Container(
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
      child: Column(children: items),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: textColor ?? AppColors.textSecondary, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textLight))
          : null,
      trailing: onTap != null
          ? const Icon(Icons.chevron_right, size: 20, color: AppColors.textLight)
          : null,
    );
  }
}
