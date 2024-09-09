// file: own_all_announcements_toggle.dart
import 'package:doggymatch_flutter/notifiers/filter_notifier.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:provider/provider.dart';

class OwnAllPostsToggle extends StatefulWidget {
  final Function(bool) onToggle; // Callback for when the toggle is changed

  const OwnAllPostsToggle({super.key, required this.onToggle});

  @override
  // ignore: library_private_types_in_public_api
  _OwnAllPostsToggleState createState() => _OwnAllPostsToggleState();
}

class _OwnAllPostsToggleState extends State<OwnAllPostsToggle> {
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
          isAllAnnouncSelected ? 'Own Posts' : 'All Posts',
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.customBlack,
          ),
        ),
      ),
    );
  }
}
