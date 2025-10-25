// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'package:doggymatch_flutter/main/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/notifiers/filter_notifier.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/ENUM_shouts_filter_option.dart';
import 'package:provider/provider.dart';

class AnnouncementsToggle extends StatefulWidget {
  final Function(ShoutsFilterOption) onToggle;
  final ShoutsFilterOption currentOption;

  const AnnouncementsToggle({
    Key? key,
    required this.onToggle,
    required this.currentOption,
  }) : super(key: key);

  @override
  _OwnAllAnnouncementsToggleState createState() =>
      _OwnAllAnnouncementsToggleState();
}

class _OwnAllAnnouncementsToggleState extends State<AnnouncementsToggle> {
  late ShoutsFilterOption _currentOption;

  @override
  void initState() {
    super.initState();
    _currentOption = widget.currentOption;
  }

  @override
  void didUpdateWidget(AnnouncementsToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentOption != oldWidget.currentOption) {
      setState(() {
        _currentOption = widget.currentOption;
      });
    }
  }

  void toggleSwitch() {
    if (mounted) {
      setState(() {
        _currentOption = ShoutsFilterOption.values[
            (_currentOption.index + 1) % ShoutsFilterOption.values.length];
        Provider.of<FilterNotifier>(context, listen: false)
            .notifyFilterChanged();
      });
    }
    widget.onToggle(_currentOption);
  }

  @override
  Widget build(BuildContext context) {
    Widget displayText;
    switch (_currentOption) {
      case ShoutsFilterOption.friendsShouts:
        displayText = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Custom icon combination for Friends Shouts
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people_alt_rounded,
                    size: 24, color: AppColors.customBlack),
                const SizedBox(width: 4),
                Transform.translate(
                  offset: const Offset(-6, -3), // Adjust icon position
                  child: const Icon(Icons.check_rounded,
                      size: 16, color: AppColors.customBlack),
                ),
              ],
            ),
            const SizedBox(width: 0),
            const Text('Friends Shouts'),
          ],
        );
        break;
      case ShoutsFilterOption.allShouts:
        displayText = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Custom icon combination for All Shouts
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.campaign,
                    size: 24, color: AppColors.customBlack),
                const SizedBox(width: 4),
                Transform.translate(
                  offset: const Offset(-6, -3), // Adjust icon position
                  child: const Icon(Icons.filter_list_rounded,
                      size: 16, color: AppColors.customBlack),
                ),
              ],
            ),
            const SizedBox(width: 0),
            const Text('All Shouts'),
          ],
        );
        break;
    }

    return GestureDetector(
      onTap: toggleSwitch,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.55,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(UIConstants.outerRadius),
          border: Border.all(
            color: AppColors.customBlack,
            width: 3, // Border width of 3
          ),
        ),
        alignment: Alignment.center,
        child: DefaultTextStyle(
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.customBlack,
          ),
          child: displayText,
        ),
      ),
    );
  }
}
