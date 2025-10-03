import 'package:app_test/models/search_value.dart';
import 'package:app_test/widgets/header.dart';
import 'package:flutter/material.dart';

import '../widgets/location_search_group.dart';
import '../widgets/recommended_section.dart';
import '../widgets/deals_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Demo data
  final tours = [
    {
      'id': 1,
      'title': '30/31 Thạnh Lộc 35, Quận 12',
      'price': 100,
      'image':
          'https://plus.unsplash.com/premium_photo-1676823553207-758c7a66e9bb?q=80&w=1740&auto=format&fit=crop',
      'location': 'Thành phố Hồ Chí Minh, Vietnam',
    },
    {
      'id': 2,
      'title': '20/56 Thạnh Xuân 52, Quận 12',
      'price': 70,
      'image':
          'https://images.unsplash.com/photo-1564078516393-cf04bd966897?q=80&w=774&auto=format&fit=crop',
      'location': 'Thành phố Hồ Chí Minh, Vietnam',
    },
    {
      'id': 3,
      'title': '15/20 Thạnh Lộc 21, Quận 12',
      'price': 120,
      'image':
          'https://images.unsplash.com/photo-1615874959474-d609969a20ed?q=80&w=1160&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'location': 'Thành phố Hồ Chí Minh, Vietnam',
    },
    {
      'id': 4,
      'title': '5/10 Thạnh Xuân 25, Quận 12',
      'price': 90,
      'image':
          'https://images.unsplash.com/photo-1595526114035-0d45ed16cfbf?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'location': 'Thành phố Hồ Chí Minh, Vietnam',
    },
  ];

  final deals = const [
    DealItem(
      title: 'Giảm 30% giá phòng hạng sang',
      subtitle: 'Ưu đãi cuối tuần cho resort 5 sao.',
      discount: 30,
    ),
    DealItem(
      title: 'Voucher 1 triệu cho khách mới',
      subtitle: 'Áp dụng khi đặt phòng tối thiểu 2 đêm.',
      discount: 20,
    ),
    DealItem(
      title: 'Miễn phí check-in sớm',
      subtitle: 'Đặt trước 10 ngày để nhận thêm buffet sáng.',
      discount: 15,
    ),
  ];

  SearchValues _searchValues = SearchValues();
  void _onSearchPressed(SearchValues v) {
    // TODO: call API tìm kiếm
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),
              const SizedBox(height: 20),

              // Vị trí + hộp tìm kiếm
              LocationSearchGroup(
                initial: _searchValues,
                onChanged: (v) => setState(() => _searchValues = v),
                onSearch: _onSearchPressed,
              ),

              // Sections
              RecommendedSection(items: tours),
              const SizedBox(height: 10),
              DealsSection(deals: deals),
            ],
          ),
        ),
      ),
    );
  }
}
