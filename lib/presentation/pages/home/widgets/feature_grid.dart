import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key});

  List<Feature> getFeatures(BuildContext context) {
    return [
      Feature(
        title: 'Compress PDF',
        description: 'Reduce file size',
        icon: Icons.compress,
        color: AppColors.compressColor(context),
        route: '/compress',
      ),
      Feature(
        title: 'Split PDF',
        description: 'Extract pages',
        icon: Icons.call_split,
        color: AppColors.splitColor(context),
        route: '/split',
      ),
      Feature(
        title: 'Merge PDFs',
        description: 'Combine files',
        icon: Icons.merge,
        color: AppColors.mergeColor(context),
        route: '/merge',
      ),
      Feature(
        title: 'Watermark',
        description: 'Add watermarks',
        icon: Icons.branding_watermark,
        color: AppColors.watermarkColor(context),
        route: '/watermark',
      ),
      Feature(
        title: 'Convert',
        description: 'Change formats',
        icon: Icons.transform,
        color: AppColors.convertColor(context),
        route: '/convert',
      ),
      Feature(
        title: 'Protect PDF',
        description: 'Add password',
        icon: Icons.lock,
        color: AppColors.protectColor(context),
        route: '/protect',
      ),
      Feature(
        title: 'Unlock PDF',
        description: 'Remove password',
        icon: Icons.lock_open,
        color: AppColors.unlockColor(context),
        route: '/unlock',
      ),
      Feature(
        title: 'Rotate Pages',
        description: 'Adjust orientation',
        icon: Icons.rotate_right,
        color: AppColors.rotateColor(context),
        route: '/rotate',
      ),
      Feature(
        title: 'Page Numbers',
        description: 'Add numbering',
        icon: Icons.format_list_numbered,
        color: AppColors.pageNumbersColor(context), // Assuming this is static
        route: '/page-numbers',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final features = getFeatures(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PDF Tools',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            return _FeatureCard(feature: features[index]);
          },
        ),
      ],
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final Feature feature;

  const _FeatureCard({required this.feature});

  @override
  _FeatureCardState createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Card(
              elevation: 2,
              shadowColor: widget.feature.color.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => context.go(widget.feature.route),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.feature.color.withOpacity(0.05),
                        Colors.white.withOpacity(0.95),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.feature.color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.feature.icon,
                          size: 30,
                          color: widget.feature.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.feature.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary(context),
                              fontSize: 15,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.feature.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary(context)
                                  .withOpacity(0.7),
                              fontSize: 12,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
