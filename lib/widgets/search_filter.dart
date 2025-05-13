import 'package:flutter/material.dart';

class SearchFilter extends StatelessWidget {
  final Function(String) onSearch;
  final Function(String) onFilter;

  const SearchFilter({
    Key? key,
    required this.onSearch,
    required this.onFilter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Search',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: onSearch,
        ),
        DropdownButton<String>(
          hint: const Text('Filter by Category'),
          items: ['Books', 'Notes', 'Others']
              .map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ))
              .toList(),
          onChanged: onFilter,
        ),
      ],
    );
  }
}