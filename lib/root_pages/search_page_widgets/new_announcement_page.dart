// ignore_for_file: deprecated_member_use

import 'package:doggymatch_flutter/main/ui_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/announcement_dialogs.dart';
import 'package:doggymatch_flutter/services/announcement_service.dart';

class NewAnnouncementPage extends StatefulWidget {
  const NewAnnouncementPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NewAnnouncementPageState createState() => _NewAnnouncementPageState();
}

class _NewAnnouncementPageState extends State<NewAnnouncementPage> {
  final TextEditingController _announcementController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedDate;
  bool _showForever = false;

  final int _minAnnouncementLength = 10;
  final int _minTitleLength = 3;

  bool _hasAnnouncement =
      false; // New variable to track if user has an announcement

  @override
  void initState() {
    super.initState();
    _announcementController.addListener(_updateButtonState);
    _titleController.addListener(_updateButtonState);
    _checkForExistingAnnouncement(); // Check for existing announcement
  }

  @override
  void dispose() {
    _announcementController.removeListener(_updateButtonState);
    _announcementController.dispose();
    _titleController.removeListener(_updateButtonState);
    _titleController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {});
  }

  Future<void> _checkForExistingAnnouncement() async {
    final announcementService = AnnouncementService();
    final hasAnnouncement = await announcementService.hasAnnouncement();
    setState(() {
      _hasAnnouncement = hasAnnouncement;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _showForever = false;
      });
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
    final bool isTextValid = controller.text.length >= minLength;

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
              color: isTextValid
                  ? AppColors.customBlack.withOpacity(0.5)
                  : AppColors.customRed,
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
    final bool isAnnouncementTextValid =
        _announcementController.text.length >= _minAnnouncementLength;
    final bool isTitleTextValid =
        _titleController.text.length >= _minTitleLength;
    final bool isDateValid = _selectedDate != null || _showForever;
    final bool isButtonEnabled =
        isAnnouncementTextValid && isTitleTextValid && isDateValid;

    return WillPopScope(
      onWillPop: () async {
        if (_announcementController.text.isNotEmpty ||
            _titleController.text.isNotEmpty) {
          // Show the dismiss confirmation dialog if there are unsaved changes
          AnnouncementDialogs.showDismissConfirmationDialog(context);
          return false; // Prevent popping the page automatically
        }
        return true; // Allow popping the page
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Create Shout",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
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
            onPressed: () {
              if (_announcementController.text.isNotEmpty ||
                  _titleController.text.isNotEmpty) {
                AnnouncementDialogs.showDismissConfirmationDialog(context);
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        backgroundColor: AppColors.greyLightest,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextFieldWithCounter(
                controller: _titleController,
                maxLength: 50,
                minLength: _minTitleLength,
                labelText: 'Title',
                icon: Icons.title_rounded,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              _buildTextFieldWithCounter(
                controller: _announcementController,
                maxLength: 1000,
                minLength: _minAnnouncementLength,
                labelText: 'Text',
                icon: Icons.announcement_rounded,
                keyboardType: TextInputType.multiline,
                minLines: 3,
                maxLines: null,
              ),
              const SizedBox(height: 16),
              _buildHeadlineWithIcon(
                Icons.date_range_rounded,
                'Show Until',
              ),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: TextEditingController(
                      text: _showForever
                          ? 'Show Forever'
                          : (_selectedDate != null
                              ? DateFormat.yMd().format(_selectedDate!)
                              : ''),
                    ),
                    decoration: InputDecoration(
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: isDateValid
                            ? AppColors.customBlack
                            : AppColors.customRed,
                      ),
                    ),
                    style: const TextStyle(color: AppColors.customBlack),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Show Forever',
                    style: TextStyle(
                      color: AppColors.customBlack,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CupertinoSwitch(
                    value: _showForever,
                    onChanged: (bool value) {
                      setState(() {
                        _showForever = value;
                        if (_showForever) {
                          _selectedDate = null;
                        }
                      });
                    },
                    trackColor: _showForever ? AppColors.brownLight : null,
                    activeColor: AppColors.brownLight,
                    thumbColor: AppColors.bg,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 1,
                  child: ElevatedButton(
                    onPressed: isButtonEnabled
                        ? () {
                            AnnouncementDialogs.showCreateConfirmationDialog(
                                context,
                                _titleController,
                                _announcementController,
                                _selectedDate,
                                _showForever,
                                _hasAnnouncement);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isButtonEnabled
                          ? AppColors.customBlack
                          : Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0, // Increase the vertical padding
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            UIConstants.innerRadius), // Curved edges
                        side: const BorderSide(
                          color: AppColors.customBlack, // Border color
                          width: 3.0, // Border width
                        ),
                      ),
                    ),
                    child: Text(
                      _hasAnnouncement
                          ? 'Create Shout (Replace Old)'
                          : 'Create Shout',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: isButtonEnabled
                            ? FontWeight.bold
                            : FontWeight.normal,
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
