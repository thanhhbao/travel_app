import 'dart:ui';
import 'package:flutter/material.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  // ----- Mock data
  final List<TripData> _upcomingTrips = [
    TripData(
      name: 'Vinpearl Resort & Spa Hạ Long',
      location: 'Hạ Long, Quảng Ninh, Việt Nam',
      address: 'Đảo Rều, Bãi Cháy, Hạ Long, Quảng Ninh 200000, Việt Nam',
      rating: 4.8,
      price: 1500,
      imageUrl:
          'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?q=80&w=1548&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      duration: '5 ngày',
      checkInDate: '15/11/2024',
      checkOutDate: '20/11/2024',
      status: TripStatus.upcoming,
    ),
    TripData(
      name: 'The Reverie Saigon',
      location: 'Quận 1, TP. Hồ Chí Minh, Việt Nam',
      address: '22-36 Nguyễn Huệ, Bến Nghé, Quận 1, TP.HCM 700000, Việt Nam',
      rating: 4.9,
      price: 2000,
      imageUrl:
          'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=1200&auto=format&fit=crop&q=80',
      duration: '3 ngày',
      checkInDate: '25/11/2024',
      checkOutDate: '28/11/2024',
      status: TripStatus.upcoming,
    ),
    TripData(
      name: 'InterContinental Danang Sun Peninsula Resort',
      location: 'Sơn Trà, Đà Nẵng, Việt Nam',
      address: 'Bãi Bắc, Thọ Quang, Sơn Trà, Đà Nẵng 550000, Việt Nam',
      rating: 4.7,
      price: 1800,
      imageUrl:
          'https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=1200&auto=format&fit=crop&q=80',
      duration: '4 ngày',
      checkInDate: '01/12/2024',
      checkOutDate: '05/12/2024',
      status: TripStatus.upcoming,
    ),
  ];

  final List<TripData> _pastTrips = [
    TripData(
      name: 'Salinda Resort Phu Quoc',
      location: 'Dương Tơ, Phú Quốc, Việt Nam',
      address: 'Cửa Lấp, Dương Tơ, Phú Quốc, Kiên Giang 92506, Việt Nam',
      rating: 4.5,
      price: 2500,
      imageUrl:
          'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      duration: '7 ngày',
      checkInDate: '01/10/2024',
      checkOutDate: '08/10/2024',
      status: TripStatus.completed,
      userRating: 0,
    ),
    TripData(
      name: 'Sheraton Nha Trang Hotel & Spa',
      location: 'Lộc Thọ, Nha Trang, Việt Nam',
      address: '26-28 Trần Phú, Lộc Thọ, Nha Trang, Khánh Hòa 650000, Việt Nam',
      rating: 4.6,
      price: 1700,
      imageUrl:
          'https://images.unsplash.com/photo-1613977257365-aaae5a9817ff?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      duration: '4 ngày',
      checkInDate: '15/09/2024',
      checkOutDate: '19/09/2024',
      status: TripStatus.completed,
      userRating: 5,
    ),
    TripData(
      name: 'Silk Path Grand Resort & Spa Sapa',
      location: 'Sa Pa, Lào Cai, Việt Nam',
      address: 'Doi Quan 6, Group 10, Sa Pa, Lào Cai, Việt Nam',
      rating: 4.8,
      price: 1200,
      imageUrl:
          'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      duration: '3 ngày',
      checkInDate: '20/08/2024',
      checkOutDate: '23/08/2024',
      status: TripStatus.completed,
      userRating: 4,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_selectedTab != _tabController.index) {
        setState(() => _selectedTab = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ===== UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTripsList(_upcomingTrips, isUpcoming: true),
                  _buildTripsList(_pastTrips, isUpcoming: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Chuyến đi',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0E4C45),
                letterSpacing: -0.3,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_outlined,
              size: 22,
              color: Color(0xFF0E4C45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              alignment: _selectedTab == 0
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E4C45),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _tabController.animateTo(0),
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _selectedTab == 0
                              ? Colors.white
                              : const Color(0xFF0E4C45).withOpacity(0.55),
                        ),
                        child: const Text('Sắp tới'),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _tabController.animateTo(1),
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _selectedTab == 1
                              ? Colors.white
                              : const Color(0xFF0E4C45).withOpacity(0.55),
                        ),
                        child: const Text('Đã hoàn thành'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripsList(List<TripData> trips, {required bool isUpcoming}) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _buildTripCard(trip, isUpcoming: isUpcoming),
        );
      },
    );
  }

  Widget _buildTripCard(TripData trip, {required bool isUpcoming}) {
    return GestureDetector(
      onTap: () => _showTripDetails(trip, isUpcoming: isUpcoming),
      child: Container(
        height: 380,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              Image.network(
                trip.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2FB9A6), Color(0xFF0E4C45)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.image, color: Colors.white, size: 60),
                ),
              ),

              // top gradient for status & actions
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.15),
                      Colors.transparent,
                      Colors.black.withOpacity(0.55),
                    ],
                    stops: const [0.0, 0.35, 1.0],
                  ),
                ),
              ),

              // Status badge (for completed)
              if (!isUpcoming)
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2FB9A6),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Đã hoàn thành',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Content bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.25),
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            trip.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  trip.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                trip.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                '\$${trip.price}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                trip.duration,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(.85),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${trip.checkInDate} - ${trip.checkOutDate}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(.9),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          if (!isUpcoming && trip.userRating > 0) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Text(
                                  'Bạn đã đánh giá: ',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12.5,
                                  ),
                                ),
                                ...List.generate(
                                  5,
                                  (i) => Padding(
                                    padding: const EdgeInsets.only(left: 2),
                                    child: Icon(
                                      i < trip.userRating
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Bottom sheet
  void _showTripDetails(TripData trip, {required bool isUpcoming}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.96),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
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
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              trip.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0E4C45),
                              ),
                            ),
                          ),
                          if (!isUpcoming)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2FB9A6).withOpacity(.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF2FB9A6),
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Hoàn thành',
                                    style: TextStyle(
                                      color: Color(0xFF2FB9A6),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Color(0xFF2FB9A6),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            trip.location,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            trip.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _buildDetailRow(
                        Icons.calendar_today,
                        'Check-in',
                        trip.checkInDate,
                      ),
                      const SizedBox(height: 10),
                      _buildDetailRow(
                        Icons.event,
                        'Check-out',
                        trip.checkOutDate,
                      ),
                      const SizedBox(height: 10),
                      _buildDetailRow(
                        Icons.access_time,
                        'Thời gian',
                        trip.duration,
                      ),
                      const SizedBox(height: 10),
                      _buildDetailRow(
                        Icons.attach_money,
                        'Tổng giá',
                        '\$${trip.price}',
                      ),
                      const SizedBox(height: 10),
                      _buildDetailRow(Icons.hotel, 'Chỗ nghỉ', 'Khách sạn 4★'),
                      const SizedBox(height: 10),
                      _buildDetailRow(
                        Icons.restaurant,
                        'Ăn uống',
                        '3 bữa/ngày',
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Mô tả',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0E4C45),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Khám phá vẻ đẹp của ${trip.name} với những trải nghiệm đáng nhớ: tham quan, ẩm thực địa phương và lưu trú tiện nghi.',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14.5,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Actions
                      if (isUpcoming)
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showCancelDialog(trip);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'Hủy chuyến',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showSuccessSnackBar('Đã xác nhận chuyến đi');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2FB9A6),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'Xem chi tiết',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (trip.userRating == 0) ...[
                              const Text(
                                'Đánh giá chuyến đi',
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0E4C45),
                                ),
                              ),
                              const SizedBox(height: 10),
                              _RatingWidget(
                                onRate: (rating) {
                                  setState(() => trip.userRating = rating);
                                  Navigator.pop(context);
                                  _showSuccessSnackBar(
                                    'Cảm ơn bạn đã đánh giá!',
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                            ],
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _showSuccessSnackBar(
                                        'Đã thêm vào yêu thích',
                                      );
                                    },
                                    icon: const Icon(Icons.favorite_border),
                                    label: const Text('Yêu thích'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF2FB9A6),
                                      side: const BorderSide(
                                        color: Color(0xFF2FB9A6),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _showSuccessSnackBar('Đã đặt lại chuyến');
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Đặt lại'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2FB9A6),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2FB9A6).withOpacity(.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2FB9A6).withOpacity(.12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2FB9A6), size: 22),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0E4C45),
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(TripData trip) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Hủy chuyến đi'),
          ],
        ),
        content: Text(
          'Bạn chắc muốn hủy chuyến đến ${trip.name}?\nPhí hủy có thể được áp dụng.',
          style: const TextStyle(fontSize: 14.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Quay lại'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _showSuccessSnackBar('Đã hủy chuyến đi', isError: true);
            },
            child: const Text('Xác nhận hủy'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.cancel : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : const Color(0xFF2FB9A6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

// ===== Models
enum TripStatus { upcoming, completed }

class TripData {
  final String name; // Tên khách sạn/khu nghỉ
  final String location; // Khu vực: quận/thành phố, quốc gia
  final String address; // Địa chỉ đầy đủ
  final double rating;
  final int price;
  final String imageUrl; // Ảnh phòng
  final String duration;
  final String checkInDate;
  final String checkOutDate;
  final TripStatus status;
  int userRating;

  TripData({
    required this.name,
    required this.location,
    required this.address, // ⬅️ mới
    required this.rating,
    required this.price,
    required this.imageUrl,
    required this.duration,
    required this.checkInDate,
    required this.checkOutDate,
    required this.status,
    this.userRating = 0,
  });
}

// ===== Rating widget (sao + ô review + nút gửi)
class _RatingWidget extends StatefulWidget {
  const _RatingWidget({required this.onRate});

  final void Function(int rating) onRate;

  @override
  State<_RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<_RatingWidget> {
  int _rating = 0;
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF2FB9A6).withOpacity(.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2FB9A6).withOpacity(.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reviewController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Chia sẻ trải nghiệm của bạn...',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: const Color(0xFF2FB9A6).withOpacity(.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: const Color(0xFF2FB9A6).withOpacity(.2),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Color(0xFF2FB9A6)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _rating > 0 ? () => widget.onRate(_rating) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2FB9A6),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Gửi đánh giá',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
