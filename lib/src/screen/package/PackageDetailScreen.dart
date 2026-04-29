import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/model/models.dart';
import 'package:muc_jomtravel/src/shared/theme/app_colors.dart';
import '../booking/booking_form.dart';

class PackageDetailScreen extends StatelessWidget {
  final Package package;

  const PackageDetailScreen({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleSection(),
                  const SizedBox(height: 24),
                  _buildQuickInfoRow(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Overview'),
                  const SizedBox(height: 12),
                  _buildDescription(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Experience Highlights'),
                  const SizedBox(height: 16),
                  _buildActivitiesList(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Location & Schedule'),
                  const SizedBox(height: 16),
                  _buildScheduleCard(),
                  const SizedBox(height: 120), // Bottom bar padding
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomAction(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black26,
          child: BackButton(
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            package.image.isNotEmpty
                ? Image.network(package.image.first, fit: BoxFit.cover)
                : Container(color: AppColors.border),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black26, Colors.transparent, Colors.black45],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Top Choice',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            const Icon(Icons.star, color: AppColors.warning, size: 20),
            const Text(' 4.8 ', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text(
              '(120+ reviews)',
              style: TextStyle(color: AppColors.textLight, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          package.title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.error, size: 18),
            const SizedBox(width: 4),
            Text(
              package.location,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickInfoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _infoItem(Icons.timer_outlined, package.duration, 'Duration'),
        _infoItem(Icons.groups_outlined, 'Family', 'Suitable'),
        _infoItem(Icons.translate, 'English/MY', 'Language'),
      ],
    );
  }

  Widget _infoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(label, style: TextStyle(color: AppColors.textLight, fontSize: 12)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      package.description,
      style: TextStyle(
        color: AppColors.textSecondary,
        height: 1.6,
        fontSize: 15,
      ),
    );
  }

  Widget _buildActivitiesList() {
    return Column(
      children: package.activities.map((activity) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  activity,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _scheduleRow(
            Icons.calendar_today,
            'Opening Days',
            '${package.openingDay} - ${package.closingDay}',
          ),
          const Divider(height: 24, color: AppColors.border),
          _scheduleRow(
            Icons.access_time,
            'Opening Hours',
            '${package.openingHours} - ${package.closingHours}',
          ),
          const Divider(height: 24, color: AppColors.border),
          _scheduleRow(
            Icons.phone_outlined,
            'Contact Info',
            package.contactNumber,
          ),
        ],
      ),
    );
  }

  Widget _scheduleRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: AppColors.textLight, fontSize: 14)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Starting from',
                style: TextStyle(color: AppColors.textLight, fontSize: 12),
              ),
              Row(
                children: [
                  Text(
                    'RM ${package.priceAdult}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Text(
                    '/adult',
                    style: TextStyle(color: AppColors.textLight, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingForm(package: package),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
