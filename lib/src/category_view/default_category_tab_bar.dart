import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

/// Default category tab bar
class DefaultCategoryTabBar extends StatelessWidget {
  /// Constructor
  const DefaultCategoryTabBar(
    this.config,
    this.tabController,
    this.categoryEmojis,
    this.closeSkinToneOverlay,
    this.onTap, {
    super.key,
  });

  /// Config
  final Config config;

  /// Tab controller
  final TabController tabController;

  /// Category emojis
  final List<CategoryEmoji> categoryEmojis;

  /// Close skin tone overlay callback
  final VoidCallback closeSkinToneOverlay;

  final void Function(int i) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: config.categoryViewConfig.tabBarHeight,
      child: TabBar(
        labelColor: config.categoryViewConfig.iconColorSelected,
        indicatorColor: config.categoryViewConfig.indicatorColor,
        unselectedLabelColor: config.categoryViewConfig.iconColor,
        dividerColor: config.categoryViewConfig.dividerColor,
        controller: tabController,
        labelPadding: EdgeInsets.zero,
        onTap: (index) {
          closeSkinToneOverlay();
          onTap(index);
        },
        tabs: categoryEmojis
            .asMap()
            .entries
            .map<Widget>(
              (item) => _buildCategoryTab(item.key, item.value.category),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCategoryTab(int index, Category category) {
    return Tab(
      icon: Icon(
        getIconForCategory(config.categoryViewConfig.categoryIcons, category),
      ),
    );
  }
}
