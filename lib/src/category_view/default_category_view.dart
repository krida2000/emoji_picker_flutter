import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

/// Default category view
class DefaultCategoryView extends CategoryView {
  /// Constructor
  const DefaultCategoryView(
    super.config,
    super.state,
    super.tabController,
    super.pageController,
    super.onTap, {
    super.key,
  });

  @override
  DefaultCategoryViewState createState() => DefaultCategoryViewState();
}

/// Default Category View State
class DefaultCategoryViewState extends CategoryViewState {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.config.categoryViewConfig.backgroundColor,
      child: Row(
        children: [
          Expanded(
            child: DefaultCategoryTabBar(
              widget.config,
              widget.tabController,
              widget.state.categoryEmoji,
              closeSkinToneOverlay,
              widget.onTap,
            ),
          ),
          _buildExtraTab(widget.config.categoryViewConfig.extraTab),
        ],
      ),
    );
  }

  Widget _buildExtraTab(extraTab) {
    if (extraTab == CategoryExtraTab.BACKSPACE) {
      return BackspaceButton(
        widget.config,
        widget.state.onBackspacePressed,
        widget.state.onBackspaceLongPressed,
        widget.config.categoryViewConfig.backspaceColor,
      );
    } else if (extraTab == CategoryExtraTab.SEARCH) {
      return SearchButton(
        widget.config,
        widget.state.onShowSearchView,
        widget.config.categoryViewConfig.iconColor,
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
