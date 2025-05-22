import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PDF Tools',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: _features.map((feature) {
            return _FeatureCard(feature: feature);
          }).toList(),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final Feature feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.go(feature.route),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                feature.color.withOpacity(0.1),
                feature.color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: feature.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  feature.icon,
                  size: 32,
                  color: feature.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                feature.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                feature.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Feature {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  const Feature({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}

final List<Feature> _features = [
  Feature(
    title: 'Compress PDF',
    description: 'Reduce file size',
    icon: Icons.compress,
    color: AppColors.compressColor,
    route: '/compress',
  ),
  Feature(
    title: 'Split PDF',
    description: 'Extract pages',
    icon: Icons.call_split,
    color: AppColors.splitColor,
    route: '/split',
  ),
  Feature(
    title: 'Merge PDFs',
    description: 'Combine files',
    icon: Icons.merge,
    color: AppColors.mergeColor,
    route: '/merge',
  ),
  Feature(
    title: 'Watermark',
    description: 'Add text/image',
    icon: Icons.branding_watermark,
    color: AppColors.watermarkColor,
    route: '/watermark',
  ),
  Feature(
    title: 'Convert',
    description: 'Change format',
    icon: Icons.transform,
    color: AppColors.convertColor,
    route: '/convert',
  ),
  Feature(
    title: 'Protect PDF',
    description: 'Add password',
    icon: Icons.lock,
    color: AppColors.protectColor,
    route: '/protect',
  ),
  Feature(
    title: 'Unlock PDF',
    description: 'Remove password',
    icon: Icons.lock_open,
    color: AppColors.unlockColor,
    route: '/unlock',
  ),
  Feature(
    title: 'Rotate Pages',
    description: 'Rotate document',
    icon: Icons.rotate_right,
    color: AppColors.rotateColor,
    route: '/rotate',
  ),
  Feature(
    title: 'Page Numbers',
    description: 'Add numbering',
    icon: Icons.format_list_numbered,
    color: AppColors.pageNumbersColor,
    route: '/page-numbers',
  ),
];
