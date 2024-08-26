import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/widgets/custom_app_bar.dart';
import 'package:doggymatch_flutter/widgets/filter_menu.dart';
import 'package:doggymatch_flutter/widgets/search/other_persons.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  bool _isFilterOpen = false;
  bool _showDogOwners = true;
  bool _showDogSitters = true;

  void _toggleFilter() {
    setState(() {
      _isFilterOpen = !_isFilterOpen;
    });
  }

  void _updateFilter(bool showDogOwners, bool showDogSitters) {
    setState(() {
      _showDogOwners = showDogOwners;
      _showDogSitters = showDogSitters;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppBar(
          isFilterOpen: _isFilterOpen,
          toggleFilter: _toggleFilter,
          showFilterIcon: true,
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                color: AppColors.bg,
                child: OtherPersons(
                  showDogOwners: _showDogOwners,
                  showDogSitters: _showDogSitters,
                ),
              ),
              if (_isFilterOpen)
                FilterMenu(
                  onFilterChanged: _updateFilter,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
