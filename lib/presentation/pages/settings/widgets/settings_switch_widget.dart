// lib/presentation/pages/settings/widgets/settings_switch_widget.dart
import 'package:flutter/material.dart';
import 'package:megapdf_client/core/theme/app_colors.dart';

class SettingsSwitchWidget extends StatefulWidget {
  final String title;
  final String description;
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  const SettingsSwitchWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<SettingsSwitchWidget> createState() => _SettingsSwitchWidgetState();
}

class _SettingsSwitchWidgetState extends State<SettingsSwitchWidget> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
              ),
            ],
          ),
        ),
        Switch(
          value: _value,
          onChanged: (value) {
            setState(() {
              _value = value;
            });
            widget.onChanged(value);
          },
          activeColor: AppColors.primary(context),
        ),
      ],
    );
  }
}
