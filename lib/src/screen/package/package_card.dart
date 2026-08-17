import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/model/models.dart';
import 'package:muc_jomtravel/src/screen/package/PackageDetailScreen.dart';
import 'package:muc_jomtravel/src/shared/theme/app_colors.dart';

class PackageCard extends StatelessWidget {
  final Package package;
  final bool isHorizontal;

  const PackageCard({
    super.key,
    required this.package,
    this.isHorizontal = false,
  });

  // In-memory cache for ratings to avoid redundant network queries
  static final Map<String, ({double avg, int count})> _ratingCache = {};

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: isHorizontal
          ? _buildHeroEditorialCard(context)
          : _buildBentoCard(context),
    );
  }

  /// Large Cinematic Hero Editorial Card (used in Trending Carousel)
  Widget _buildHeroEditorialCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        width: 290,
        margin: const EdgeInsets.only(right: 16, bottom: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.1),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background Image with Disk & Memory Caching
              Positioned.fill(
                child: package.image.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: package.image.first,
                        fit: BoxFit.cover,
                        memCacheWidth: 800,
                        placeholder: (context, url) => Container(
                          color: AppColors.surfaceSubtle,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.surfaceSubtle,
                          child: const Icon(
                            Icons.landscape_rounded,
                            size: 48,
                            color: AppColors.textLight,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.surfaceSubtle,
                        child: const Icon(
                          Icons.landscape_rounded,
                          size: 48,
                          color: AppColors.textLight,
                        ),
                      ),
              ),

              // Gradient Scrim
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),

              // Top Badges
              Positioned(
                top: 14,
                left: 14,
                right: 14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Location Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 120),
                            child: Text(
                              package.location,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Rating Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _buildRatingBadge(isDarkBg: true),
                    ),
                  ],
                ),
              ),

              // Bottom Content
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        package.duration.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      package.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'FROM',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'RM ${package.priceAdult.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Compact Grid Bento Card
  Widget _buildBentoCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight, width: 1),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with rounded top corners
            Expanded(
              flex: 6,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    package.image.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: package.image.first,
                            fit: BoxFit.cover,
                            memCacheWidth: 500,
                            placeholder: (context, url) => Container(
                              color: AppColors.surfaceSubtle,
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.surfaceSubtle,
                              child: const Icon(
                                Icons.landscape_rounded,
                                size: 36,
                                color: AppColors.textLight,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.surfaceSubtle,
                            child: const Icon(
                              Icons.landscape_rounded,
                              size: 36,
                              color: AppColors.textLight,
                            ),
                          ),
                    // Price tag
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'RM ${package.priceAdult.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    package.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 12,
                        color: AppColors.coral,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          package.location,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildRatingBadge(isDarkBg: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBadge({required bool isDarkBg}) {
    if (_ratingCache.containsKey(package.packageId)) {
      final cached = _ratingCache[package.packageId]!;
      return _renderRatingRow(cached.avg, cached.count, isDarkBg);
    }

    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('feedbacks')
          .where('package_id', isEqualTo: package.packageId)
          .where('status', isEqualTo: 'approved')
          .where('is_visible', isEqualTo: true)
          .get(const GetOptions(source: Source.serverAndCache)),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final count = docs.length;
        double avgRating = 0;
        if (count > 0) {
          final total = docs.fold<int>(0, (acc, doc) {
            final ratingValue = doc.data()['rating'];
            int rating = 0;
            if (ratingValue is int) {
              rating = ratingValue;
            } else if (ratingValue is double) {
              rating = ratingValue.round();
            } else if (ratingValue is String) {
              rating = int.tryParse(ratingValue) ?? 0;
            }
            return acc + rating;
          });
          avgRating = total / count;
          _ratingCache[package.packageId] = (avg: avgRating, count: count);
        }

        return _renderRatingRow(avgRating, count, isDarkBg);
      },
    );
  }

  Widget _renderRatingRow(double avgRating, int count, bool isDarkBg) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          size: 14,
          color: count > 0
              ? AppColors.warning
              : (isDarkBg ? Colors.white54 : AppColors.textLight),
        ),
        const SizedBox(width: 3),
        Text(
          count == 0 ? 'New' : avgRating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isDarkBg ? Colors.white : AppColors.textPrimary,
          ),
        ),
        if (count > 0) ...[
          const SizedBox(width: 2),
          Text(
            '($count)',
            style: TextStyle(
              fontSize: 10,
              color: isDarkBg ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PackageDetailScreen(package: package),
      ),
    );
  }
}
