import 'package:flutter/material.dart';
import 'package:megapdf_client/core/theme/app_colors.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentTabIndex;
  final bool isGridView;
  final VoidCallback onToggleView;
  final Function(String) onSearch;
  final VoidCallback onProfileTap;

  const HomeAppBar({
    super.key,
    required this.currentTabIndex,
    required this.isGridView,
    required this.onToggleView,
    required this.onSearch,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface(context),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.picture_as_pdf,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MegaPDF',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
              ),
              Text(
                'Your PDF Workspace',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
              ),
            ],
          ),
        ],
      ),
      // actions: [
      //   IconButton(
      //     onPressed: () => _showSearchDialog(context),
      //     icon: const Icon(Icons.search),
      //     color: AppColors.textSecondary(context),
      //     tooltip: 'Search Files',
      //   ),
      //   if (currentTabIndex == 1) // Files tab
      //     IconButton(
      //       onPressed: onToggleView,
      //       icon: Icon(isGridView ? Icons.list : Icons.grid_view),
      //       color: AppColors.textSecondary(context),
      //       tooltip: isGridView ? 'List View' : 'Grid View',
      //     ),
      //   IconButton(
      //     onPressed: onProfileTap,
      //     icon: const Icon(Icons.account_circle),
      //     color: AppColors.textSecondary(context),
      //     tooltip: 'Profile',
      //   ),
      // ],
    );
  }

  // void _showSearchDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Search Files'),
  //       content: TextField(
  //         decoration: const InputDecoration(
  //           hintText: 'Enter file name...',
  //           prefixIcon: Icon(Icons.search),
  //         ),
  //         onChanged: (value) {
  //           onSearch(value);
  //           Navigator.pop(context);
  //         },
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
