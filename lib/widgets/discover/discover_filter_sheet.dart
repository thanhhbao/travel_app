import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const kPrimary = Color(0xFF0E4C45);

/// Model kết quả bộ lọc trả về
class Filters {
  final PropertyType type;
  final RangeValues price;
  final double? rating; // null = Any
  final int rooms;
  final int beds;

  const Filters({
    this.type = PropertyType.hotel,
    this.price = const RangeValues(150, 12150),
    this.rating,
    this.rooms = 1,
    this.beds = 1,
  });

  Filters copyWith({
    PropertyType? type,
    RangeValues? price,
    double? rating = _sentinelDouble,
    int? rooms,
    int? beds,
  }) {
    return Filters(
      type: type ?? this.type,
      price: price ?? this.price,
      rating: rating == _sentinelDouble ? this.rating : rating,
      rooms: rooms ?? this.rooms,
      beds: beds ?? this.beds,
    );
  }

  static const _sentinelDouble = -99999.12345;
}

/// Loại hình chỗ ở
enum PropertyType { hotel, room, boat, cabin, apartment }

extension on PropertyType {
  String get label => switch (this) {
    PropertyType.hotel => 'Khách sạn',
    PropertyType.room => 'Phòng',
    PropertyType.boat => 'Du thuyền',
    PropertyType.cabin => 'Nhà gỗ',
    PropertyType.apartment => 'Căn hộ',
  };
  IconData get icon => switch (this) {
    PropertyType.hotel => Icons.apartment_rounded,
    PropertyType.room => Icons.home_work_outlined,
    PropertyType.boat => Icons.directions_boat_rounded,
    PropertyType.cabin => Icons.cabin_rounded,
    PropertyType.apartment => Icons.apartment_outlined,
  };
}

/// Helper mở sheet và nhận kết quả
Future<Filters?> showFilterSheet(BuildContext context, {Filters? initial}) {
  return showModalBottomSheet<Filters>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FilterSheetBody(initial: initial ?? const Filters()),
  );
}

/// ================= UI =================

class _FilterSheetBody extends StatefulWidget {
  const _FilterSheetBody({required this.initial});
  final Filters initial;

  @override
  State<_FilterSheetBody> createState() => _FilterSheetBodyState();
}

class _FilterSheetBodyState extends State<_FilterSheetBody> {
  late PropertyType _type;
  late RangeValues _price;
  double? _rating; // null = any
  int _rooms = 1;
  int _beds = 1;

  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _type = widget.initial.type;
    _price = widget.initial.price;
    _rating = widget.initial.rating;
    _rooms = widget.initial.rooms;
    _beds = widget.initial.beds;

    _syncPriceText();
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  void _syncPriceText() {
    _minCtrl.text = _fmtMoney(_price.start);
    _maxCtrl.text = _fmtMoney(_price.end);
  }

  String _fmtMoney(double v) {
    final n = v.round();
    // Định dạng đơn giản 12,150
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i;
      buf.write(s[i]);
      if (idx > 1 && idx % 3 == 1) buf.write(',');
    }
    return '\$${buf.toString()}';
  }

  // fake histogram data
  static const _histCount = 60;
  final _hist = List<double>.generate(_histCount, (i) {
    // đỉnh ở giữa, hình “chuông” đơn giản
    final t = (i / (_histCount - 1)) * math.pi;
    return (math.sin(t) * 0.7 + 0.3) * 1.0;
  });

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.6,
      maxChildSize: 0.98,
      builder: (context, controller) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.only(bottom: viewInsets > 0 ? viewInsets : 16),
            color: Colors.white,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      _roundIcon(
                        icon: Icons.close_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Bộ lọc',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: kPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // cân đối với nút close
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    children: [
                      const SizedBox(height: 8),
                      _sectionTitle('Loại chỗ nghỉ'),
                      const SizedBox(height: 8),
                      _propertyTypeRow(),

                      const SizedBox(height: 20),
                      _sectionTitle('Giá'),
                      const SizedBox(height: 4),
                      Text(
                        'Giá trung bình mỗi đêm là ${_fmtMoney(150)}',
                        style: TextStyle(
                          color: const Color(0xFF1D2433).withValues(alpha: .6),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 60,
                        child: CustomPaint(
                          painter: _HistogramPainter(
                            bars: _hist,
                            color: kPrimary.withValues(alpha: .6),
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPriceSlider(), // <= RangeSlider themed
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _priceBox(_minCtrl, 'Tối thiểu')),
                          const SizedBox(width: 12),
                          Expanded(child: _priceBox(_maxCtrl, 'Tối đa')),
                        ],
                      ),

                      const SizedBox(height: 24),
                      _sectionTitle('Đánh giá'),
                      const SizedBox(height: 10),
                      _ratingRow(),

                      const SizedBox(height: 24),
                      _sectionTitle('Phòng & Giường'),
                      const SizedBox(height: 10),
                      _stepperRow(
                        label: 'Phòng',
                        value: _rooms,
                        onChanged: (v) =>
                            setState(() => _rooms = v.clamp(0, 20)),
                      ),
                      const SizedBox(height: 10),
                      _stepperRow(
                        label: 'Giường',
                        value: _beds,
                        onChanged: (v) =>
                            setState(() => _beds = v.clamp(0, 20)),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Footer buttons
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _type = PropertyType.hotel;
                              _price = const RangeValues(150, 12150);
                              _rating = null;
                              _rooms = 1;
                              _beds = 1;
                              _syncPriceText();
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: kPrimary),
                            foregroundColor: kPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            'Xoá tất cả',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final result = Filters(
                              type: _type,
                              price: _price,
                              rating: _rating,
                              rooms: _rooms,
                              beds: _beds,
                            );
                            Navigator.pop(context, result);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: kPrimary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Hiển thị kết quả',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ===== widgets con =====

  Widget _buildPriceSlider() {
    final base = Theme.of(context).sliderTheme;
    return SliderTheme(
      data: base.copyWith(
        trackHeight: 3,
        activeTrackColor: kPrimary,
        inactiveTrackColor: kPrimary.withValues(alpha: .25),
        overlayColor: kPrimary.withValues(alpha: .12),
        thumbColor: kPrimary,
        rangeThumbShape: const RoundRangeSliderThumbShape(
          enabledThumbRadius: 10,
        ),
        rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
        valueIndicatorColor: kPrimary,
        valueIndicatorTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: RangeSlider(
        min: 50,
        max: 12150,
        divisions: 242, // mỗi 50$
        values: _price,
        labels: RangeLabels(_fmtMoney(_price.start), _fmtMoney(_price.end)),
        onChanged: (v) {
          setState(() {
            _price = v;
            _syncPriceText();
          });
        },
      ),
    );
  }

  Widget _priceBox(TextEditingController c, String hint) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d$,]'))],
      decoration: InputDecoration(
        labelText: hint,
        prefixText: '',
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(
          color: const Color(0xFF1D2433).withValues(alpha: .5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: const Color(0xFF1D2433).withValues(alpha: .1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: const Color(0xFF1D2433).withValues(alpha: .1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kPrimary, width: 1.2),
        ),
        suffixIcon: const Icon(Icons.expand_more_rounded, color: kPrimary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      onSubmitted: (_) {
        // Parse về số, cập nhật slider
        double _parse(String s) =>
            double.tryParse(s.replaceAll(RegExp(r'[^0-9]'), ''))?.toDouble() ??
            0;
        var min = _parse(_minCtrl.text);
        var max = _parse(_maxCtrl.text);
        if (min < 50) min = 50;
        if (max > 12150) max = 12150;
        if (min > max) {
          final tmp = min;
          min = max;
          max = tmp;
        }
        setState(() {
          _price = RangeValues(min, max);
          _syncPriceText();
        });
      },
    );
  }

  Widget _propertyTypeRow() {
    final list = PropertyType.values;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final t in list) ...[
            _choiceChip(
              selected: _type == t,
              icon: t.icon,
              label: t.label,
              onTap: () => setState(() => _type = t),
            ),
            const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }

  Widget _ratingRow() {
    final chips = <Widget>[
      _pill(
        selected: _rating == null,
        label: 'Bất kỳ',
        icon: Icons.star_half_rounded,
        onTap: () => setState(() => _rating = null),
      ),
      for (final r in [5.0, 4.5, 4.0, 3.5])
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: _pill(
            selected: _rating == r,
            label: r.toStringAsFixed(1),
            icon: Icons.star_rounded,
            onTap: () => setState(() => _rating = r),
          ),
        ),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: chips),
    );
  }

  Widget _stepperRow({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF1D2433).withValues(alpha: .08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: kPrimary,
            ),
          ),
          const Spacer(),
          _roundIcon(
            icon: Icons.remove_rounded,
            onTap: () => onChanged(value - 1),
          ),
          const SizedBox(width: 10),
          Text(
            '$value',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 10),
          _roundIcon(
            icon: Icons.add_rounded,
            onTap: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }

  /// ===== tiny helpers =====

  Widget _sectionTitle(String t) => Text(
    t,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: kPrimary,
    ),
  );

  Widget _roundIcon({required IconData icon, VoidCallback? onTap}) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Ink(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
          ),
        ],
      ),
      child: Icon(icon, color: kPrimary),
    ),
  );

  Widget _choiceChip({
    required bool selected,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? kPrimary : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFF1D2433).withValues(alpha: .1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: selected ? Colors.white : kPrimary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : kPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill({
    required bool selected,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? kPrimary : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFF1D2433).withValues(alpha: .1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : kPrimary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : kPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter cho histogram giá
class _HistogramPainter extends CustomPainter {
  final List<double> bars; // 0..1
  final Color color;
  _HistogramPainter({required this.bars, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final barW = size.width / bars.length;
    const barThickness = 4.0;
    final paint = Paint()..color = color;
    const radius = Radius.circular(2.5);

    for (int i = 0; i < bars.length; i++) {
      final h = bars[i] * size.height;
      final x = i * barW + (barW - barThickness) / 2;
      final rect = Rect.fromLTWH(x, size.height - h, barThickness, h);
      final rrect = RRect.fromRectAndRadius(rect, radius);
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HistogramPainter oldDelegate) =>
      oldDelegate.bars != bars || oldDelegate.color != color;
}
