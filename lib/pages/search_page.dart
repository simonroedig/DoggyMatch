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

  void _toggleFilter() {
    setState(() {
      _isFilterOpen = !_isFilterOpen;
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
                child:
                    const OtherPersons(), // <-- Updated to display OtherPersons widget
              ),
              if (_isFilterOpen) const FilterMenu(),
            ],
          ),
        ),
      ],
    );
  }
}
