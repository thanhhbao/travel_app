// lib/screens/stay_detail_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HotelDetailScreen extends StatefulWidget {
  const HotelDetailScreen({super.key, required this.stay});
  final Stay stay;

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreen();
}

class _HotelDetailScreen extends State<HotelDetailScreen> {
  // UI state
  final PageController _pageController = PageController();
  int _imageIndex = 0;

  // Booking state
  DateTimeRange? _dateRange;
  int _selectedRoomIndex = 0;
  int _guests = 2;
  bool _isFavorite = false;

  // Add-ons
  bool _breakfast = false; // $12 / guest / night
  bool _airportPickup = false; // $30 / booking
  bool _spa = false; // $25 / night
  bool _lateCheckout = false; // $15 / booking

  // Reviews (mock local)
  final List<UserReview> _reviews = [
    UserReview(
      author: 'Minh Trí',
      rating: 5,
      text: 'Phòng sạch, view đẹp, nhân viên thân thiện.',
    ),
    UserReview(
      author: 'Lan Anh',
      rating: 4,
      text: 'Vị trí thuận tiện, ăn sáng ổn, sẽ quay lại!',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // default date range: hôm nay + 1 đêm
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: now,
      end: now.add(const Duration(days: 1)),
    );
  }

  int get _nights {
    if (_dateRange == null) return 1;
    return _dateRange!.end.difference(_dateRange!.start).inDays.clamp(1, 365);
  }

  RoomType get _room => widget.stay.rooms[_selectedRoomIndex];

  double get _baseNightly =>
      widget.stay.basePricePerNight * _room.priceMultiplier;

  double _calcTotal() {
    // base
    double total = _baseNightly * _nights;

    // add-ons
    if (_breakfast) {
      total += 12 * _guests * _nights;
    }
    if (_airportPickup) {
      total += 30;
    }
    if (_spa) {
      total += 25 * _nights;
    }
    if (_lateCheckout) {
      total += 15;
    }
    return total;
  }

  String _fmtMoney(num v) {
    // đơn giản: 1,234.56 (không cần intl package)
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - 1 - i;
      buf.write(s[i]);
      if ((s.length - i) > 1 && idx % 3 == 0 && i != s.length - 1) {
        // nothing
      }
    }
    // thêm dấu phẩy ngăn cách
    final chars = s.split('').reversed.toList();
    final out = <String>[];
    for (int i = 0; i < chars.length; i++) {
      out.add(chars[i]);
      if ((i + 1) % 3 == 0 && i + 1 != chars.length) out.add(',');
    }
    return out.reversed.join();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0E4C45),
              onPrimary: Colors.white,
              surfaceTint: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  Future<void> _callManager() async {
    final uri = Uri(scheme: 'tel', path: widget.stay.managerPhone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _snack('Không thể mở trình gọi điện');
    }
  }

  Future<void> _emailManager() async {
    final uri = Uri(
      scheme: 'mailto',
      path: widget.stay.managerEmail,
      queryParameters: {
        'subject': 'Hỏi thông tin đặt phòng: ${widget.stay.name}',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _snack('Không thể mở Email');
    }
  }

  Future<void> _openMap() async {
    final query = Uri.encodeComponent(
      '${widget.stay.name} ${widget.stay.address}',
    );
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _snack('Không thể mở bản đồ');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  double get _avgRating {
    if (_reviews.isEmpty) return widget.stay.rating;
    final sum = _reviews.fold<double>(0.0, (p, e) => p + e.rating);
    return ((sum / _reviews.length + widget.stay.rating) / 2);
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0E4C45);
    const accent = Color(0xFF2FB9A6);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FB),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 320,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
                foregroundColor: primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: widget.stay.images.length,
                        onPageChanged: (i) => setState(() => _imageIndex = i),
                        itemBuilder: (_, i) => Image.network(
                          widget.stay.images[i],
                          fit: BoxFit.cover,
                        ),
                      ),
                      // gradient
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // top controls
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            _glassIcon(
                              context,
                              icon: Icons.arrow_back_ios_new_rounded,
                              onTap: () => Navigator.pop(context),
                            ),
                            const Spacer(),
                            _glassIcon(
                              context,
                              icon: _isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              onTap: () =>
                                  setState(() => _isFavorite = !_isFavorite),
                            ),
                            const SizedBox(width: 10),
                            _glassIcon(context, icon: Icons.share_outlined),
                          ],
                        ),
                      ),
                      // index bubble
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: _glassText(
                          context,
                          text:
                              '${_imageIndex + 1}/${widget.stay.images.length}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title + rating + location
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.stay.name,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: primary,
                                height: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _ratingPill(_avgRating),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _openMap,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.place_outlined,
                              size: 18,
                              color: primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                widget.stay.address,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.map_outlined,
                              color: accent,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date & guests
                      _sectionCard(
                        child: Column(
                          children: [
                            _rowTile(
                              title: 'Ngày ở',
                              trailing: TextButton.icon(
                                onPressed: _pickDateRange,
                                icon: const Icon(Icons.calendar_month_outlined),
                                label: Text(
                                  _dateRange == null
                                      ? 'Chọn ngày'
                                      : '${_dateRange!.start.day}/${_dateRange!.start.month} → ${_dateRange!.end.day}/${_dateRange!.end.month} • $_nights đêm',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: primary,
                                  ),
                                ),
                              ),
                            ),
                            const Divider(height: 20),
                            _rowTile(
                              title: 'Số khách',
                              trailing: _counter(
                                value: _guests,
                                min: 1,
                                max: _room.capacity,
                                onChanged: (v) => setState(() => _guests = v),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Room types
                      const Text(
                        'Loại phòng',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _sectionCard(
                        child: Column(
                          children: [
                            for (
                              int i = 0;
                              i < widget.stay.rooms.length;
                              i++
                            ) ...[
                              _roomTile(widget.stay.rooms[i], i),
                              if (i != widget.stay.rooms.length - 1)
                                const Divider(height: 18),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Amenities
                      const Text(
                        'Dịch vụ & tiện nghi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _sectionCard(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: widget.stay.amenities
                              .map((e) => _amenityChip(e))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Add-ons
                      const Text(
                        'Bổ sung (tính phí)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _sectionCard(
                        child: Column(
                          children: [
                            _addonTile(
                              label: 'Bữa sáng',
                              desc: '\$12 / khách / đêm',
                              value: _breakfast,
                              onChanged: (v) => setState(() => _breakfast = v),
                            ),
                            const Divider(height: 18),
                            _addonTile(
                              label: 'Đưa đón sân bay',
                              desc: '\$30 / lượt',
                              value: _airportPickup,
                              onChanged: (v) =>
                                  setState(() => _airportPickup = v),
                            ),
                            const Divider(height: 18),
                            _addonTile(
                              label: 'Spa & xông hơi',
                              desc: '\$25 / đêm',
                              value: _spa,
                              onChanged: (v) => setState(() => _spa = v),
                            ),
                            const Divider(height: 18),
                            _addonTile(
                              label: 'Trả phòng trễ',
                              desc: '\$15 / lượt',
                              value: _lateCheckout,
                              onChanged: (v) =>
                                  setState(() => _lateCheckout = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Contact manager
                      const Text(
                        'Liên hệ quản lý',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _sectionCard(
                        child: Row(
                          children: [
                            _actionChip(
                              icon: Icons.call,
                              label: 'Gọi',
                              onTap: _callManager,
                            ),
                            const SizedBox(width: 10),
                            _actionChip(
                              icon: Icons.mail_outline,
                              label: 'Email',
                              onTap: _emailManager,
                            ),
                            const SizedBox(width: 10),
                            _actionChip(
                              icon: Icons.chat_bubble_outline,
                              label: 'Chat',
                              onTap: () => _snack('Mở chat (mock)'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Reviews
                      Row(
                        children: [
                          const Text(
                            'Đánh giá',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: primary,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _openWriteReview,
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Viết đánh giá'),
                          ),
                        ],
                      ),
                      _sectionCard(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber),
                                const SizedBox(width: 6),
                                Text(
                                  _avgRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${_reviews.length} đánh giá)',
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            for (final r in _reviews) ...[
                              _reviewTile(r),
                              if (r != _reviews.last) const Divider(height: 18),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Sticky bottom price bar
          Positioned(
            left: 12,
            right: 12,
            bottom: 12 + MediaQuery.of(context).padding.bottom,
            child: _bottomBar(
              pricePerNight: _baseNightly,
              nights: _nights,
              total: _calcTotal(),
              onBook: _confirmBooking,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Widgets nhỏ ----------

  Widget _glassIcon(
    BuildContext context, {
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.white.withOpacity(.7),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(icon, size: 20, color: const Color(0xFF0E4C45)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassText(BuildContext context, {required String text}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          color: Colors.white.withOpacity(.6),
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF0E4C45),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _ratingPill(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0E4C45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _rowTile({required String title, required Widget trailing}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF0E4C45),
          ),
        ),
        const Spacer(),
        trailing,
      ],
    );
  }

  Widget _counter({
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    void inc() => onChanged((value + 1).clamp(min, max));
    void dec() => onChanged((value - 1).clamp(min, max));
    return Row(
      children: [
        _miniBtn(Icons.remove, onTap: dec),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '$value',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF0E4C45),
              fontSize: 16,
            ),
          ),
        ),
        _miniBtn(Icons.add, onTap: inc),
      ],
    );
  }

  Widget _miniBtn(IconData icon, {VoidCallback? onTap}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Material(
        color: const Color(0xFFEFF6F6),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 18, color: const Color(0xFF0E4C45)),
          ),
        ),
      ),
    );
  }

  Widget _roomTile(RoomType room, int index) {
    final selected = index == _selectedRoomIndex;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedRoomIndex = index;
        // reset guests nếu vượt capacity
        if (_guests > room.capacity) _guests = room.capacity;
      }),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF2FB9A6).withOpacity(.12)
                    : const Color(0xFFF0F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.king_bed_rounded,
                color: Color(0xFF0E4C45),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0E4C45),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tối đa ${room.capacity} khách • ${(room.priceMultiplier * 100).toStringAsFixed(0)}% giá cơ bản',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF0E4C45) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                selected ? 'Đang chọn' : 'Chọn',
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF0E4C45),
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _amenityChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF2FB9A6), size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF0E4C45),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _addonTile({
    required String label,
    required String desc,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0E4C45),
                ),
              ),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(color: Color(0xFF64748B))),
            ],
          ),
        ),
        Switch(
          value: value,
          activeColor: const Color(0xFF2FB9A6),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _reviewTile(UserReview r) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    r.author,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0E4C45),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < r.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(r.text, style: const TextStyle(color: Color(0xFF475569))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bottomBar({
    required double pricePerNight,
    required int nights,
    required double total,
    required VoidCallback onBook,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(.3), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Giá mỗi đêm',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '\$${_fmtMoney(pricePerNight)}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFF0E4C45),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '  × $nights đêm',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          'Tổng:',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            '\$${_fmtMoney(total)}',
                            key: ValueKey(total.round()),
                            style: const TextStyle(
                              color: Color(0xFF0E4C45),
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: onBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E4C45),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock_clock, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Đặt ngay',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmBooking() {
    final total = _calcTotal();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _glassSheet(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Xác nhận đặt phòng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0E4C45),
                  ),
                ),
                const SizedBox(height: 10),
                _sumRow('Cơ sở', widget.stay.name),
                _sumRow('Loại phòng', _room.name),
                _sumRow(
                  'Ngày',
                  _dateRange == null
                      ? '-'
                      : '${_dateRange!.start.day}/${_dateRange!.start.month} → ${_dateRange!.end.day}/${_dateRange!.end.month}  ($_nights đêm)',
                ),
                _sumRow('Khách', '$_guests'),
                _sumRow(
                  'Bổ sung',
                  [
                    if (_breakfast) 'Bữa sáng',
                    if (_airportPickup) 'Đón sân bay',
                    if (_spa) 'Spa',
                    if (_lateCheckout) 'Trả phòng trễ',
                  ].join(', ').ifEmpty('-'),
                ),
                const Divider(height: 22),
                _sumRow('Tổng', '\$${_fmtMoney(total)}', bold: true),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0E4C45),
                          side: const BorderSide(color: Color(0xFF0E4C45)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Quay lại',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _snack('Đặt phòng thành công!');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2FB9A6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Xác nhận',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openWriteReview() {
    int tempRating = 5;
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return _glassSheet(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Viết đánh giá',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0E4C45),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (i) => IconButton(
                        onPressed: () => setState(() => tempRating = i + 1),
                        icon: Icon(
                          i < tempRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Chia sẻ trải nghiệm của bạn...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.teal.shade100,
                          width: 1,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _reviews.insert(
                            0,
                            UserReview(
                              author: 'Bạn',
                              rating: tempRating,
                              text: controller.text.trim().ifEmpty(
                                'Tuyệt vời!',
                              ),
                            ),
                          );
                        });
                        Navigator.pop(context);
                        _snack('Cảm ơn bạn đã đánh giá!');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E4C45),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Gửi đánh giá',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _glassSheet({required Widget child}) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(color: Colors.white.withOpacity(.92), child: child),
      ),
    );
  }

  Widget _sumRow(String k, String v, {bool bold = false}) {
    const primary = Color(0xFF0E4C45);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            k,
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: primary,
                fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _actionChip({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: .06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF0E4C45), size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0E4C45),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    ),
  );
}

// ------- Models & sample -------

class Stay {
  final String id;
  final String name;
  final String address;
  final double rating;
  final double basePricePerNight;
  final List<String> images;
  final List<String> amenities;
  final List<RoomType> rooms;
  final String managerPhone;
  final String managerEmail;

  Stay({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.basePricePerNight,
    required this.images,
    required this.amenities,
    required this.rooms,
    required this.managerPhone,
    required this.managerEmail,
  });
}

class RoomType {
  final String name;
  final int capacity;
  final double priceMultiplier; // 1.0 = giá cơ bản

  const RoomType({
    required this.name,
    required this.capacity,
    required this.priceMultiplier,
  });
}

class UserReview {
  final String author;
  final int rating;
  final String text;

  UserReview({required this.author, required this.rating, required this.text});
}

// tiện extension nhỏ
extension _X on String {
  String ifEmpty(String alt) => isEmpty ? alt : this;
}

// ------- Demo usage -------
// Gọi màn hình với dữ liệu mẫu (vd. từ list):
//
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (_) => StayDetailScreen(stay: demoStay),
//   ),
// );

final demoStay = Stay(
  id: 'stay_hcm_01',
  name: 'The Horizon Riverside',
  address: '151 Nguyễn Bỉnh Khiêm, Quận 1, TP.HCM',
  rating: 4.7,
  basePricePerNight: 120,
  images: const [
    // Unsplash – nội thất/phòng ở
    'https://images.unsplash.com/photo-1559592413-7cde4f75cc78?w=1600',
    'https://images.unsplash.com/photo-1505692794403-34d4982b4d41?w=1600',
    'https://images.unsplash.com/photo-1519710164239-da123dc03ef4?w=1600',
    'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=1600',
  ],
  amenities: const [
    'Wifi miễn phí',
    'Hồ bơi vô cực',
    'Gym 24/7',
    'Giặt ủi',
    'Bãi đỗ xe',
    'Quầy bar',
    'Bếp chung',
    'Gần trung tâm',
  ],
  rooms: const [
    RoomType(name: 'Standard Queen', capacity: 2, priceMultiplier: 1.0),
    RoomType(name: 'Deluxe King', capacity: 3, priceMultiplier: 1.25),
    RoomType(name: 'Family Suite', capacity: 4, priceMultiplier: 1.6),
  ],
  managerPhone: '+84901234567',
  managerEmail: 'manager@horizon.example',
);
