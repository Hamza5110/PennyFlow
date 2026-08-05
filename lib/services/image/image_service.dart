import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/base/base_service.dart';
import '../../core/constants/app_constants.dart';

/// Receipt image pick, compress, and local storage (FR-020, FR-021).
class ImageService extends GetxService with BaseService {
  ImageService() : _picker = ImagePicker(), _uuid = const Uuid();

  final ImagePicker _picker;
  final Uuid _uuid;

  Future<List<String>> pickFromGallery({int maxImages = 5}) async {
    final files = await _picker.pickMultiImage(
      imageQuality: 85,
      limit: maxImages,
    );
    if (files.isEmpty) return [];
    return _saveCompressed(files);
  }

  Future<String?> pickFromCamera() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (file == null) return null;
    final paths = await _saveCompressed([file]);
    return paths.isEmpty ? null : paths.first;
  }

  Future<List<String>> _saveCompressed(List<XFile> files) async {
    final dir = await _receiptsDir();
    final saved = <String>[];

    for (final file in files) {
      if (saved.length >= AppConstants.maxImagesPerTransaction) break;

      final targetPath = p.join(dir.path, '${_uuid.v4()}.jpg');
      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: 75,
        minWidth: 1280,
        minHeight: 1280,
      );

      if (result != null) {
        saved.add(result.path);
      }
    }
    return saved;
  }

  Future<Directory> _receiptsDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'receipts'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<void> deleteImages(List<String> paths) async {
    for (final path in paths) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}
