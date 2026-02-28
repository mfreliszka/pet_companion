import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Utilities for picking, cropping, and compressing pet photos.
class ImageUtils {
  ImageUtils._();

  static final _picker = ImagePicker();

  /// Pick an image, crop it to a square, compress, and return bytes.
  ///
  /// Returns `null` if the user cancels at any step.
  static Future<Uint8List?> pickAndProcessImage({
    required ImageSource source,
    int maxDimension = 1024,
    int quality = 80,
  }) async {
    // 1. Pick image
    final pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 2048,
      maxHeight: 2048,
    );
    if (pickedFile == null) return null;

    // 2. Crop to square (face-centered)
    CroppedFile? cropped;
    try {
      cropped = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 100, // We'll compress separately
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Photo',
            toolbarColor: Colors.teal,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
          ),
          IOSUiSettings(title: 'Crop Photo', aspectRatioLockEnabled: true),
        ],
      );
    } catch (e) {
      // Android image_cropper can crash with "Reply already submitted" —
      // fall back to the uncropped picked file.
      debugPrint('ImageCropper error (using uncropped): $e');
    }
    final imagePath = cropped?.path ?? pickedFile.path;

    // 3. Compress
    final compressedBytes = await FlutterImageCompress.compressWithFile(
      imagePath,
      minWidth: maxDimension,
      minHeight: maxDimension,
      quality: quality,
      format: CompressFormat.jpeg,
    );

    return compressedBytes != null ? Uint8List.fromList(compressedBytes) : null;
  }

  /// Create a smaller thumbnail from already-compressed bytes.
  static Future<Uint8List?> createThumbnail(
    Uint8List source, {
    int maxDimension = 200,
    int quality = 70,
  }) async {
    final result = await FlutterImageCompress.compressWithList(
      source,
      minWidth: maxDimension,
      minHeight: maxDimension,
      quality: quality,
      format: CompressFormat.jpeg,
    );

    return Uint8List.fromList(result);
  }
}
