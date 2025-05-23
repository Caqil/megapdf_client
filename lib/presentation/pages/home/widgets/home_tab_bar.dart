import 'package:flutter/material.dart';
import 'package:megapdf_client/core/theme/app_colors.dart';

class HomeTabBar extends StatelessWidget {
  final TabController controller;

  const HomeTabBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 26),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: AppColors.primary(context).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: AppColors.primary(context),
        unselectedLabelColor: AppColors.textSecondary(context),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Quick Tools'),
          Tab(text: 'My Files'),
          Tab(text: 'Recent'),
        ],
      ),
    );
  }
}
