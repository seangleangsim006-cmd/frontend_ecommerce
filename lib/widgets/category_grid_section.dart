import 'package:flutter/material.dart';
import 'package:widget_flutter/core/constants/app_colors.dart';
import 'package:widget_flutter/models/category.dart';
import 'package:widget_flutter/widgets/cached_image.dart';

class CategoryGridSection extends StatelessWidget {
  final List<Category> categories;
  final VoidCallback? onSeeAll;
  final ValueChanged<Category>? onCategoryTap;
  final int crossAxisCount;

  const CategoryGridSection({
    super.key,
    required this.categories,
    this.onSeeAll,
    this.onCategoryTap,
    this.crossAxisCount = 4,
  });

  static const double _borderRadius = 20;
  static const double _padding = 16;
  static const double _iconSize = 30;
  static const double _circleSize = 56;
  static const double _gridMainAxisSpacing = 16;
  static const double _gridCrossAxisSpacing = 12;
  static const double _labelHeight = 28;
  static const double _iconToLabelGap = 8;

  double _calculateAspectRatio(BuildContext context) {
    final availableWidth = MediaQuery.of(context).size.width -
        (_padding * 2) -
        (_gridCrossAxisSpacing * (crossAxisCount - 1));
    final itemWidth = availableWidth / crossAxisCount;
    final itemHeight = _circleSize + _iconToLabelGap + _labelHeight;
    return itemWidth / itemHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(_padding),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                GestureDetector(
                  onTap: onSeeAll,
                  child: Text(
                    "See All",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: _calculateAspectRatio(context),
              ),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final style = _CategoryStyle.fromName(cat.name);
                final hasImage = cat.image.isNotEmpty;
                return GestureDetector(
                  onTap: () => onCategoryTap?.call(cat),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: _circleSize,
                        height: _circleSize,
                        decoration: BoxDecoration(
                          color: style.color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: hasImage
                            ? CachedImage(
                                cat.image,
                                width: _circleSize,
                                height: _circleSize,
                                fit: BoxFit.cover,
                                errorWidget: Icon(
                                  style.icon,
                                  size: _iconSize,
                                  color: style.color,
                                ),
                                placeholder: Icon(
                                  style.icon,
                                  size: _iconSize,
                                  color: style.color,
                                ),
                              )
                            : Icon(
                                style.icon,
                                size: _iconSize,
                                color: style.color,
                              ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryStyle {
  final IconData icon;
  final Color color;

  const _CategoryStyle(this.icon, this.color);

  static const Map<String, _CategoryStyle> _styles = {
    'coffee': _CategoryStyle(Icons.local_cafe, Color(0xFF6F4E37)),
    'fast food': _CategoryStyle(Icons.fastfood, Color(0xFFE64A19)),
    'pizza': _CategoryStyle(Icons.local_pizza, Color(0xFFC62828)),
    'drinks': _CategoryStyle(Icons.local_drink, Color(0xFF0288D1)),
    'noodles': _CategoryStyle(Icons.ramen_dining, Color(0xFFF9A825)),
    'dessert': _CategoryStyle(Icons.cake, Color(0xFFAD1457)),
    'chicken': _CategoryStyle(Icons.restaurant_menu, Color(0xFFEF6C00)),
  };

  static _CategoryStyle fromName(String name) {
    final key = name.trim().toLowerCase();
    return _styles[key] ??
        _CategoryStyle(Icons.restaurant, AppColors.primary);
  }
}
