import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:widget_flutter/core/constants/app_colors.dart';
import 'package:widget_flutter/providers/auth_provider.dart';
import 'package:widget_flutter/routes/app_route.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF8),
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFDDBF), Color(0xFFFFF4E9)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ClipOval(
                            child: user.avatar != null && user.avatar!.isNotEmpty
                                ? Image.network(
                                    user.avatar!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _initials(user.name),
                                  )
                                : _initials(user.name),
                          ),
                        ),
                        const SizedBox(height: 14),

                        Text(
                          _formatName(user.name),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Stats
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ProfileStat(
                          value: "${authProvider.stats['orders'] ?? 0}",
                          title: "Orders",
                        ),
                        _ProfileStat(
                          value: "${authProvider.stats['saved'] ?? 0}",
                          title: "Saved",
                        ),
                        _ProfileStat(
                          value: "${authProvider.stats['coupons'] ?? 0}",
                          title: "Coupons",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        _tile(
                          icon: Icons.shopping_bag_outlined,
                          title: "My Orders",
                          onTap: () => context.push(AppRoute.orders),
                        ),
                        _tile(
                          icon: Icons.location_on_outlined,
                          title: "Delivery Address",
                          onTap: () => context.push(AppRoute.addresses),
                        ),
                        _tile(
                          icon: Icons.favorite_border,
                          title: "Favorites",
                          onTap: () => context.push(AppRoute.favorites),
                        ),
                        _tile(
                          icon: Icons.payment,
                          title: "Payment Methods",
                          onTap: () => context.push(AppRoute.payments),
                        ),
                        _tile(
                          icon: Icons.notifications_none,
                          title: "Notifications",
                          onTap: () => context.push(AppRoute.notifications),
                        ),
                        _tile(
                          icon: Icons.help_outline,
                          title: "Help Center",
                          onTap: () => context.push(AppRoute.help),
                        ),
                        _tile(
                          icon: Icons.info_outline,
                          title: "About App",
                          onTap: () => context.push(AppRoute.about),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await context.read<AuthProvider>().logout();
                          if (context.mounted) {
                            context.go(AppRoute.login);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          "Logout",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  static Widget _initials(String? name) {
    final formatted = _formatName(name);
    final initials = formatted
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join();
    return Center(
      child: Text(
        initials.isEmpty ? 'U' : initials,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 26,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  static String _formatName(String? name) {
    final value = name?.trim() ?? '';
    if (value.isEmpty) return 'User';
    return value
        .split(RegExp(r'\s+'))
        .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
        .join(' ');
  }

  static Widget _tile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String title;

  const _ProfileStat({
    required this.value,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
