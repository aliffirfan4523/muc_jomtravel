import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/screen/booking/booking_history.dart';
import 'package:muc_jomtravel/src/screen/homepage/user_profile.dart';
import 'package:muc_jomtravel/src/screen/voucher_points/view_voucher_points.dart';
import 'package:muc_jomtravel/src/shared/notifications.dart';
import 'package:muc_jomtravel/src/shared/theme/app_colors.dart';

import 'user_dashboard.dart';

class UserNavigationView extends StatefulWidget {
  final int selectedIndex;
  const UserNavigationView({super.key, this.selectedIndex = 0});

  @override
  State<UserNavigationView> createState() => _UserNavigationViewState();
}

class _UserNavigationViewState extends State<UserNavigationView> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  void _changeTab(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ChangeTabNotification>(
      onNotification: (notification) {
        _changeTab(notification.index);
        return true;
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            UserDashboardScreen(),
            BookingHistoryScreen(),
            ViewVoucherPoints(),
            UserProfileScreen(),
          ],
        ),
        bottomNavigationBar: _buildFloatingGlassNav(),
      ),
    );
  }

  Widget _buildFloatingGlassNav() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      index: 0,
                      icon: Icons.explore_rounded,
                      outlineIcon: Icons.explore_outlined,
                      label: 'Explore',
                    ),
                    _buildNavItem(
                      index: 1,
                      icon: Icons.confirmation_number_rounded,
                      outlineIcon: Icons.confirmation_number_outlined,
                      label: 'Trips',
                    ),
                    _buildNavItem(
                      index: 2,
                      icon: Icons.card_giftcard_rounded,
                      outlineIcon: Icons.card_giftcard_outlined,
                      label: 'Rewards',
                    ),
                    _buildNavItem(
                      index: 3,
                      icon: Icons.person_rounded,
                      outlineIcon: Icons.person_outline_rounded,
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData outlineIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _changeTab(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? icon : outlineIcon,
              size: 22,
              color: isSelected ? AppColors.primary : AppColors.textLight,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
