// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'package:doggymatch_flutter/main/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/ENUM_post_filter_option.dart';

class PostsToggle extends StatefulWidget {
  final Function(PostFilterOption) onToggle;

  const PostsToggle({Key? key, required this.onToggle}) : super(key: key);

  @override
  _OwnAllPostsToggleState createState() => _OwnAllPostsToggleState();
}

class _OwnAllPostsToggleState extends State<PostsToggle> {
  PostFilterOption _currentOption = PostFilterOption.allPosts;

  void toggleSwitch() {
    setState(() {
      // Cycle to the next option
      _currentOption = PostFilterOption
          .values[(_currentOption.index + 1) % PostFilterOption.values.length];
    });
    widget.onToggle(_currentOption);
  }

  @override
  Widget build(BuildContext context) {
    Widget displayText;
    switch (_currentOption) {
      case PostFilterOption.friendsPosts:
        displayText = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Custom icon combination for Friends Posts
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
            const Text('Friends Posts'),
          ],
        );
        break;
      case PostFilterOption.allPosts:
        displayText = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Custom icon combination for All Posts
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.photo_library,
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
            const Text('All Posts'),
          ],
        );
        break;
      case PostFilterOption.likedPosts:
        displayText = const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite), // Filled heart icon
            SizedBox(width: 4),
            Text('Liked Posts'),
          ],
        );
        break;
      case PostFilterOption.savedPosts:
        displayText = const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark), // Filled save icon
            SizedBox(width: 0),
            Text('Saved Posts'),
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
