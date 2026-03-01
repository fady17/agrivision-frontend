import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  /// Compresses image to ~1024px max dimension and converts to JPEG.
  /// Returns null if compression fails.
  static Future<File?> compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final targetPath = "$tempPath/upload_$timestamp.jpg";

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 80, // High enough for AI, low enough for speed
      minWidth: 1024,
      minHeight: 1024,
    );

    if (result != null) {
      return File(result.path);
    }
    return null;
  }
}