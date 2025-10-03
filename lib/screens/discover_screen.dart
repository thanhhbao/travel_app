import 'package:flutter/material.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF5F8FB),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 20),
              _Header(),
              SizedBox(height: 24),
              _RecommendedCarousel(),
              SizedBox(height: 24),
              _PopularPlaces(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
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
                      Icon(
                        Icons.search,
                        color: const Color(0xFF0E4C45).withOpacity(.65),
                      ),
                      const SizedBox(width: 12),

                      const Expanded(
                        child: Text(
                          'Tìm điểm đến...',
                          style: TextStyle(
                            color: Color(0xFF818A9A),
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(Icons.tune, color: Color(0xFF0E4C45)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecommendedCarousel extends StatelessWidget {
  const _RecommendedCarousel();

  static const _cards = [
    _DiscoverCardData(
      title: '115/22 Tô Ký, Quận 12',
      price: 95,
      rating: 4.8,
      image:
          'https://images.unsplash.com/photo-1566665797739-1674de7a421a?q=80&w=1548&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      location: 'Thành phố Hồ Chí Minh, Vietnam',
    ),
    _DiscoverCardData(
      title: '20/5 Lê Thị Riêng, Quận 12',
      price: 210,
      rating: 4.9,
      image:
          'https://plus.unsplash.com/premium_photo-1663126298656-33616be83c32?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      location: 'Thành phố Hồ Chí Minh, Vietnam',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Gợi ý cho bạn', onSeeAll: () {}),
          const SizedBox(height: 16),
          SizedBox(
            height: 268,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, index) => _DiscoverCard(data: _cards[index]),
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemCount: _cards.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoverCard extends StatelessWidget {
  final _DiscoverCardData data;
  const _DiscoverCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(data.image, fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: _Badge(
                icon: Icons.star,
                text: data.rating.toStringAsFixed(1),
              ),
            ),
            const Positioned(top: 16, right: 16, child: _Bookmark()),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '\$${data.price}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 25,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          data.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.location,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0E4C45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text('Xem chi tiết'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularPlaces extends StatelessWidget {
  const _PopularPlaces();

  static const _chips = ['Biển', 'Núi', 'Đảo', 'Hồ'];
  static const _places = [
    _DiscoverCardData(
      title: 'Thành Phố Hồ Chí Minh',
      price: 430,
      rating: 5.0,
      location: '273/5 Đường Trần Hưng Đạo, Quận 1',
      image:
          'https://images.unsplash.com/photo-1560448205-4d9b3e6bb6db?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    ),
    _DiscoverCardData(
      title: 'Thành Phố Hồ Chí Minh',

      price: 320,
      rating: 4.8,
      location: '22 Lê Thị Riêng, Quận 12',
      image:
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    ),
    _DiscoverCardData(
      title: 'Thành Phố Hồ Chí Minh',
      price: 200,
      rating: 4.8,
      location: '11/7A Trần Hưng Đạo, Quận 1',
      image:
          'https://plus.unsplash.com/premium_photo-1674676471380-1258cb31b3ac?q=80&w=1618&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    ),
    _DiscoverCardData(
      title: 'Thành Phố Hồ Chí Minh',
      price: 120,
      rating: 4.9,
      location: '30/4A Nguyễn Thị Thập, Quận 7',
      image:
          'https://images.unsplash.com/photo-1560185007-5f0bb1866cab?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    ),
    _DiscoverCardData(
      title: 'Thành Phố Hồ Chí Minh',
      price: 120,
      rating: 4.9,
      location: '123/5 Lê Văn Sỹ, Quận 3',
      image:
          'https://images.unsplash.com/photo-1537726235470-8504e3beef77?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    ),
    _DiscoverCardData(
      title: 'Thành Phố Hồ Chí Minh',
      price: 120,
      rating: 4.9,
      location: '89/3A Phan Xích Long, Phú Nhuận',
      image:
          'https://images.unsplash.com/photo-1560185007-5f0bb1866cab?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    ),
    _DiscoverCardData(
      title: 'Thành Phố Hồ Chí Minh',
      price: 120,
      rating: 4.9,
      location: '156/2 Lê Văn Thọ, Gò Vấp',
      image:
          'https://images.unsplash.com/photo-1489171078254-c3365d6e359f?q=80&w=2062&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    ),
    _DiscoverCardData(
      title: 'Thành Phố Hồ Chí Minh',
      price: 120,
      rating: 4.9,
      location: '342/5 Lý Thường Kiệt, Tân Bình',
      image:
          'https://images.unsplash.com/photo-1560185009-dddeb820c7b7?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Điểm đến nổi bật', onSeeAll: () {}),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, index) =>
                  _CategoryChip(label: _chips[index], selected: index == 0),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: _chips.length,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _places.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (_, index) => _MiniCard(data: _places[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _CategoryChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF0E4C45) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E6EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF0E4C45),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final _DiscoverCardData data;
  const _MiniCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(data.image, fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: _Badge(
                icon: Icons.star,
                text: data.rating.toStringAsFixed(1),
              ),
            ),
            const Positioned(top: 12, right: 12, child: _Bookmark(size: 32)),
            Positioned(
              bottom: 16,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '\$${data.price}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '/đêm',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 12,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          data.location,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  const _SectionTitle({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0E4C45),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onSeeAll,
            child: const Text(
              'Xem tất cả',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Badge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFE6A200)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF1D2433),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bookmark extends StatelessWidget {
  final double size;
  const _Bookmark({this.size = 38});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
        ],
      ),
      child: const Icon(Icons.bookmark_add_outlined, color: Color(0xFF0E4C45)),
    );
  }
}

class _DiscoverCardData {
  final String title;
  final double price;
  final double rating;
  final String location;
  final String image;

  const _DiscoverCardData({
    required this.title,
    required this.price,
    required this.rating,
    required this.location,
    required this.image,
  });
}
