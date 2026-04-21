import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PhotoService {
  static const String _photoListFile = 'photo_list.txt';

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _photoListFileRef async {
    final path = await _localPath;
    return File('$path/$_photoListFile');
  }

  static Future<void> savePhoto(String photoPath) async {
    final file = await _photoListFileRef;
    final timestamp = DateTime.now().toIso8601String();
    await file.writeAsString('$photoPath|$timestamp\n', mode: FileMode.append);
  }

  static Future<List<Map<String, String>>> getPhotos() async {
    try {
      final file = await _photoListFileRef;
      if (!await file.exists()) {
        return [];
      }

      final contents = await file.readAsString();
      if (contents.isEmpty) {
        return [];
      }

      final lines = contents.split('\n').where((line) => line.isNotEmpty);
      final photos = <Map<String, String>>[];

      for (final line in lines) {
        final parts = line.split('|');
        if (parts.length == 2) {
          final photoFile = File(parts[0]);
          if (await photoFile.exists()) {
            photos.add({
              'path': parts[0],
              'timestamp': parts[1],
            });
          }
        }
      }

      photos.sort((a, b) => b['timestamp']!.compareTo(a['timestamp']!));
      return photos;
    } catch (e) {
      print('Error getting photos: $e');
      return [];
    }
  }

  static Future<void> deletePhoto(String photoPath) async {
    try {
      final file = await _photoListFileRef;
      if (!await file.exists()) {
        return;
      }

      final contents = await file.readAsString();
      final lines = contents.split('\n');
      final updatedLines = lines.where((line) {
        return !line.startsWith(photoPath);
      }).join('\n');

      await file.writeAsString(updatedLines);

      final photoFile = File(photoPath);
      if (await photoFile.exists()) {
        await photoFile.delete();
      }
    } catch (e) {
      print('Error deleting photo: $e');
    }
  }
}
