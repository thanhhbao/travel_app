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
    final bottom = MediaQuery.of(context).padding.bottom;
    return barHeight + outerPadding.vertical + bottom;
  }

  @override
  State<AppNavBar> createState() => _AppNavBarState();
}

class _AppNavBarState extends State<AppNavBar>
    with SingleTickerProviderStateMixin {
  // timing
  static const _wAnimDur = Duration(milliseconds: 420);
  static const _boxAnimDur = Duration(milliseconds: 360);
  static const _switchDur = Duration(milliseconds: 220);
  static const _wCurve = Curves.easeOutExpo; // mượt, đuôi chậm
  static const _boxCurve = Curves.easeOutCubic;

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
      icon: Icons.bookmark_add_outlined,
      activeIcon: Icons.bookmark_added,
      label: 'Đã lưu',
    ),
    _NavItem(
      icon: Icons.map_outlined,
      activeIcon: Icons.map_sharp,
      label: 'Chuyến đi',
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
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..value = 1;
    _scale = CurvedAnimation(
      parent: _c,
      curve: Curves.elasticOut,
    ); // bounce nhẹ icon active
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
    // kích thước cố định
    const double iconFrame = 50.0;
    const double iconSize = 21.0;
    const double innerPad = 12.0;
    const double gap = 6.0;
    const double hPad = 18.0;
    const double minGap = 8.0; // min spacing giữa các item

    return SafeArea(
      top: false,
      child: Padding(
        padding: AppNavBar.outerPadding,
        child: LayoutBuilder(
          builder: (context, cons) {
            final double available = cons.maxWidth - (hPad * 2);

            // width mong muốn cho active
            final label = _items[widget.currentIndex].label;
            final labelW = _textWidth(label, _labelStyle);
            const double safety = 12.0;
            final double wantA =
                innerPad * 2 + iconSize + gap + labelW + safety;

            // để lại chỗ cho các icon còn lại + khoảng cách tối thiểu
            final double maxA = math.max(
              iconFrame,
              available -
                  (iconFrame * (_items.length - 1)) -
                  (minGap * (_items.length - 1)),
            );
            final double activeW = wantA.clamp(iconFrame, maxA);

            return AnimatedBuilder(
              animation: _c,
              builder: (_, __) {
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
                        color: Colors.white.withOpacity(.9),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(_items.length, (i) {
                          final bool isActive = i == widget.currentIndex;
                          final double w = isActive ? activeW : iconFrame;

                          // 👉 animate WIDTH mềm mại
                          return AnimatedContainer(
                            duration: _wAnimDur,
                            curve: _wCurve,
                            width: w,
                            height: iconFrame,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(28),
                                onTap: () => widget.onTap(i),
                                child: _NavButton(
                                  item: _items[i],
                                  isActive: isActive,
                                  gradient: _gradient,
                                  labelStyle: _labelStyle,

                                  scale: _c.isAnimating ? _scale.value : 1.0,
                                  innerPad: innerPad,
                                  iconSize: iconSize,
                                  gap: gap,
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
    super.key,
    required this.item,
    required this.isActive,
    required this.gradient,
    required this.labelStyle,
    required this.scale,
    required this.innerPad,
    required this.iconSize,
    required this.gap,
  });

  final _NavItem item;
  final bool isActive;
  final Gradient gradient;
  final TextStyle labelStyle;
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

                // label trượt nhẹ, KHÔNG fade
                Flexible(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, anim) => SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(.06, 0),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                    child: Text(
                      item.label,
                      key: ValueKey(item.label),
                      maxLines: 1,
                      softWrap: false,
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
