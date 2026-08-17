import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/shared/theme/app_colors.dart';
import 'package:muc_jomtravel/src/shared/widgets/widgets.dart';

class PointsHistoryView extends StatefulWidget {
  const PointsHistoryView({super.key});

  @override
  State<PointsHistoryView> createState() => _PointsHistoryViewState();
}

class _PointsHistoryViewState extends State<PointsHistoryView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Points History Log',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.4,
          ),
        ),
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'All History'),
                Tab(text: 'Earning'),
                Tab(text: 'Spending'),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('point_history')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final allDocs = snapshot.data?.docs ?? [];

          // Compute Totals
          int totalEarned = 0;
          int totalSpent = 0;
          for (final doc in allDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final amount = (data['amount'] ?? 0) as num;
            if (amount > 0) {
              totalEarned += amount.toInt();
            } else {
              totalSpent += amount.abs().toInt();
            }
          }

          final earnDocs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final amount = (data['amount'] ?? 0) as num;
            final type = data['type'] as String?;
            return amount > 0 || type == 'earn';
          }).toList();

          final spendDocs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final amount = (data['amount'] ?? 0) as num;
            final type = data['type'] as String?;
            return amount < 0 || type == 'spend';
          }).toList();

          return Column(
            children: [
              // Summary Metric Banner
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Total Earned',
                        value: '+$totalEarned pts',
                        color: AppColors.success,
                        icon: Icons.arrow_downward_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Total Spent',
                        value: '-$totalSpent pts',
                        color: AppColors.error,
                        icon: Icons.arrow_upward_rounded,
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTransactionList(
                      docs: allDocs,
                      emptyTitle: 'No transaction activity yet',
                      emptySubtitle:
                          'Your points transactions will show here.',
                    ),
                    _buildTransactionList(
                      docs: earnDocs,
                      emptyTitle: 'No points earned yet',
                      emptySubtitle:
                          'Book trips and packages to earn reward points.',
                    ),
                    _buildTransactionList(
                      docs: spendDocs,
                      emptyTitle: 'No points spent yet',
                      emptySubtitle:
                          'Redeem reward vouchers to use your points.',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList({
    required List<QueryDocumentSnapshot> docs,
    required String emptyTitle,
    required String emptySubtitle,
  }) {
    if (docs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.history_toggle_off_rounded,
                size: 54,
                color: AppColors.textLight,
              ),
              const SizedBox(height: 14),
              Text(
                emptyTitle,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                emptySubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, color: AppColors.divider),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final amount = (data['amount'] ?? 0) as num;
            final isEarn = amount > 0;
            final timestamp = data['timestamp'] as Timestamp?;

            return PointsActivityCard(
              isEarn: isEarn,
              title: data['title'] ?? 'Transaction',
              timestamp: timestamp ?? Timestamp.now(),
              amount: amount.abs().toInt(),
            );
          },
        ),
      ),
    );
  }
}
