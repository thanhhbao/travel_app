import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: const [
          Text(
            'TRAVELHUB',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0E4C45),
            ),
          ),
          Spacer(),
          ChipIcon(Icons.wallet_outlined),
          SizedBox(width: 10),
          ChipIcon(Icons.chat_bubble_outline),
          SizedBox(width: 10),
          ChipIcon(Icons.notifications_none),
          SizedBox(width: 10),
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47'),
            backgroundColor: Colors.transparent,
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
