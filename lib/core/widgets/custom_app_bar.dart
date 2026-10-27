import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:widget_flutter/core/constants/app_colors.dart';
import 'package:widget_flutter/providers/auth_provider.dart';
import 'package:widget_flutter/providers/cart_provider.dart';
import 'package:widget_flutter/routes/app_route.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final bool showNotification;
  final List<Widget>? actions;
  final Widget? titleWidget;
  final double height;
  final String? profileImageUrl;
  final bool hasUnreadNotifications;
  final bool isCustomer;
  final String deliveryLabel;

  const CustomAppBar({
    super.key,
    this.title,
    this.showBackButton = false,
    this.showNotification = true,
    this.actions,
    this.titleWidget,
    this.height = 80,
    this.profileImageUrl,
    this.hasUnreadNotifications = false,
    this.isCustomer = false,
    this.deliveryLabel = 'Deliver to Home',
  });

  @override
  Size get preferredSize => Size(double.infinity, isCustomer ? 80 : height);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.user?.name ?? 'User';
    final greeting = _getGreeting();

    if (isCustomer) {
      return _buildCustomerAppBar(context, userName, greeting);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              if (showBackButton)
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade100,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      size: 18,
                      color: Colors.grey.shade700,
                    ),
                  ),
                )
              else
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        profileImageUrl != null && profileImageUrl!.isNotEmpty
                        ? Image.network(
                            profileImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.person_outline,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          )
                        : Icon(
                            Icons.person_outline,
                            size: 18,
                            color: AppColors.primary,
                          ),
                  ),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titleWidget != null ? '' : '$greeting, $userName',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (title != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        title!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.neutral,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (showNotification)
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No new notifications'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.notifications_none,
                          size: 18,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      if (hasUnreadNotifications)
                        Positioned(
                          top: 1,
                          right: 1,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerAppBar(
    BuildContext context,
    String userName,
    String greeting,
  ) {
    final cartCount = context.watch<CartProvider>().cartItem.length;
    final displayName = _formatName(userName);
    final notificationCount = hasUnreadNotifications ? 1 : 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildProfileAvatar(displayName),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade900,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildIconAction(
                    icon: Icons.notifications_none_rounded,
                    onTap: () => context.push(AppRoute.notifications),
                    count: notificationCount,
                  ),
                  const SizedBox(width: 8),
                  _buildIconAction(
                    icon: Icons.shopping_bag_outlined,
                    onTap: () => context.push(AppRoute.cart),
                    count: cartCount,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(String displayName) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE2C7), Color(0xFFFFF3E7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipOval(
        child: profileImageUrl != null && profileImageUrl!.isNotEmpty
            ? Image.network(
                profileImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _buildInitials(displayName),
              )
            : _buildInitials(displayName),
      ),
    );
  }

  Widget _buildInitials(String name) {
    final initials = name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join()
        .toUpperCase();

    return Center(
      child: Text(
        initials.isEmpty ? 'U' : initials,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildIconAction({
    required IconData icon,
    required VoidCallback onTap,
    bool showBadge = false,
    int count = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4EC),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          if (showBadge || count > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFFD94841),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    count > 0 ? '$count' : '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _formatName(String name) {
    return name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) => part[0].toUpperCase() + part.substring(1).toLowerCase(),
        )
        .join(' ');
  }

}
