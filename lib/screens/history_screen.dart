import 'dart:io';
import 'package:flutter/material.dart';
import '../services/photo_service.dart';
import '../services/share_service.dart';
import 'photo_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, String>> _photos = [];
  bool _isLoading = true;
  bool _showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _isLoading = true;
    });

    final photos = await PhotoService.getPhotos(favoritesOnly: _showFavoritesOnly);
    setState(() {
      _photos = photos;
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite(String photoPath) async {
    await PhotoService.toggleFavorite(photoPath);
    _loadPhotos();
  }

  Future<void> _deletePhoto(String photoPath) async {
    await PhotoService.deletePhoto(photoPath);
    _loadPhotos();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Photo deleted'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _sharePhoto(String photoPath) async {
    try {
      await ShareService.shareImage(photoPath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to share photo'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _saveWatermarkedPhoto(String photoPath) async {
    final success = await ShareService.saveWatermarkedImageToGallery(photoPath);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Saved to gallery!' : 'Failed to save'),
          backgroundColor: success 
              ? Theme.of(context).colorScheme.primary 
              : Colors.red,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ).createShader(bounds),
          child: const Text(
            'History',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  _showFavoritesOnly
                      ? Colors.pink.withOpacity(0.6)
                      : Theme.of(context).colorScheme.primary.withOpacity(0.4),
                  _showFavoritesOnly
                      ? Colors.red.withOpacity(0.6)
                      : Theme.of(context).colorScheme.secondary.withOpacity(0.4),
                ],
              ),
              border: Border.all(
                color: _showFavoritesOnly
                    ? Colors.pink.withOpacity(0.8)
                    : Theme.of(context).colorScheme.primary.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  setState(() {
                    _showFavoritesOnly = !_showFavoritesOnly;
                  });
                  _loadPhotos();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
                    size: 22,
                    color: _showFavoritesOnly ? Colors.pink[200] : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Loading photos...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            )
          : _photos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              _showFavoritesOnly 
                                  ? Colors.pink.withOpacity(0.3)
                                  : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              _showFavoritesOnly
                                  ? Colors.red.withOpacity(0.3)
                                  : Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _showFavoritesOnly
                                  ? Colors.pink.withOpacity(0.3)
                                  : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          _showFavoritesOnly ? Icons.favorite_border : Icons.photo_library_outlined,
                          size: 70,
                          color: _showFavoritesOnly 
                              ? Colors.pink[200]
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        _showFavoritesOnly ? 'No favorites yet' : 'No photos yet',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _showFavoritesOnly 
                            ? 'Favorite photos to see them here!'
                            : 'Take your first vibe check!',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 16,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).scaffoldBackgroundColor,
                        Theme.of(context).colorScheme.surface.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _photos.length,
                    itemBuilder: (context, index) {
                      final photo = _photos[index];
                      final isFavorite = photo['isFavorite'] == 'true';
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PhotoDetailScreen(
                                photoPath: photo['path']!,
                                timestamp: photo['timestamp']!,
                                isFavorite: isFavorite,
                                onDelete: () {
                                  _deletePhoto(photo['path']!);
                                },
                                onFavoriteToggle: () {
                                  _toggleFavorite(photo['path']!);
                                },
                              ),
                            ),
                          );
                          _loadPhotos();
                        },
                        child: Hero(
                          tag: photo['path']!,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                  Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(
                                    File(photo['path']!),
                                    fit: BoxFit.cover,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.3),
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.8),
                                        ],
                                        stops: const [0.0, 0.3, 1.0],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black.withOpacity(0.6),
                                            border: Border.all(
                                              color: isFavorite ? Colors.pink : Colors.white.withOpacity(0.5),
                                              width: 2,
                                            ),
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(20),
                                              onTap: () => _toggleFavorite(photo['path']!),
                                              child: Padding(
                                                padding: const EdgeInsets.all(6.0),
                                                child: Icon(
                                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                                  color: isFavorite ? Colors.pink : Colors.white,
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black.withOpacity(0.6),
                                            border: Border.all(
                                              color: Colors.red.withOpacity(0.7),
                                              width: 2,
                                            ),
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(20),
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    backgroundColor: Theme.of(context).colorScheme.surface,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20),
                                                      side: BorderSide(
                                                        color: Theme.of(context).colorScheme.primary,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    title: Text(
                                                      'Delete Photo',
                                                      style: TextStyle(
                                                        color: Theme.of(context).colorScheme.secondary,
                                                      ),
                                                    ),
                                                    content: Text(
                                                      'Are you sure you want to delete this photo?',
                                                      style: TextStyle(
                                                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                            color: Theme.of(context).colorScheme.secondary,
                                                          ),
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.red,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          _deletePhoto(photo['path']!);
                                                          Navigator.pop(context);
                                                        },
                                                        child: const Text(
                                                          'Delete',
                                                          style: TextStyle(color: Colors.white),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.all(6.0),
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black.withOpacity(0.6),
                                            border: Border.all(
                                              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                              width: 2,
                                            ),
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(20),
                                              onTap: () => _saveWatermarkedPhoto(photo['path']!),
                                              child: const Padding(
                                                padding: EdgeInsets.all(6.0),
                                                child: Icon(
                                                  Icons.download,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black.withOpacity(0.6),
                                            border: Border.all(
                                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                                              width: 2,
                                            ),
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(20),
                                              onTap: () => _sharePhoto(photo['path']!),
                                              child: const Padding(
                                                padding: EdgeInsets.all(6.0),
                                                child: Icon(
                                                  Icons.share,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
