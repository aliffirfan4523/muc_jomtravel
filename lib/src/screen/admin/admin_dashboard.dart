import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/service/services.dart';
import 'package:muc_jomtravel/src/shared/theme/app_colors.dart';
import 'package:muc_jomtravel/src/shared/widgets/widgets.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AuthService _authService = AuthService();
  final AdminService _adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Overview",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // FutureBuilder for Real Stats
                  FutureBuilder<Map<String, int>>(
                    future: _adminService.getDashboardStats(),
                    builder: (context, snapshot) {
                      final stats =
                          snapshot.data ??
                          {'packages': 0, 'bookings': 0, 'users': 0, 'vouchers': 0};
                      final isLoading =
                          snapshot.connectionState == ConnectionState.waiting;

                      return Column(
                        children: [
                          Row(
                            children: [
                              _DashboardStatCard(
                                title: "Packages",
                                count: stats['packages']!,
                                icon: Icons.holiday_village_outlined,
                                color: AppColors.primary,
                                isLoading: isLoading,
                              ),
                              const SizedBox(width: 12),
                              _DashboardStatCard(
                                title: "Bookings",
                                count: stats['bookings']!,
                                icon: Icons.book_online_outlined,
                                color: AppColors.secondary,
                                isLoading: isLoading,
                              ),
                              const SizedBox(width: 12),
                              _DashboardStatCard(
                                title: "Users",
                                count: stats['users']!,
                                icon: Icons.people_outline,
                                color: AppColors.textSecondary,
                                isLoading: isLoading,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _DashboardStatCard(
                                title: "Vouchers",
                                count: stats['vouchers'] ?? 0,
                                icon: Icons.local_offer_outlined,
                                color: AppColors.info,
                                isLoading: isLoading,
                              ),
                              const SizedBox(width: 12),
                              _DashboardStatCard(
                                title: "Reviews",
                                count: 0, // Placeholder
                                icon: Icons.reviews_outlined,
                                color: AppColors.success,
                                isLoading: isLoading,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                  const Text(
                    "Management",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Action Grid
                  GridView.count(
                    primary: false,
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                      _ActionCard(
                        title: "Packages",
                        icon: Icons.map,
                        color: AppColors.primary,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            "/adminViewPackages",
                          ).then((_) => setState(() {}));
                        },
                      ),
                      _ActionCard(
                        title: "Bookings",
                        icon: Icons.confirmation_number,
                        color: AppColors.secondary,
                        onTap: () {
                          Navigator.pushNamed(context, "/adminViewBooking");
                        },
                      ),
                      _ActionCard(
                        title: "Users",
                        icon: Icons.person_search,
                        color: AppColors.textSecondary,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            "/adminViewUserData",
                          ).then((_) => setState(() {}));
                        },
                      ),
                      _ActionCard(
                        title: "Vouchers",
                        icon: Icons.local_offer_outlined,
                        color: AppColors.info,
                        onTap: () {
                          Navigator.pushNamed(context, "/adminViewVouchers")
                              .then((_) => setState(() {}));
                        },
                      ),
                      _ActionCard(
                        title: "Reviews",
                        icon: Icons.reviews_outlined,
                        color: AppColors.success,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Coming soon!"), backgroundColor: AppColors.info),
                          );
                        },
                      ),
                      _ActionCard(
                        title: "Reports",
                        icon: Icons.analytics_outlined,
                        color: AppColors.warning,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Coming soon!"), backgroundColor: AppColors.info),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        image: DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black38,
            BlendMode.darken,
          ),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 40,
            right: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white24,
              child: SignoutButton(authService: _authService),
            ),
          ),
          const Positioned(
            bottom: 30,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Admin Dashboard",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Manage your travel platform",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final bool isLoading;

  const _DashboardStatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 8),
            isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Text(
                    count.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
            Text(
              title,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
