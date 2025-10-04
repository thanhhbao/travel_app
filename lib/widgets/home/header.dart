import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, this.onAvatarTap});
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFF0E4C45);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          const Text(
            'TRAVELHUB',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: brand,
            ),
          ),
          const Spacer(),
          const ChipIcon(Icons.wallet_outlined),
          const SizedBox(width: 10),
          const ChipIcon(Icons.chat_bubble_outline),
          const SizedBox(width: 10),
          const ChipIcon(Icons.notifications_none),
          const SizedBox(width: 10),

          // ⬇️ Avatar tự đồng bộ theo FirebaseAuth
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.userChanges(),
            builder: (context, snap) {
              final user = snap.data;
              final photoURL = user?.photoURL;
              final displayName = user?.displayName;

              return GestureDetector(
                onTap: onAvatarTap,
                child: _AvatarBubble(
                  photoURL: photoURL,
                  displayName: displayName,
                  radius: 20,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ChipIcon extends StatelessWidget {
  final IconData icon;
  const ChipIcon(this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 234, 242, 242),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: const Color(0xFF0E4C45)),
    );
  }
}

class _AvatarBubble extends StatelessWidget {
  const _AvatarBubble({
    required this.photoURL,
    required this.displayName,
    this.radius = 20,
  });

  final String? photoURL;
  final String? displayName;
  final double radius;

  @override
  Widget build(BuildContext context) {
    // Nếu có ảnh -> hiện ảnh; nếu lỗi/chưa có -> hiện chữ cái đầu
    if (photoURL != null && photoURL!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.transparent,
        // foregroundImage cho load mượt; errorBuilder fallback về initials
        child: ClipOval(
          child: Image.network(
            photoURL!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) =>
                _Initials(radius: radius, name: displayName),
          ),
        ),
      );
    }
    return _Initials(radius: radius, name: displayName);
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.radius, required this.name});
  final double radius;
  final String? name;

  @override
  Widget build(BuildContext context) {
    final initial = (name?.trim().isNotEmpty ?? false)
        ? name!.trim().characters.first.toUpperCase()
        : 'U';

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFE6F0EF),
      child: Text(
        initial,
        style: const TextStyle(
          color: Color(0xFF0E4C45),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
