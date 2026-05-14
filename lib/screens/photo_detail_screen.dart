import 'dart:io';
import 'package:flutter/material.dart';
import '../services/share_service.dart';

class PhotoDetailScreen extends StatefulWidget {
  final String photoPath;
  final String timestamp;
  final bool isFavorite;
  final VoidCallback onDelete;
  final VoidCallback onFavoriteToggle;

  const PhotoDetailScreen({
    super.key,
    required this.photoPath,
    required this.timestamp,
    required this.isFavorite,
    required this.onDelete,
    required this.onFavoriteToggle,
  });

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    widget.onFavoriteToggle();
  }

  Future<void> _sharePhoto() async {
    try {
      await ShareService.shareImage(widget.photoPath);
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

  Future<void> _saveWatermarkedPhoto() async {
    final success = await ShareService.saveWatermarkedImageToGallery(widget.photoPath);
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
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: widget.photoPath,
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Image.file(
                  File(widget.photoPath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.5),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.download, color: Colors.white),
                              onPressed: _saveWatermarkedPhoto,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.5),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.share, color: Colors.white),
                              onPressed: _sharePhoto,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.5),
                              border: Border.all(
                                color: _isFavorite ? Colors.pink : Colors.white.withOpacity(0.5),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (_isFavorite ? Colors.pink : Colors.white).withOpacity(0.3),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: _isFavorite ? Colors.pink : Colors.white,
                              ),
                              onPressed: _toggleFavorite,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.5),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.7),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
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
                                          widget.onDelete();
                                          Navigator.pop(context);
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
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
