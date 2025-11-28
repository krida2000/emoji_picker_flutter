import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

/// Default EmojiPicker Implementation
class DefaultEmojiPickerView extends EmojiPickerView {
  /// Constructor
  const DefaultEmojiPickerView(super.config, super.state, super.showSearchBar,
      {super.key});

  @override
  State<DefaultEmojiPickerView> createState() => _DefaultEmojiPickerViewState();
}

class _DefaultEmojiPickerViewState extends State<DefaultEmojiPickerView>
    with SingleTickerProviderStateMixin, SkinToneOverlayStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  final _scrollController = ScrollController();

  double _emojiSize = 0;

  int _columns = 0;

  late final CategoryEmoji _recentEmoji;

  @override
  void initState() {
    // Use controller's current category if available,
    // otherwise use config's initCategory
    final targetCategory = widget.state.currentCategory ??
        widget.config.categoryViewConfig.initCategory;

    var initCategory = widget.state.categoryEmoji
        .indexWhere((element) => element.category == targetCategory);
    if (initCategory == -1) {
      initCategory = 0;
    }
    _tabController = TabController(
        initialIndex: initCategory,
        length: widget.state.categoryEmoji.length,
        vsync: this);
    _pageController = PageController(initialPage: initCategory)
      ..addListener(closeSkinToneOverlay);
    _scrollController.addListener(closeSkinToneOverlay);
    _scrollController.addListener(() {
      final double offset = _scrollController.offset;
      double categoryOffset = widget.config.emojiViewConfig.gridPadding.top;

      for (int i = 0; i < widget.state.categoryEmoji.length; i++) {
        categoryOffset +=
            (widget.state.categoryEmoji[i].emoji.length / _columns).ceil() *
                (_emojiSize + widget.config.emojiViewConfig.verticalSpacing);

        if (offset < categoryOffset) {
          _tabController.index = i;
          break;
        }
      }
    });
    _recentEmoji = widget.state.categoryEmoji.first;
    super.initState();
  }

  void _onCategoryNavigationChanged() {
    final targetCategory = widget.state.categoryNavigationNotifier.value;
    if (targetCategory != null) {
      final index = widget.state.categoryEmoji
          .indexWhere((element) => element.category == targetCategory);
      if (index != -1) {
        final currentPage = _pageController.page?.round();
        if (index != currentPage) {
          // Use jumpToPage for instant navigation without building
          // intermediate pages. This prevents performance issues when
          // jumping to tabs far away. The onPageChanged callback will
          // handle animating the tab indicator
          _pageController.jumpToPage(index);
        }
      }
    }
  }

  @override
  void dispose() {
    closeSkinToneOverlay();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final emojiSize = widget.config.emojiViewConfig.emojiSizeMax;
        final emojiBoxSize = widget.config.emojiViewConfig.emojiSizeMax;
        _columns = widget.config.emojiViewConfig.getColumns(
          constraints.maxWidth,
        );
        _emojiSize = widget.config.emojiViewConfig.getRealEmojiSize(
          constraints.maxWidth,
          _columns,
        );
        return EmojiContainer(
          color: widget.config.emojiViewConfig.backgroundColor,
          buttonMode: widget.config.emojiViewConfig.buttonMode,
          child: Column(
            children: [
              widget.config.viewOrderConfig.top,
              widget.config.viewOrderConfig.middle,
              widget.config.viewOrderConfig.bottom,
            ].map(
              (item) {
                switch (item) {
                  case EmojiPickerItem.categoryBar:
                    // Category view
                    return _buildCategoryView(
                      emojiSize + widget.config.emojiViewConfig.verticalSpacing,
                      _columns,
                    );
                  case EmojiPickerItem.emojiView:
                    // Emoji view
                    return _buildEmojiView(emojiSize, emojiBoxSize, _columns);
                  case EmojiPickerItem.searchBar:
                    // Search Bar
                    return const SizedBox();
                }
              },
            ).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCategoryView(double emojiSize, int columnsCount) {
    return widget.config.categoryViewConfig.customCategoryView != null
        ? widget.config.categoryViewConfig.customCategoryView!(
            widget.config,
            widget.state,
            _tabController,
            _pageController,
          )
        : DefaultCategoryView(
            widget.config,
            widget.state,
            _tabController,
            _pageController,
            (index) {
              double offset = widget.config.emojiViewConfig.gridPadding.top;

              for (int i = 0; i < index; i++) {
                offset +=
                    (widget.state.categoryEmoji[i].emoji.length / columnsCount)
                            .ceil() *
                        (_emojiSize +
                            widget.config.emojiViewConfig.verticalSpacing);
              }

              _scrollController.animateTo(
                offset,
                duration: const Duration(milliseconds: 200),
                curve: Curves.linear,
              );
            },
          );
  }

  Widget _buildEmojiView(
    double emojiSize,
    double emojiBoxSize,
    int columnsCount,
  ) {
    return Flexible(
      child: Padding(
        padding: EdgeInsets.only(
          left: widget.config.emojiViewConfig.gridPadding.left,
          right: widget.config.emojiViewConfig.gridPadding.right,
        ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: List.generate(
            widget.state.categoryEmoji.length,
            (i) => _buildPage(
              emojiSize,
              emojiBoxSize,
              columnsCount,
              widget.state.categoryEmoji[i],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSearchBar() {
    if (!widget.config.bottomActionBarConfig.enabled) {
      return const SizedBox.shrink();
    }
    return widget.config.bottomActionBarConfig.customBottomActionBar != null
        ? widget.config.bottomActionBarConfig.customBottomActionBar!(
            widget.config,
            widget.state,
            widget.showSearchBar,
          )
        : DefaultBottomActionBar(
            widget.config,
            widget.state,
            widget.showSearchBar,
          );
  }

  Widget _buildPage(
    double emojiSize,
    double emojiBoxSize,
    int columnsCount,
    CategoryEmoji categoryEmoji,
  ) {
    if (categoryEmoji.category.index == 0) {
      categoryEmoji = _recentEmoji;
    }

    final crossAxisSpacing = widget.config.emojiViewConfig.horizontalSpacing -
        (columnsCount * 10 / (columnsCount - 1));

    // Build page normally
    return SliverPadding(
      padding: EdgeInsets.only(
        top: categoryEmoji.category.index == 0
            ? widget.config.emojiViewConfig.gridPadding.top
            : 0,
        bottom: widget.config.emojiViewConfig.verticalSpacing - 10,
      ),
      sliver: SliverGrid.builder(
        key: Key('SliverGrid${categoryEmoji.category.index}'),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1,
          crossAxisCount: columnsCount,
          mainAxisSpacing: widget.config.emojiViewConfig.verticalSpacing - 10,
          crossAxisSpacing: crossAxisSpacing,
        ),
        itemCount: categoryEmoji.emoji.length,
        itemBuilder: (context, index) {
          return addSkinToneTargetIfAvailable(
            hasSkinTone: categoryEmoji.emoji[index].hasSkinTone,
            linkKey:
                categoryEmoji.category.name + categoryEmoji.emoji[index].emoji,
            child: EmojiCell.fromConfig(
              emoji: categoryEmoji.emoji[index],
              emojiSize: emojiSize,
              emojiBoxSize: emojiBoxSize,
              categoryEmoji: categoryEmoji,
              onEmojiSelected: _onSkinTonedEmojiSelected,
              onSkinToneDialogRequested: _openSkinToneDialog,
              config: widget.config,
            ),
          );
        },
      ),
    );
  }

  /// Build Widget for when no recent emoji are available
  Widget _buildNoRecent() {
    return Center(
      child: widget.config.emojiViewConfig.noRecents,
    );
  }

  void _openSkinToneDialog(
    Offset emojiBoxPosition,
    Emoji emoji,
    double emojiSize,
    CategoryEmoji? categoryEmoji,
  ) {
    closeSkinToneOverlay();
    if (!emoji.hasSkinTone || !widget.config.skinToneConfig.enabled) {
      return;
    }
    showSkinToneOverlay(
      emojiBoxPosition,
      emoji,
      emojiSize,
      categoryEmoji,
      widget.config,
      _onSkinTonedEmojiSelected,
      links[categoryEmoji!.category.name + emoji.emoji]!,
    );
  }

  void _onSkinTonedEmojiSelected(Category? category, Emoji emoji) {
    widget.state.onEmojiSelected(category, emoji);
    closeSkinToneOverlay();
  }
}
