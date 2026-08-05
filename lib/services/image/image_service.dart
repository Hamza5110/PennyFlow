import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/base/base_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/image_compression_utils.dart';

/// Receipt image pick, compress, store, and delete (FR-119–FR-121).
class ImageService extends GetxService with BaseService {
  ImageService() : _picker = ImagePicker(), _uuid = const Uuid();

  final ImagePicker _picker;
  final Uuid _uuid;

  Future<List<String>> pickFromGallery({
    int? maxImages,
  }) async {
    final limit = maxImages ?? AppConstants.maxImagesPerTransaction;
    if (limit <= 0) return [];

    final files = await _picker.pickMultiImage(
      imageQuality: 85,
      limit: limit,
    );
    if (files.isEmpty) return [];
    return _saveCompressed(files, maxCount: limit);
  }

  Future<String?> pickFromCamera() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (file == null) return null;
    final paths = await _saveCompressed([file], maxCount: 1);
    return paths.isEmpty ? null : paths.first;
  }

  Future<List<String>> _saveCompressed(
    List<XFile> files, {
    required int maxCount,
  }) async {
    final dir = await receiptsDir();
    final saved = <String>[];

    for (final file in files) {
      if (saved.length >= maxCount) break;
      final path = await _compressToTarget(file.path, dir);
      if (path != null) saved.add(path);
    }
    return saved;
  }

  Future<String?> _compressToTarget(String sourcePath, Directory dir) async {
    var quality = ImageCompressionUtils.initialQuality;
    String? currentPath;

    while (quality >= ImageCompressionUtils.qualitySteps.last) {
      final targetPath = p.join(dir.path, '${_uuid.v4()}.jpg');
      final result = await FlutterImageCompress.compressAndGetFile(
        sourcePath,
        targetPath,
        quality: quality,
        minWidth: 1280,
        minHeight: 1280,
      );

      if (result == null) return currentPath;

      if (currentPath != null && currentPath != result.path) {
        await deleteImage(currentPath);
      }

      currentPath = result.path;
      final size = await File(result.path).length();
      if (!ImageCompressionUtils.exceedsMaxSize(size)) {
        return currentPath;
      }

      quality = ImageCompressionUtils.nextQuality(quality);
    }

    return currentPath;
  }

  Future<Directory> receiptsDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'receipts'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<bool> fileExists(String path) async => File(path).exists();

  Future<void> deleteImage(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> deleteImages(List<String> paths) async {
    for (final path in paths) {
      await deleteImage(path);
    }
  }

  Future<void> deleteRemovedPaths({
    required List<String> previous,
    required List<String> current,
  }) async {
    final removed =
        previous.where((path) => !current.contains(path)).toList();
    await deleteImages(removed);
  }
}
