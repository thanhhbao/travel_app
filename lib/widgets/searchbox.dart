import 'package:app_test/models/search_value.dart';
import 'package:app_test/screens/home_screen.dart';
import 'package:flutter/material.dart';

class InlineSearchBox extends StatefulWidget {
  final SearchValues? initial;
  final ValueChanged<SearchValues>? onChanged;
  final ValueChanged<SearchValues>? onSearch;

  const InlineSearchBox({
    super.key,
    this.initial,
    this.onChanged,
    this.onSearch,
  });

  @override
  State<InlineSearchBox> createState() => _InlineSearchBoxState();
}

class _InlineSearchBoxState extends State<InlineSearchBox> {
  static const primary = Color(0xFF0E4C45);
  late SearchValues v;

  @override
  void initState() {
    super.initState();
    v = widget.initial ?? SearchValues();
  }

  void _emit() => widget.onChanged?.call(v);

  // ===== Destination picker with quick list =====
  Future<void> _pickDestination() async {
    final List<String> all = [
      'Hà Nội',
      'Đà Nẵng',
      'Nha Trang',
      'Hội An',
      'Đà Lạt',
      'Phú Quốc',
      'Vũng Tàu',
      'Hạ Long',
      'Sapa',
      'Phan Thiết',
    ];

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final c = TextEditingController(text: v.destination ?? '');
        String q = c.text;

        List<String> filtered(String s) => all
            .where((e) => e.toLowerCase().contains(s.toLowerCase()))
            .toList();

        return FractionallySizedBox(
          heightFactor: 0.60,
          child: StatefulBuilder(
            builder: (ctx, setM) {
              final items = filtered(q);
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bạn muốn đến đâu?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: c,
                      autofocus: true,
                      onChanged: (s) => setM(() => q = s),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, color: primary),
                        hintText: 'Nhập thành phố/điểm đến...',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: primary.withOpacity(.25),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: items.isEmpty
                          ? Center(
                              child: Text(
                                'Không tìm thấy',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            )
                          : ListView.separated(
                              itemCount: items.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (_, i) => ListTile(
                                leading: const Icon(
                                  Icons.place_outlined,
                                  color: primary,
                                ),
                                title: Text(items[i]),
                                onTap: () => Navigator.pop(ctx, items[i]),
                              ),
                            ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx, c.text.trim()),
                        child: const Text(
                          'Xong',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() => v.destination = result);
      _emit();
    }
  }

  // ===== Date range picker (1 màn, 3/4 chiều cao) =====
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final res = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
      initialDateRange: v.range,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: 'Chọn ngày',
      cancelText: 'Hủy',
      saveText: 'Xong',
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1D2433),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primary),
            ),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.75,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: child!,
              ),
            ),
          ),
        );
      },
    );
    if (res != null) {
      setState(() => v.range = res);
      _emit();
    }
  }

  // ===== Guests sheet =====
  Future<void> _pickGuests() async {
    final res = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        int adults = v.adults, children = v.children, rooms = v.rooms;
        bool pets = v.pets;

        Widget squareBtn(IconData icon, VoidCallback onTap) => InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 42,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD3DB)),
              color: Colors.white,
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF1D63E1)),
          ),
        );

        Widget counter(
          String label,
          int value, {
          required VoidCallback minus,
          required VoidCallback plus,
          required StateSetter setM,
        }) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(label, style: const TextStyle(fontSize: 16)),
                ),
                Row(
                  children: [
                    squareBtn(Icons.remove, () => setM(() => minus())),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          '$value',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    squareBtn(Icons.add, () => setM(() => plus())),
                  ],
                ),
              ],
            ),
          );
        }

        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: primary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primary),
            ),
          ),
          child: FractionallySizedBox(
            heightFactor: 0.60,
            child: StatefulBuilder(
              builder: (ctx, setM) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9ECF1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Khách & Phòng',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const Divider(),
                    counter(
                      'Người lớn',
                      adults,
                      minus: () {
                        if (adults > 1) adults--;
                      },
                      plus: () {
                        adults++;
                      },
                      setM: setM,
                    ),
                    counter(
                      'Trẻ em',
                      children,
                      minus: () {
                        if (children > 0) children--;
                      },
                      plus: () {
                        children++;
                      },
                      setM: setM,
                    ),
                    counter(
                      'Phòng',
                      rooms,
                      minus: () {
                        if (rooms > 1) rooms--;
                      },
                      plus: () {
                        rooms++;
                      },
                      setM: setM,
                    ),

                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Mang thú cưng đi cùng'),
                      value: pets,
                      onChanged: (val) => setM(() => pets = val),
                    ),
                    const Spacer(),
                    SafeArea(
                      top: false,
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () => Navigator.pop(ctx, {
                            'adults': adults,
                            'children': children,
                            'rooms': rooms,
                            'pets': pets,
                          }),
                          child: const Text(
                            'Xong',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (res != null) {
      setState(() {
        v.adults = res['adults'];
        v.children = res['children'];
        v.rooms = res['rooms'];
        v.pets = res['pets'];
      });
      _emit();
    }
  }

  String _dateText() {
    if (v.range == null) return 'Ngày nhận phòng  —  Ngày trả phòng';
    final s = v.range!.start, e = v.range!.end;
    return '${s.day}/${s.month} — ${e.day}/${e.month}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE9ECF1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FieldTile(
              icon: Icons.bed_outlined,
              text: v.destination?.isNotEmpty == true
                  ? v.destination!
                  : 'Bạn muốn đến đâu?',
              isPlaceholder: !(v.destination?.isNotEmpty == true),
              onTap: _pickDestination,
            ),
            const SizedBox(height: 8),
            _FieldTile(
              icon: Icons.calendar_today_outlined,
              text: _dateText(),
              isPlaceholder: v.range == null,
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            _FieldTile(
              icon: Icons.person_outline,
              text:
                  '${v.adults} người lớn · ${v.children} trẻ em · ${v.rooms} phòng',
              isPlaceholder: false,
              trailing: const Icon(Icons.keyboard_arrow_down),
              onTap: _pickGuests,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () => widget.onSearch?.call(v),
                child: const Text(
                  'Tìm',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isPlaceholder;
  final VoidCallback onTap;
  final Widget? trailing;

  const _FieldTile({
    required this.icon,
    required this.text,
    required this.isPlaceholder,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0E4C45);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE6E6E6)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(icon, color: primary.withOpacity(.9)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isPlaceholder
                        ? const Color(0xFF7A7F87)
                        : const Color(0xFF1D2433),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              trailing ?? const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
