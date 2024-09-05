// file: own_all_announcements_toggle.dart
import 'package:doggymatch_flutter/pages/notifiers/filter_notifier.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:provider/provider.dart';

class OwnAllAnnouncementsToggle extends StatefulWidget {
  final Function(bool) onToggle; // Callback for when the toggle is changed

  const OwnAllAnnouncementsToggle({super.key, required this.onToggle});

  @override
  // ignore: library_private_types_in_public_api
  _OwnAllAnnouncementsToggleState createState() =>
      _OwnAllAnnouncementsToggleState();
}

class _OwnAllAnnouncementsToggleState extends State<OwnAllAnnouncementsToggle> {
  bool isAllAnnouncSelected = false;

  void toggleSwitch() {
    setState(() {
      isAllAnnouncSelected = !isAllAnnouncSelected;
      Provider.of<FilterNotifier>(context, listen: false).notifyFilterChanged();
    });
    widget.onToggle(isAllAnnouncSelected);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleSwitch,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.45,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: AppColors.customBlack,
            width: 3, // Border width of 3
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          isAllAnnouncSelected ? 'Own Shouts' : 'All Shouts',
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.customBlack,
          ),
        ),
      ),
    );
  }
}
