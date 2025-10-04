// lib/screens/profile_screen.dart
import 'package:app_test/routes.dart';
import 'package:app_test/widgets/appnavbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const primary = Color(0xFF0E4C45);
  static const accent = Color(0xFF2FB9A6);
  final _auth = FirebaseAuth.instance;

  User? _user;
  bool _busy = false;
  bool _notif = true; // demo toggle

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  bool get _linkedGoogle =>
      _user?.providerData.any((p) => p.providerId == 'google.com') ?? false;

  bool get _linkedPassword =>
      _user?.providerData.any((p) => p.providerId == 'password') ?? false;

  Future<void> _reload() async {
    await _user?.reload();
    setState(() => _user = _auth.currentUser);
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _editProfile() async {
    final nameC = TextEditingController(text: _user?.displayName ?? '');
    final photoC = TextEditingController(text: _user?.photoURL ?? '');

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.72,
          child: Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Chỉnh sửa hồ sơ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 14),
                _LabeledField(label: 'Tên hiển thị', controller: nameC),
                const SizedBox(height: 12),
                _LabeledField(
                  label: 'Ảnh đại diện (URL)',
                  controller: photoC,
                  hint: 'https://...',
                ),
                const Spacer(),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text(
                      'Lưu thay đổi',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == true) {
      setState(() => _busy = true);
      try {
        if (nameC.text.trim().isNotEmpty) {
          await _user?.updateDisplayName(nameC.text.trim());
        }
        await _user?.updatePhotoURL(
          photoC.text.trim().isEmpty ? null : photoC.text.trim(),
        );
        await _reload();
        _toast('Đã cập nhật hồ sơ.');
      } catch (e) {
        _toast('Cập nhật thất bại: $e');
      } finally {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _sendVerifyEmail() async {
    if (_user?.email == null) {
      _toast('Tài khoản chưa có email.');
      return;
    }
    setState(() => _busy = true);
    try {
      await _user?.sendEmailVerification();
      _toast('Đã gửi email xác minh tới ${_user!.email}');
    } catch (e) {
      _toast('Gửi email xác minh thất bại: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _sendResetPassword() async {
    final email = _user?.email;
    if (email == null) {
      _toast('Tài khoản chưa có email để đổi mật khẩu.');
      return;
    }
    setState(() => _busy = true);
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _toast('Đã gửi email đặt lại mật khẩu đến $email');
    } catch (e) {
      _toast('Gửi email đặt lại mật khẩu thất bại: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  /// Liên kết Google vào tài khoản hiện tại (Firebase Auth 6+).
  Future<void> _linkGoogle() async {
    setState(() => _busy = true);
    try {
      final provider = GoogleAuthProvider()..addScope('email');
      await _user?.linkWithProvider(provider);
      await _reload();
      _toast('Đã liên kết Google.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked') {
        _toast('Google đã được liên kết.');
      } else if (e.code == 'credential-already-in-use') {
        _toast('Email Google này đã thuộc về tài khoản khác.');
      } else if (e.code == 'requires-recent-login') {
        _toast('Vui lòng đăng nhập lại rồi thử lại.');
      } else {
        _toast('Liên kết thất bại: ${e.code}');
      }
    } catch (e) {
      _toast('Liên kết thất bại: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _unlinkGoogle() async {
    setState(() => _busy = true);
    try {
      // Không được hủy liên kết nếu đây là provider duy nhất
      final providers = _user?.providerData ?? [];
      if (providers.length <= 1) {
        _toast('Không thể hủy liên kết provider cuối cùng.');
      } else {
        await _user?.unlink('google.com');
        await _reload();
        _toast('Đã hủy liên kết Google.');
      }
    } on FirebaseAuthException catch (e) {
      _toast('Hủy liên kết thất bại: ${e.code}');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _deleteAccount() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa tài khoản?'),
        content: const Text(
          'Hành động này không thể hoàn tác. Tất cả dữ liệu cá nhân sẽ bị xóa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _busy = true);
    try {
      await _user?.delete();
      await _auth.signOut();
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(Routes.splash, (_) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _toast('Vui lòng đăng nhập lại rồi xóa tài khoản.');
      } else {
        _toast('Xóa tài khoản thất bại: ${e.code}');
      }
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _busy = true);
    try {
      await _auth.signOut();
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(Routes.splash, (_) => false);
    } catch (e) {
      _toast('Đăng xuất thất bại: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _user?.displayName?.trim();
    final email = _user?.email;
    final photo = _user?.photoURL;

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== Header =====
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: const [
                        Text(
                          'TRAVELHUB',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: primary,
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Card thông tin user
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [primary, accent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.10),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 34,
                                backgroundColor: Colors.white,
                                backgroundImage: photo != null
                                    ? NetworkImage(photo)
                                    : null,
                                child: photo == null
                                    ? const Icon(
                                        Icons.person,
                                        color: primary,
                                        size: 34,
                                      )
                                    : null,
                              ),
                              Positioned(
                                right: -2,
                                bottom: -2,
                                child: Material(
                                  color: Colors.white,
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: _busy ? null : _editProfile,
                                    child: const Padding(
                                      padding: EdgeInsets.all(6),
                                      child: Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (name?.isNotEmpty == true ? name : 'Khách') ??
                                      'Khách',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.mail_outline,
                                      size: 14,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        email ?? '—',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white70,
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
                  ),

                  const SizedBox(height: 24),

                  // ===== Sections =====
                  const _SectionTitle('Thông tin cá nhân'),
                  _CardBlock(
                    children: [
                      _Tile(
                        icon: Icons.verified_user_outlined,
                        title: _user?.emailVerified == true
                            ? 'Email đã xác minh'
                            : 'Email chưa xác minh',
                        subtitle: email ?? '',
                        trailing: _user?.emailVerified == true
                            ? const Icon(Icons.check_circle, color: accent)
                            : TextButton(
                                onPressed: _busy ? null : _sendVerifyEmail,
                                child: const Text('Gửi xác minh'),
                              ),
                      ),
                      if (_linkedPassword)
                        _Tile(
                          icon: Icons.lock_reset_rounded,
                          title: 'Đổi mật khẩu',
                          subtitle: 'Gửi email đặt lại mật khẩu',
                          onTap: _busy ? null : _sendResetPassword,
                        ),
                    ],
                  ),

                  const _SectionTitle('Đăng nhập & bảo mật'),
                  _CardBlock(
                    children: [
                      _Tile(
                        icon: Icons.link_rounded,
                        title: _linkedGoogle
                            ? 'Google đã liên kết'
                            : 'Liên kết với Google',
                        subtitle: _linkedGoogle
                            ? 'Nhấn để hủy liên kết'
                            : 'Thêm Google để đăng nhập nhanh',
                        trailing: _linkedGoogle
                            ? const Icon(Icons.check_circle, color: accent)
                            : null,
                        onTap: _busy
                            ? null
                            : () => _linkedGoogle
                                  ? _unlinkGoogle()
                                  : _linkGoogle(),
                      ),
                    ],
                  ),

                  const _SectionTitle('Ứng dụng'),
                  _CardBlock(
                    children: [
                      SwitchListTile.adaptive(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        secondary: const Icon(
                          Icons.notifications_none,
                          color: primary,
                        ),
                        title: const Text('Nhận thông báo'),
                        value: _notif,
                        onChanged: (v) => setState(() => _notif = v),
                      ),
                      const Divider(height: 1),
                      const _Tile(
                        icon: Icons.translate_rounded,
                        title: 'Ngôn ngữ',
                        subtitle: 'Tiếng Việt',
                      ),
                      const Divider(height: 1),
                      const _Tile(
                        icon: Icons.policy_outlined,
                        title: 'Điều khoản & Chính sách',
                      ),
                      const Divider(height: 1),
                      _Tile(
                        icon: Icons.delete_outline_rounded,
                        title: 'Xóa tài khoản',
                        titleColor: Colors.red.shade600,
                        onTap: _busy ? null : _deleteAccount,
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _busy ? null : _signOut,
                        child: const Text(
                          'Đăng xuất',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: AppNavBar.overlaySpace(context)),
                ],
              ),
            ),

            if (_busy)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.black.withOpacity(0.05),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(primary),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ===== Small UI helpers =====

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Text(
        text,
        style: const TextStyle(
          color: _ProfileScreenState.primary,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CardBlock extends StatelessWidget {
  final List<Widget> children;
  const _CardBlock({required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.06),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(children: children),
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? titleColor;

  const _Tile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF5F4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: _ProfileScreenState.primary),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? const Color(0xFF0F172A),
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing:
          trailing ??
          const Icon(Icons.chevron_right_rounded, color: Colors.black26),
      onTap: onTap,
      dense: false,
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;

  const _LabeledField({
    required this.label,
    required this.controller,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: _ProfileScreenState.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _ProfileScreenState.primary),
            ),
          ),
        ),
      ],
    );
  }
}
