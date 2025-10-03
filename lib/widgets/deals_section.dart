import 'dart:ui';
import 'package:flutter/material.dart';

class DealsSection extends StatelessWidget {
  final List<DealItem> deals;
  const DealsSection({super.key, required this.deals});

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 220;
    const double cardHeight = 185;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với decoration
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0E4C45), Color(0xFF2FB9A6)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0E4C45).withOpacity(.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.star_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Ưu đãi hấp dẫn',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // List ngang
          SizedBox(
            height: cardHeight,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (_, i) => _DealCard(
                item: deals[i],
                width: cardWidth,
                height: cardHeight,
              ),
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemCount: deals.length,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------- CARD REDESIGN ----------------------

class _DealCard extends StatefulWidget {
  final DealItem item;
  final double width;
  final double height;

  const _DealCard({
    required this.item,
    required this.width,
    required this.height,
  });

  @override
  State<_DealCard> createState() => _DealCardState();
}

class _DealCardState extends State<_DealCard>
    with SingleTickerProviderStateMixin {
  static const Color _primary = Color(0xFF0E4C45);
  static const Color _accent = Color(0xFF2FB9A6);
  bool _pressed = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(20);

    return AnimatedScale(
      scale: _pressed ? .96 : 1,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {},
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: r,
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 160, 205, 198),
                const Color.fromARGB(255, 213, 231, 227),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: _primary.withOpacity(.12), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: _accent.withOpacity(.05),
                blurRadius: 40,
                offset: const Offset(0, 16),
                spreadRadius: -4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: r,
            child: Stack(
              children: [
                // Gradient background nhẹ
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [_accent.withOpacity(.08), Colors.transparent],
                      ),
                    ),
                  ),
                ),

                // Shimmer effect nhẹ
                AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return Positioned(
                      left: -100 + (_shimmerController.value * 300),
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(.15),
                              Colors.transparent,
                            ],
                            stops: const [0, 0.5, 1],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Discount badge với icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.shade50,
                                  Colors.orange.shade50,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.amber.shade200,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  color: Colors.orange.shade600,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.item.discount}%',
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    letterSpacing: .5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _primary.withOpacity(.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.favorite_border,
                              color: _primary,
                              size: 16,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Title
                      Text(
                        widget.item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          letterSpacing: 0.2,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Subtitle
                      Text(
                        widget.item.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF415366).withOpacity(.75),
                          fontSize: 12,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Action button
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_primary, _accent],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _primary.withOpacity(.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Xem chi tiết',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DealItem {
  final String title;
  final String subtitle;
  final int discount;
  const DealItem({
    required this.title,
    required this.subtitle,
    required this.discount,
  });
}
