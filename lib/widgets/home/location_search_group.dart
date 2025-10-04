import 'package:app_test/models/search_value.dart';
import 'package:app_test/screens/home_screen.dart';
import 'package:app_test/widgets/home/searchbox.dart';
import 'package:flutter/material.dart';

import 'location_card.dart';

class LocationSearchGroup extends StatelessWidget {
  final SearchValues initial;
  final ValueChanged<SearchValues> onChanged;
  final ValueChanged<SearchValues> onSearch;

  const LocationSearchGroup({
    super.key,
    required this.initial,
    required this.onChanged,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LocationCard(),
          // Kéo ô tìm kiếm “đè” lên nhẹ nhưng vẫn trong layout → tap được
          Transform.translate(
            offset: const Offset(0, -10),
            child: InlineSearchBox(
              initial: initial,
              onChanged: onChanged,
              onSearch: onSearch,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
