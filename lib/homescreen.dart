import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const TravelBookingApp());
}

class TravelBookingApp extends StatelessWidget {
  const TravelBookingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel Booking',
      theme: ThemeData(
        primaryColor: const Color(0xFF0E4C45), // xanh đậm
        scaffoldBackgroundColor: const Color(
          0xFFFFF7FB,
        ), // nền hồng nhạt như mock
        fontFamily: 'SF Pro Display',
        useMaterial3: false,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final Set<int> _favorites = {1};

  // dữ liệu tour demo
  final List<Map<String, dynamic>> tours = [
    {
      'id': 1,
      'name': 'Nha Trang Beach Escape',
      'price': 350,
      'unit': 'person',
      'image':
          'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=1200&q=80',
      'location': 'Nha Trang, Vietnam',
      'duration': '3 days',
    },
    {
      'id': 2,
      'name': 'Sapa Mountain Adventure',
      'price': 70,
      'unit': 'person',
      'image':
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1200&q=80',
      'location': 'Sapa, Vietnam',
      'duration': '4 days',
    },
  ];

  void _toggleFavorite(int id) {
    setState(
      () =>
          _favorites.contains(id) ? _favorites.remove(id) : _favorites.add(id),
    );
  }

  // ==== FILTER SHEET (chức năng) ====
  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        double budget = 500;
        String duration = 'Any';
        return StatefulBuilder(
          builder: (ctx, setM) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9ECF1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Filter Tours',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Max Budget',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      Text('\$${budget.toInt()}'),
                    ],
                  ),
                  Slider(
                    value: budget,
                    min: 100,
                    max: 2000,
                    divisions: 19,
                    onChanged: (v) => setM(() => budget = v),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Text(
                        'Duration',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Any', '1-3 days', '4-7 days', '7+ days']
                        .map(
                          (e) => ChoiceChip(
                            label: Text(e),
                            selected: duration == e,
                            onSelected: (_) => setM(() => duration = e),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E4C45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        // TODO: áp dụng filter vào danh sách
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _header()),
            SliverToBoxAdapter(
              child: _locationAndSearch(),
            ), // <- đã sửa giống mock
            SliverToBoxAdapter(child: const SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: _sectionTitle('Discover Best\nSuitable Tour'),
            ),
            SliverToBoxAdapter(child: _categories()),
            SliverToBoxAdapter(child: _recommendedHeader()),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.80,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _tourCard(tours[i]),
                  childCount: tours.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  // ======= TOP HEADER =======
  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: Colors.white,
      child: Row(
        children: [
          const Text(
            'TRAVELHUB',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0E4C45),
              letterSpacing: 1.4,
            ),
          ),
          const Spacer(),
          _chipIcon(Icons.wallet_outlined),
          const SizedBox(width: 10),
          _chipIcon(Icons.chat_bubble_outline),
          const SizedBox(width: 10),
          _chipIcon(Icons.notifications_none),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 20,
            backgroundImage: const NetworkImage(
              'https://i.pravatar.cc/150?img=47',
            ),
            backgroundColor: Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _chipIcon(IconData icon) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: const Color(0xFFF3F5F7),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, size: 20, color: const Color(0xFF0E4C45)),
  );

  // ======= LOCATION + SEARCH (MATCH MOCK) =======
  Widget _locationAndSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        children: [
          // Card vị trí
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0E4C45),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0E4C45).withOpacity(0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // icon pin
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.place, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current location',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'District 1 - Ho Chi Minh City',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                // nút tròn mũi tên download bên phải
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D6D64), // xanh nhạt hơn 1 chút
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.file_download_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Ô search pill tách rời, có nút filter BÊN TRONG ô
          Container(
            height: 56,
            padding: const EdgeInsets.only(left: 14, right: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFE9ECF1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey.shade500),
                const SizedBox(width: 10),
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Find tour, destination, and more',
                      hintStyle: TextStyle(
                        color: Color(0xFFB0B6BF),
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                // nút filter nằm trong ô
                InkWell(
                  onTap: _openFilterSheet,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 44,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE9ECF1)),
                    ),
                    child: const Icon(
                      Icons.tune,
                      size: 20,
                      color: Color(0xFF6C7685),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ======= sections chính =======
  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        height: 1.2,
        fontWeight: FontWeight.w900,
        color: Color(0xFF0E4C45),
      ),
    ),
  );

  Widget _categories() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.6,
        children: const [
          _CategoryPill(icon: Icons.beach_access, label: 'Beach Tour'),
          _CategoryPill(icon: Icons.terrain, label: 'Mountain Trek'),
          _CategoryPill(icon: Icons.museum_outlined, label: 'Culture Tour'),
          _CategoryPill(icon: Icons.hiking, label: 'Adventure Trip'),
        ],
      ),
    );
  }

  Widget _recommendedHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
    child: Row(
      children: [
        const Text(
          'Recommended',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0E4C45),
          ),
        ),
        const Spacer(),
        Text(
          'View All',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    ),
  );

  Widget _tourCard(Map<String, dynamic> t) {
    final fav = _favorites.contains(t['id']);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  t['image'],
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: GestureDetector(
                  onTap: () => _toggleFavorite(t['id']),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      fav ? Icons.bookmark : Icons.bookmark_border,
                      size: 18,
                      color: const Color(0xFFFF5678),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t['name'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0E1A1A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '\$${t['price']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0E1A1A),
                          ),
                        ),
                        TextSpan(
                          text: '/${t['unit']}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF6C7685),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          t['location'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======= bottom nav =======
  Widget _bottomNav() {
    final items = [
      Icons.home_filled,
      Icons.search,
      Icons.event_available_outlined,
      Icons.favorite_border,
      Icons.person_outline,
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(items.length, (i) {
              final active = _selectedIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = i),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFF0E4C45)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    items[i],
                    size: 24,
                    color: active ? Colors.white : Colors.grey.shade500,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ======= small widgets =======
class _CategoryPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CategoryPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9ECF1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF0E4C45)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
                color: Color(0xFF0E1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
