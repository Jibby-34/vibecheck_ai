import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class ShareService {
  static Future<File> addWatermark(String imagePath) async {
    final imageFile = File(imagePath);
    final imageBytes = await imageFile.readAsBytes();
    
    img.Image? image = img.decodeImage(imageBytes);
    
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    final watermarkText = 'VibeCheck AI';
    final fontSize = (image.width * 0.05).toInt();
    
    img.drawString(
      image,
      watermarkText,
      font: img.arial48,
      x: 20,
      y: image.height - 60,
      color: img.ColorRgba8(255, 255, 255, 200),
    );

    img.drawString(
      image,
      watermarkText,
      font: img.arial48,
      x: 22,
      y: image.height - 58,
      color: img.ColorRgba8(0, 0, 0, 100),
    );

    final tempDir = await getTemporaryDirectory();
    final watermarkedPath = '${tempDir.path}/watermarked_${DateTime.now().millisecondsSinceEpoch}.png';
    final watermarkedFile = File(watermarkedPath);
    
    await watermarkedFile.writeAsBytes(img.encodePng(image));
    
    return watermarkedFile;
  }

  static Future<void> shareImage(String imagePath) async {
    try {
      final watermarkedFile = await addWatermark(imagePath);
      
      await Share.shareXFiles(
        [XFile(watermarkedFile.path)],
        text: 'Check out my vibe! 🎉',
      );

      await Future.delayed(const Duration(seconds: 2));
      if (await watermarkedFile.exists()) {
        await watermarkedFile.delete();
      }
    } catch (e) {
      print('Error sharing image: $e');
      rethrow;
    }
  }

  static Future<bool> saveWatermarkedImageToGallery(String imagePath) async {
    try {
      final watermarkedFile = await addWatermark(imagePath);
      final watermarkedBytes = await watermarkedFile.readAsBytes();
      
      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(watermarkedBytes),
        quality: 100,
        name: 'vibecheck_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (await watermarkedFile.exists()) {
        await watermarkedFile.delete();
      }
      
      return result['isSuccess'] == true;
    } catch (e) {
      print('Error saving watermarked image: $e');
      return false;
    }
  }
}
