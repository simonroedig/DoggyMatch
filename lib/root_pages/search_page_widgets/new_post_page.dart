// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'package:doggymatch_flutter/main/ui_constants.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/posts_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/services/post_service.dart';

class NewPostPage extends StatefulWidget {
  const NewPostPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  final int _minDescriptionLength = 1;
  final int _maxDescriptionLength = 250;
  final int _minImagesRequired = 1;
  final int _maxImagesAllowed = 9;

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_updateButtonState);
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {});
  }

  Future<void> _pickImage() async {
    if (_images.length >= _maxImagesAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can only upload up to 9 images")),
      );
      return;
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _removeImage(int index) async {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _reorderImages(int oldIndex, int newIndex) {
    setState(() {
      final image = _images.removeAt(oldIndex);
      _images.insert(newIndex, image);
    });
  }

  Future<void> _createPost() async {
    if (_descriptionController.text.isEmpty ||
        _descriptionController.text.length < _minDescriptionLength ||
        _images.length < _minImagesRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please provide a valid description and at least one image')),
      );
      return;
    }

    // Show confirmation dialog
    final bool confirmed = await PostsDialogs.showCreateConfirmationDialog(
      context,
      _images,
      _descriptionController,
    );

    if (!confirmed) return;

    setState(() {
      _isUploading = true;
    });

    // Show progress dialog
    PostsDialogs.showProgressDialog(context);

    try {
      await PostService().createPost(
        postDescription: _descriptionController.text,
        images: _images,
      );

      Navigator.of(context).pop(); // Close progress dialog

      // Show success dialog and delay auto-navigation
      PostsDialogs.showSuccessDialog(context);

      // Delay 3 seconds, then navigate back to the search page
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.of(context).pop(); // Go back to the search page
      });
    } catch (e) {
      Navigator.of(context).pop(); // Close progress dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error creating post')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _onBackPressed() async {
    if (_images.isNotEmpty || _descriptionController.text.isNotEmpty) {
      final bool confirmed = await PostsDialogs.showDismissConfirmationDialog(
        context,
      );
      if (confirmed) {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  Widget _buildTextFieldWithCounter({
    required TextEditingController controller,
    required int maxLength,
    required int minLength,
    required String labelText,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    int minLines = 1,
    int? maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) _buildHeadlineWithIcon(icon, labelText),
        TextField(
          controller: controller,
          maxLength: maxLength,
          minLines: minLines,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.customBlack),
          decoration: InputDecoration(
            counterText: '${controller.text.length} / $maxLength',
            counterStyle: TextStyle(
              color: controller.text.length < minLength
                  ? AppColors.customRed
                  : AppColors.customBlack.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeadlineWithIcon(IconData icon, String text,
      {Color textColor = AppColors.customBlack}) {
    return Row(
      children: [
        Icon(icon, color: textColor),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDescriptionValid =
        _descriptionController.text.length >= _minDescriptionLength;
    final bool isButtonEnabled =
        isDescriptionValid && _images.length >= _minImagesRequired;

    return WillPopScope(
      onWillPop: () async {
        await _onBackPressed();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.greyLightest,
          elevation: 0.0,
          scrolledUnderElevation: 0.0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_circle_left_rounded,
              size: 30.0,
              color: AppColors.customBlack,
            ),
            onPressed: _onBackPressed,
          ),
          title: const Text(
            "Create Post",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: AppColors.customBlack,
            ),
          ),
        ),
        backgroundColor: AppColors.greyLightest,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${_images.length}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16.0,
                            color: _images.length < _minImagesRequired
                                ? AppColors.customRed
                                : AppColors.customBlack,
                          ),
                        ),
                        const TextSpan(
                          text: '/9 Images Uploaded',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16.0,
                            color: AppColors.customBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ReorderableGridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                ),
                itemCount: _images.length < _maxImagesAllowed
                    ? _images.length + 1
                    : _images.length, // Show "Add Image" only if less than 9
                onReorder: _reorderImages,
                itemBuilder: (context, index) {
                  if (index == _images.length &&
                      _images.length < _maxImagesAllowed) {
                    return GestureDetector(
                      key: const ValueKey('add_image'),
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.customBlack.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(UIConstants.innerRadius),
                          border: Border.all(
                            color: AppColors.customBlack,
                            width: 3.0,
                          ),
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate_rounded,
                          size: 40.0,
                          color: AppColors.customBlack,
                        ),
                      ),
                    );
                  }

                  return Stack(
                    key: ValueKey(_images[index].path),
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(UIConstants.innerRadius),
                            border: Border.all(
                              color: AppColors.customBlack,
                              width: 3.0,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                UIConstants.innerRadiusClipped),
                            child:
                                Image.file(_images[index], fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.customBlack,
                          ),
                          onPressed: () => _removeImage(index),
                        ),
                      ),
                    ],
                  );
                },
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              const SizedBox(height: 26),
              _buildTextFieldWithCounter(
                controller: _descriptionController,
                maxLength: _maxDescriptionLength,
                minLength: _minDescriptionLength,
                labelText: 'Description',
                icon: Icons.description_rounded,
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: null,
              ),
              const SizedBox(height: 32),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: ElevatedButton(
                    onPressed:
                        isButtonEnabled && !_isUploading ? _createPost : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isButtonEnabled && !_isUploading
                          ? AppColors.customBlack
                          : Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(UIConstants.innerRadius),
                        side: const BorderSide(
                          color: AppColors.customBlack,
                          width: 3.0,
                        ),
                      ),
                    ),
                    child: Text(
                      'Create Post',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: isButtonEnabled
                            ? AppColors.bg
                            : AppColors.customBlack,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
