import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_scaffold.dart';

/// Full-screen receipt viewer with pinch-to-zoom (FR-121).
class ReceiptImageViewerPage extends StatefulWidget {
  const ReceiptImageViewerPage({
    super.key,
    required this.imagePaths,
    this.initialIndex = 0,
    this.allowDelete = false,
    this.onDelete,
  });

  final List<String> imagePaths;
  final int initialIndex;
  final bool allowDelete;
  final ValueChanged<int>? onDelete;

  static Future<void> open(
    BuildContext context, {
    required List<String> imagePaths,
    int initialIndex = 0,
    bool allowDelete = false,
    ValueChanged<int>? onDelete,
  }) {
    if (imagePaths.isEmpty) return Future.value();
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ReceiptImageViewerPage(
          imagePaths: imagePaths,
          initialIndex: initialIndex,
          allowDelete: allowDelete,
          onDelete: onDelete,
        ),
      ),
    );
  }

  @override
  State<ReceiptImageViewerPage> createState() => _ReceiptImageViewerPageState();
}

class _ReceiptImageViewerPageState extends State<ReceiptImageViewerPage> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.imagePaths.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _deleteCurrent() {
    widget.onDelete?.call(_currentIndex);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'receipt_viewer_title'.trParams({
        'current': '${_currentIndex + 1}',
        'total': '${widget.imagePaths.length}',
      }),
      actions: widget.allowDelete
          ? [
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: 'receipt_delete_image'.tr,
                onPressed: _deleteCurrent,
              ),
            ]
          : null,
      body: ColoredBox(
        color: Colors.black,
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.imagePaths.length,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          itemBuilder: (context, index) {
            final path = widget.imagePaths[index];
            final file = File(path);
            if (!file.existsSync()) {
              return Center(
                child: Text(
                  'receipt_image_missing'.tr,
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            }

            return InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Center(
                child: Image.file(file, fit: BoxFit.contain),
              ),
            );
          },
        ),
      ),
    );
  }
}
