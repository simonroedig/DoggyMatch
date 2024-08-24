import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/constants/colors.dart';
import 'package:doggymatch_flutter/widgets/custom_app_bar.dart';
import 'package:doggymatch_flutter/widgets/filter_menu.dart';

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
                child: const Center(
                  child: Text("Search Page Content goes here"),
                ),
              ),
              if (_isFilterOpen) const FilterMenu(),
            ],
          ),
        ),
      ],
    );
  }
}
