// lib/presentation/widgets/general_settings_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/settings_provider.dart';
import 'settings_section_widget.dart';

class GeneralSettingsSection extends ConsumerWidget {
  final SettingsState state;

  const GeneralSettingsSection({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsSectionWidget(
      title: 'General',
      icon: Icons.tune,
      iconColor: AppColors.primary(context),
      children: [
        // Theme Setting
        SettingsItemWidget(
          icon: _getThemeIcon(state.themeMode),
          iconColor: AppColors.primary(context),
          title: 'Appearance',
          subtitle: 'App theme: ${state.themeModeDisplayName}',
          trailing: DropdownButton<ThemeMode>(
            value: state.themeMode,
            underline: const SizedBox.shrink(),
            items: const [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text('System'),
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text('Light'),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Text('Dark'),
              ),
            ],
            onChanged: (ThemeMode? value) {
              if (value != null) {
                ref
                    .read(settingsNotifierProvider.notifier)
                    .updateThemeMode(value);
              }
            },
          ),
        ),

        const Divider(height: 1, indent: 16, endIndent: 16),

        // File Preview Setting
        SettingsItemWidget(
          icon: Icons.visibility,
          iconColor: AppColors.info(context),
          title: 'File Preview',
          subtitle: 'Show thumbnails and file previews',
          trailing: Switch(
            value: state.showFilePreview,
            onChanged: (value) {
              ref
                  .read(settingsNotifierProvider.notifier)
                  .updateShowFilePreview(value);
            },
            activeColor: AppColors.primary(context),
          ),
        ),

        const Divider(height: 1, indent: 16, endIndent: 16),

        // Auto-save Setting
        SettingsItemWidget(
          icon: Icons.save,
          iconColor: AppColors.success(context),
          title: 'Auto-save Results',
          subtitle: 'Automatically save processed files',
          trailing: Switch(
            value: state.autoSaveResults,
            onChanged: (value) {
              ref
                  .read(settingsNotifierProvider.notifier)
                  .updateAutoSaveResults(value);
            },
            activeColor: AppColors.primary(context),
          ),
        ),

        const Divider(height: 1, indent: 16, endIndent: 16),

        // Default Quality Setting
        SettingsItemWidget(
          icon: Icons.high_quality,
          iconColor: AppColors.warning(context),
          title: 'Default Quality',
          subtitle: 'Compression quality: ${state.defaultQuality}%',
          onTap: () => _showQualityDialog(context, ref),
        ),

        const Divider(height: 1, indent: 16, endIndent: 16),

        // File Naming Setting
        SettingsItemWidget(
          icon: Icons.label,
          iconColor: AppColors.secondary(context),
          title: 'File Naming',
          subtitle: state.fileNamingDisplayName,
          onTap: () => _showFileNamingDialog(context, ref),
        ),

        const Divider(height: 1, indent: 16, endIndent: 16),

        // Language Setting (placeholder)
        SettingsItemWidget(
          icon: Icons.language,
          iconColor: AppColors.info(context),
          title: 'Language',
          subtitle: 'English (US)',
          onTap: () => _showLanguageDialog(context),
          trailing: Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary(context),
            size: 20,
          ),
        ),
      ],
    );
  }

  IconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  void _showQualityDialog(BuildContext context, WidgetRef ref) {
    int tempQuality = ref.read(settingsNotifierProvider).defaultQuality;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Default Compression Quality'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Quality: ${tempQuality}%',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Slider(
                  value: tempQuality.toDouble(),
                  min: 10,
                  max: 100,
                  divisions: 18,
                  activeColor: AppColors.primary(context),
                  onChanged: (value) {
                    setState(() {
                      tempQuality = value.round();
                    });
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lower size',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                    ),
                    Text(
                      'Higher quality',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.info(context).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.info(context),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This will be used as the default quality for compression operations.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.info(context),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(settingsNotifierProvider.notifier)
                  .updateDefaultQuality(tempQuality);
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showFileNamingDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('File Naming Pattern'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text('Add timestamp'),
              subtitle: Text('file_20241215_143022.pdf'),
              value: 'timestamp',
              groupValue: ref.read(settingsNotifierProvider).fileNamingPattern,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(settingsNotifierProvider.notifier)
                      .updateFileNamingPattern(value);
                  Navigator.pop(context);
                }
              },
              activeColor: AppColors.primary(context),
            ),
            RadioListTile<String>(
              title: Text('Keep original'),
              subtitle: Text('document.pdf'),
              value: 'original',
              groupValue: ref.read(settingsNotifierProvider).fileNamingPattern,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(settingsNotifierProvider.notifier)
                      .updateFileNamingPattern(value);
                  Navigator.pop(context);
                }
              },
              activeColor: AppColors.primary(context),
            ),
            RadioListTile<String>(
              title: Text('Add operation name'),
              subtitle: Text('compressed_document.pdf'),
              value: 'operation',
              groupValue: ref.read(settingsNotifierProvider).fileNamingPattern,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(settingsNotifierProvider.notifier)
                      .updateFileNamingPattern(value);
                  Navigator.pop(context);
                }
              },
              activeColor: AppColors.primary(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('English (US)'),
              trailing: Icon(Icons.check, color: AppColors.primary(context)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: Text('Spanish'),
              subtitle: Text('Coming soon'),
              enabled: false,
              onTap: null,
            ),
            ListTile(
              title: Text('French'),
              subtitle: Text('Coming soon'),
              enabled: false,
              onTap: null,
            ),
            ListTile(
              title: Text('German'),
              subtitle: Text('Coming soon'),
              enabled: false,
              onTap: null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
