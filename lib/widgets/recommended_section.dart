import 'dart:ui';

import 'package:flutter/material.dart';

class RecommendedSection extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const RecommendedSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0E4C45);
    const spacing = 14.0;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                Text(
                  'Khám phá gần đây',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: primary,
                  ),
                ),
                Spacer(),
                Text(
                  'Xem tất cả',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Grid 2 cột, tính tỉ lệ để card đồng bộ chiều cao
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const crossAxisCount = 2;
                final totalSpacing = spacing * (crossAxisCount - 1);
                final cardWidth =
                    (constraints.maxWidth - totalSpacing) / crossAxisCount;

                // Tỉ lệ ảnh ~16:11 => ổn khi crop
                const imageAspect = 16 / 11;
                final imageHeight = cardWidth / imageAspect;

                // Phần nội dung (title + price/location row)
                const contentHeight = 102.0;

                final cardHeight = imageHeight + contentHeight;
                final ratio = cardWidth / cardHeight;

                return GridView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    childAspectRatio: ratio,
                  ),
                  itemBuilder: (_, i) => _TourCardRefined(
                    data: items[i],
                    width: cardWidth,
                    imageHeight: imageHeight,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TourCardRefined extends StatefulWidget {
  final Map<String, dynamic> data;
  final double width;
  final double imageHeight;

  const _TourCardRefined({
    required this.data,
    required this.width,
    required this.imageHeight,
  });

  @override
  State<_TourCardRefined> createState() => _TourCardRefinedState();
}

class _TourCardRefinedState extends State<_TourCardRefined> {
  static const primary = Color(0xFF0E4C45);
  bool isSaved = false;

  @override
  Widget build(BuildContext context) {
    final price = (widget.data['price'] as num?)?.toStringAsFixed(0) ?? '--';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh + overlay
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  // Ảnh
                  Image.network(
                    widget.data['image'],
                    width: widget.width,
                    height: widget.imageHeight,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: widget.width,
                      height: widget.imageHeight,
                      color: const Color(0xFFF1F5F9),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  // Gradient dưới để nổi giá
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(.35),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Giá (góc dưới-trái)
                  Positioned(
                    left: 10,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '\$$price/đêm',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                  // 🔖 Bookmark
                  Positioned(
                    right: 8,
                    top: 8,
                    child: _GlassCircleButton(
                      size: 40,
                      icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                      iconColor: primary,
                      onTap: () => setState(() => isSaved = !isSaved),
                    ),
                  ),
                ],
              ),
            ),

            // Nội dung
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data['title'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 16,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.data['location'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF64748B),
                          ),
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

// Nút kính mờ tròn dùng lại nhiều nơi
class _GlassCircleButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color iconColor;
  final VoidCallback? onTap;

  const _GlassCircleButton({
    required this.icon,
    this.size = 36,
    this.iconColor = const Color(0xFF0E4C45),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Material(
            color: Colors.white.withOpacity(0.50),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: Center(
                child: Icon(icon, size: size * 0.5, color: iconColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
