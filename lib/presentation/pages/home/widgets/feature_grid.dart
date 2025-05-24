import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key});

  List<Feature> getFeatures(BuildContext context) {
    // Simple elegant color scheme that adapts to theme
    final primaryColor = AppColors.primary(context);
    final mutedColor = AppColors.textSecondary(context);

    return [
      Feature(
        title: 'Compress PDF',
        description: 'Reduce file size',
        icon: Icons.compress,
        color: primaryColor,
        route: '/compress',
        badge: 'Popular',
      ),
      Feature(
        title: 'Split PDF',
        description: 'Extract pages',
        icon: Icons.call_split,
        color: mutedColor,
        route: '/split',
      ),
      Feature(
        title: 'Merge PDFs',
        description: 'Combine files',
        icon: Icons.merge,
        color: primaryColor,
        route: '/merge',
        badge: 'New',
      ),
      Feature(
        title: 'Watermark',
        description: 'Add watermarks',
        icon: Icons.branding_watermark,
        color: mutedColor,
        route: '/watermark',
      ),
      Feature(
        title: 'Convert',
        description: 'Change formats',
        icon: Icons.transform,
        color: primaryColor,
        route: '/convert',
      ),
      Feature(
        title: 'Protect PDF',
        description: 'Add password',
        icon: Icons.lock,
        color: mutedColor,
        route: '/protect',
      ),
      Feature(
        title: 'Unlock PDF',
        description: 'Remove password',
        icon: Icons.lock_open,
        color: primaryColor,
        route: '/unlock',
      ),
      Feature(
        title: 'Rotate Pages',
        description: 'Fix orientation',
        icon: Icons.rotate_right,
        color: mutedColor,
        route: '/rotate',
      ),
      Feature(
        title: 'Page Numbers',
        description: 'Add numbering',
        icon: Icons.format_list_numbered,
        color: primaryColor,
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
        // Header Section
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant(context),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.build_circle,
                  color: AppColors.textSecondary(context),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PDF Tools',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary(context),
                          ),
                    ),
                    Text(
                      'Professional PDF editing tools',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary(context),
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Grid Section - 3 columns, 3 rows
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.9,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            return _FeatureCard(
              feature: features[index],
              index: index,
            );
          },
        ),
      ],
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final Feature feature;
  final int index;

  const _FeatureCard({
    required this.feature,
    required this.index,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _tapController;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _tapController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _iconScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.02),
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    // Delayed entrance animation
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _hoverController.forward();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _hoverController.reverse();
        });
      }
    });
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _onTap() {
    _tapController.forward().then((_) {
      _tapController.reverse();
      context.push(widget.feature.route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_hoverController, _tapController]),
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: Transform.scale(
              scale:
                  _scaleAnimation.value * (1.0 - _tapController.value * 0.05),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary(context).withOpacity(0.08),
                      blurRadius: _elevationAnimation.value * 1.5,
                      offset: Offset(0, _elevationAnimation.value * 0.5),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Material(
                  elevation: 0,
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _onTap,
                    borderRadius: BorderRadius.circular(20),
                    splashColor: AppColors.surfaceVariant(context),
                    highlightColor: AppColors.surface(context),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _isHovered
                              ? [
                                  AppColors.surface(context),
                                  AppColors.surfaceVariant(context),
                                  AppColors.surface(context),
                                ]
                              : [
                                  AppColors.surface(context),
                                  AppColors.surface(context),
                                ],
                        ),
                        border: Border.all(
                          color: _isHovered
                              ? AppColors.primary(context).withOpacity(0.3)
                              : AppColors.border(context),
                          width: _isHovered ? 1.5 : 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Badge
                          if (widget.feature.badge != null)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.feature.badge == 'New'
                                      ? Colors.blue
                                      : Colors.amber,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.feature.badge!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                          // Content - Full height container
                          SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  // Icon Section
                                  Transform.scale(
                                    scale: _iconScaleAnimation.value,
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: widget.feature.color
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: widget.feature.color
                                              .withOpacity(0.15),
                                          width: 1,
                                        ),
                                      ),
                                      child: Icon(
                                        widget.feature.icon,
                                        size: 24,
                                        color: widget.feature.color,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // Title
                                  Text(
                                    widget.feature.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary(context),
                                          height: 1.2,
                                          fontSize: 13,
                                        ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 6),

                                  // Description
                                  Text(
                                    widget.feature.description,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color:
                                              AppColors.textSecondary(context),
                                          height: 1.3,
                                          fontSize: 10,
                                        ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
  final String? badge;

  const Feature({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
    this.badge,
  });
}
