// lib/widgets/appnavbar.dart
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class AppNavBar extends StatefulWidget {
  const AppNavBar({super.key, required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const double barHeight = 72.0;
  static const EdgeInsets outerPadding = EdgeInsets.fromLTRB(16, 10, 16, 24);

  static double overlaySpace(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return barHeight + outerPadding.vertical + bottomInset;
  }

  @override
  State<AppNavBar> createState() => _AppNavBarState();
}

class _AppNavBarState extends State<AppNavBar>
    with SingleTickerProviderStateMixin {
  static const _gradient = LinearGradient(
    colors: [Color(0xFF2FB9A6), Color(0xFF0E4C45)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  final List<_NavItem> _items = const [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Trang chủ',
    ),
    _NavItem(
      icon: Icons.gps_fixed_outlined,
      activeIcon: Icons.gps_fixed_rounded,
      label: 'Khám phá',
    ),
    _NavItem(
      icon: Icons.bookmark_border,
      activeIcon: Icons.bookmark,
      label: 'Đã lưu',
    ),
    _NavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Tài khoản',
    ),
  ];

  static const TextStyle _labelStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w600,
    fontSize: 13.5,
    height: 1,
    letterSpacing: .2,
  );

  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..value = 1;
    _fade = CurvedAnimation(
      parent: _c,
      curve: const Interval(.15, .85, curve: Curves.easeOut),
    );
    _scale = CurvedAnimation(parent: _c, curve: Curves.elasticOut);
  }

  @override
  void didUpdateWidget(covariant AppNavBar old) {
    super.didUpdateWidget(old);
    if (widget.currentIndex != old.currentIndex) {
      _c
        ..stop()
        ..forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _textWidth(String text, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return tp.width;
  }

  @override
  Widget build(BuildContext context) {
    // Kích thước & khoảng cách cơ bản
    const iconFrame = 50.0; // “khung” tròn của mỗi ô
    const iconSize = 21.0; // cỡ icon vẽ thực
    const innerPad = 12.0; // padding ngang khi active
    const gap = 6.0; // khoảng cách icon–text bên trong
    const spacing = 8.0; // khoảng cách giữa các ô
    const hPad = 18.0; // padding ngang của container

    return SafeArea(
      top: false,
      child: Padding(
        padding: AppNavBar.outerPadding,
        child: LayoutBuilder(
          builder: (context, cons) {
            final available = cons.maxWidth - (hPad * 2);
            final inactiveCount = _items.length - 1;

            // 1) Tính width mong muốn cho ô active dựa trên nhãn hiện tại
            final label = _items[widget.currentIndex].label;
            final labelW = _textWidth(label, _labelStyle);
            final desiredActiveW = innerPad * 2 + iconSize + gap + labelW;

            // 2) Giới hạn để không overflow (chừa mỗi inactive >= iconFrame)
            final minForInactives =
                iconFrame * inactiveCount + spacing * (_items.length - 1);
            final maxActiveW = math.max(iconFrame, available - minForInactives);
            final activeW = desiredActiveW.clamp(iconFrame, maxActiveW);

            // 3) Chia đều phần còn lại cho inactives
            final remain = available - activeW - spacing * (_items.length - 1);
            final inactiveW = math.max(iconFrame, remain / inactiveCount);

            // 4) Đổi sang flex để lấp kín hàng 100% (tránh sai số 1–3 px dẫn đến overflow)
            //    Ta scale các width này thành flex int.
            const totalFlex = 1000; // số lớn để chia tỉ lệ mịn
            final aFlex = (activeW / available * totalFlex).round();
            final iFlex = ((inactiveW / available) * totalFlex).round();

            return AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      height: AppNavBar.barHeight,
                      padding: const EdgeInsets.symmetric(
                        horizontal: hPad,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: Colors.white.withOpacity(.28),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: List.generate(_items.length, (i) {
                          final isActive = i == widget.currentIndex;
                          return Expanded(
                            flex: isActive ? aFlex : iFlex,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: i == 0 ? 0 : spacing,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(28),
                                  onTap: () => widget.onTap(i),
                                  child: Center(
                                    // SizedBox.expand để đảm bảo child nhận đủ chiều cao
                                    child: SizedBox(
                                      height: iconFrame,
                                      child: _NavButton(
                                        item: _items[i],
                                        isActive: isActive,
                                        gradient: _gradient,
                                        labelStyle: _labelStyle,
                                        fade: _c.isAnimating
                                            ? _fade.value
                                            : 1.0,
                                        scale: _c.isAnimating
                                            ? _scale.value
                                            : 1.0,
                                        innerPad: innerPad,
                                        iconSize: iconSize,
                                        gap: gap,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.isActive,
    required this.gradient,
    required this.labelStyle,
    required this.fade,
    required this.scale,
    required this.innerPad,
    required this.iconSize,
    required this.gap,
  });

  final _NavItem item;
  final bool isActive;
  final Gradient gradient;
  final TextStyle labelStyle;
  final double fade;
  final double scale;
  final double innerPad;
  final double iconSize;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: isActive ? gradient : null,
        color: isActive ? null : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isActive ? Colors.transparent : Colors.black.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? const Color(0xFF0E4C45).withOpacity(.28)
                : Colors.black.withOpacity(.06),
            blurRadius: isActive ? 16 : 8,
            offset: Offset(0, isActive ? 6 : 3),
            spreadRadius: isActive ? 0 : -1,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: isActive ? innerPad : 0),
      child: isActive
          ? Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: scale,
                  child: Icon(
                    item.activeIcon,
                    color: Colors.white,
                    size: iconSize,
                  ),
                ),
                SizedBox(width: gap),
                Flexible(
                  child: Opacity(
                    opacity: fade,
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: labelStyle,
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: Icon(
                item.icon,
                color: const Color(0xFF0E4C45).withOpacity(.7),
                size: iconSize,
              ),
            ),
    );
  }
}
