import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_constants.dart';
import 'receipt_image_viewer_page.dart';

/// Thumbnail grid for viewing receipt images (FR-121).
class ReceiptThumbnailGrid extends StatelessWidget {
  const ReceiptThumbnailGrid({
    super.key,
    required this.imagePaths,
    this.thumbnailSize = 100,
    this.allowDelete = false,
    this.onRemove,
  });

  final List<String> imagePaths;
  final double thumbnailSize;
  final bool allowDelete;
  final ValueChanged<int>? onRemove;

  @override
  Widget build(BuildContext context) {
    if (imagePaths.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < imagePaths.length; i++)
          _Thumbnail(
            path: imagePaths[i],
            size: thumbnailSize,
            onTap: () => ReceiptImageViewerPage.open(
              context,
              imagePaths: imagePaths,
              initialIndex: i,
              allowDelete: allowDelete,
              onDelete: onRemove,
            ),
            onRemove: allowDelete && onRemove != null
                ? () => onRemove!(i)
                : null,
          ),
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.path,
    required this.size,
    required this.onTap,
    this.onRemove,
  });

  final String path;
  final double size;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final file = File(path);
    final exists = file.existsSync();

    return Stack(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: exists
                ? Image.file(
                    file,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: size,
                    height: size,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ),
          ),
        ),
        if (onRemove != null)
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: onRemove,
            ),
          ),
      ],
    );
  }
}

/// Gallery/camera picker with thumbnails for transaction forms (FR-119–FR-121).
class ReceiptImagePickerSection extends StatelessWidget {
  const ReceiptImagePickerSection({
    super.key,
    required this.title,
    required this.imagePaths,
    required this.onAddGallery,
    required this.onAddCamera,
    required this.onRemove,
    this.galleryLabel,
    this.cameraLabel,
    this.maxImages = AppConstants.maxImagesPerTransaction,
  });

  final String title;
  final List<String> imagePaths;
  final VoidCallback onAddGallery;
  final VoidCallback onAddCamera;
  final ValueChanged<int> onRemove;
  final String? galleryLabel;
  final String? cameraLabel;
  final int maxImages;

  @override
  Widget build(BuildContext context) {
    final canAddMore = imagePaths.length < maxImages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        if (canAddMore)
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onAddGallery,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(galleryLabel ?? 'expense_gallery'.tr),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onAddCamera,
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(cameraLabel ?? 'expense_camera'.tr),
              ),
            ],
          ),
        if (!canAddMore) ...[
          Text(
            'receipt_max_images'.trParams({'count': maxImages.toString()}),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 8),
        ReceiptThumbnailGrid(
          imagePaths: imagePaths,
          thumbnailSize: 72,
          allowDelete: true,
          onRemove: onRemove,
        ),
      ],
    );
  }
}
