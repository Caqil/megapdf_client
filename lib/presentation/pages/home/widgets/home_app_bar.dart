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
          Image.asset(
            'assets/images/logo.png',
            width: 40,
            height: 40,
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
                'All-in-One PDF Converter & Editor',
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
