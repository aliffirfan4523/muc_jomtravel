import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/service/admin_service.dart';
import 'package:muc_jomtravel/src/service/auth_service.dart';
import 'package:muc_jomtravel/src/shared/widgets/sign_out_button.dart';

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
    // Tropical Theme Colors
    final Color primaryColor = const Color(0xFF00695C); // Teal shade
    final Color secondaryColor = const Color(0xFF4DB6AC); // Lighter teal

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, primaryColor),
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
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // FutureBuilder for Real Stats
                  FutureBuilder<Map<String, int>>(
                    future: _adminService.getDashboardStats(),
                    builder: (context, snapshot) {
                      final stats =
                          snapshot.data ??
                          {'packages': 0, 'bookings': 0, 'users': 0};
                      final isLoading =
                          snapshot.connectionState == ConnectionState.waiting;

                      return Row(
                        children: [
                          _DashboardStatCard(
                            title: "Packages",
                            count: stats['packages']!,
                            icon: Icons.holiday_village_outlined,
                            color: Colors.orangeAccent,
                            isLoading: isLoading,
                          ),
                          const SizedBox(width: 12),
                          _DashboardStatCard(
                            title: "Bookings",
                            count: stats['bookings']!,
                            icon: Icons.book_online_outlined,
                            color: Colors.blueAccent,
                            isLoading: isLoading,
                          ),
                          const SizedBox(width: 12),
                          _DashboardStatCard(
                            title: "Users",
                            count: stats['users']!,
                            icon: Icons.people_outline,
                            color: Colors.purpleAccent,
                            isLoading: isLoading,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    "Management",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Action Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 10,
                    children: [
                      _ActionCard(
                        title: "Manage Packages",
                        icon: Icons.map,
                        color: primaryColor,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            "/adminViewPackages",
                          ).then((_) => setState(() {}));
                        },
                      ),
                      _ActionCard(
                        title: "Manage Bookings",
                        icon: Icons.confirmation_number,
                        color: secondaryColor,
                        onTap: () {
                          Navigator.pushNamed(context, "/adminViewBooking");
                        },
                      ),
                      _ActionCard(
                        title: "Manage Users",
                        icon: Icons.person_search,
                        color: Colors.blueGrey,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            "/adminViewUserData",
                          ).then((_) => setState(() {}));
                        },
                      ),
                      // Placeholder for future actions
                      _ActionCard(
                        title: "Reports",
                        icon: Icons.analytics_outlined,
                        color: Colors.amber.shade700,
                        onTap: () async {
                          // Future implementation
                          //await insertKelantanPackages();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Coming soon!")),
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

  Widget _buildHeader(BuildContext context, Color primaryColor) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        image: const DecorationImage(
          image: AssetImage(
            'assets/images/kl.jpg',
          ), // Beautiful Thai beach scene placeholder
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black26, // Darken image slightly for text readability
            BlendMode.darken,
          ),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: SignoutButton(authService: _authService),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Welcome Admin,",
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
        height: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
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
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 8),
            isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                : Text(
                    count.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
