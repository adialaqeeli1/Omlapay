import 'package:flutter/material.dart';

import 'common_loading_indicator.dart';

/// A reusable paginated list view that handles scroll-based pagination.
///
/// Triggers [onLoadMore] when the user scrolls within [loadMoreThreshold]
/// pixels of the bottom. Shows a loading indicator at the bottom while
/// [isLoadingMore] is true.
class PaginatedListView extends StatefulWidget {
  /// Builder for each item in the list.
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Total number of items currently loaded.
  final int itemCount;

  /// Whether more items are currently being fetched.
  final bool isLoadingMore;

  /// Whether there are more items to load.
  final bool hasMore;

  /// Called when the user scrolls near the bottom and [hasMore] is true.
  final VoidCallback onLoadMore;

  /// Distance from the bottom (in pixels) at which [onLoadMore] is triggered.
  final double loadMoreThreshold;

  /// Padding around the list content.
  final EdgeInsetsGeometry? padding;

  /// Optional physics for the scroll view.
  final ScrollPhysics? physics;

  const PaginatedListView({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    required this.isLoadingMore,
    required this.hasMore,
    required this.onLoadMore,
    this.loadMoreThreshold = 200,
    this.padding,
    this.physics,
  });

  @override
  State<PaginatedListView> createState() => _PaginatedListViewState();
}

class _PaginatedListViewState extends State<PaginatedListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasMore || widget.isLoadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - widget.loadMoreThreshold) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      physics: widget.physics,
      itemCount: widget.itemCount + (widget.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.itemCount) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CommonLoadingIndicator()),
          );
        }
        return widget.itemBuilder(context, index);
      },
    );
  }
}
