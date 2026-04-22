import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/vibe_result.dart';
import '../services/photo_service.dart';

class VibeResultScreen extends StatefulWidget {
  final VibeResult result;
  final String imagePath;

  const VibeResultScreen({
    super.key,
    required this.result,
    required this.imagePath,
  });

  @override
  State<VibeResultScreen> createState() => _VibeResultScreenState();
}

class _VibeResultScreenState extends State<VibeResultScreen> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isSaved = false;

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF4CAF50);
    if (score >= 60) return const Color(0xFF8BC34A);
    if (score >= 40) return const Color(0xFFFFC107);
    if (score >= 20) return const Color(0xFFFF9800);
    return const Color(0xFFFF5252);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 800));
      await _saveCardAsImage();
    });
  }

  Future<void> _saveCardAsImage() async {
    if (_isSaved) return;

    try {
      final RenderRepaintBoundary boundary =
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = 'vibecheck_card_$timestamp.png';
      final String savePath = path.join(appDir.path, fileName);

      final File file = File(savePath);
      await file.writeAsBytes(pngBytes);

      await PhotoService.savePhoto(savePath);

      setState(() {
        _isSaved = true;
      });

      print('Card saved successfully to: $savePath');
    } catch (e) {
      print('Error saving card: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = _getScoreColor(widget.result.vibeScore);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            RepaintBoundary(
                              key: _cardKey,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(60),
                                    topRight: Radius.circular(45),
                                    bottomLeft: Radius.circular(45),
                                    bottomRight: Radius.circular(60),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Theme.of(context).colorScheme.surface.withOpacity(0.95),
                                      Theme.of(context).colorScheme.surface.withOpacity(0.85),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                      offset: const Offset(-5, 5),
                                    ),
                                    BoxShadow(
                                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                                      blurRadius: 60,
                                      spreadRadius: 15,
                                      offset: const Offset(5, -5),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(28.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(40),
                                          topRight: Radius.circular(30),
                                          bottomLeft: Radius.circular(30),
                                          bottomRight: Radius.circular(40),
                                        ),
                                        child: Container(
                                          constraints: BoxConstraints(
                                            maxHeight: constraints.maxHeight * 0.4,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(40),
                                              topRight: Radius.circular(30),
                                              bottomLeft: Radius.circular(30),
                                              bottomRight: Radius.circular(40),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: scoreColor.withOpacity(0.4),
                                                blurRadius: 25,
                                                spreadRadius: 3,
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(40),
                                              topRight: Radius.circular(30),
                                              bottomLeft: Radius.circular(30),
                                              bottomRight: Radius.circular(40),
                                            ),
                                            child: Image.file(
                                              File(widget.imagePath),
                                              fit: BoxFit.contain,
                                              width: double.infinity,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 28),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 30,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
                                              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(40),
                                            topRight: Radius.circular(50),
                                            bottomLeft: Radius.circular(50),
                                            bottomRight: Radius.circular(40),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: scoreColor.withOpacity(0.3),
                                              blurRadius: 20,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'VIBE SCORE',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.8),
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 2.5,
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Container(
                                                  width: 140,
                                                  height: 140,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: RadialGradient(
                                                      colors: [
                                                        scoreColor.withOpacity(0.5),
                                                        scoreColor.withOpacity(0.3),
                                                        scoreColor.withOpacity(0.1),
                                                        Colors.transparent,
                                                      ],
                                                      stops: const [0.0, 0.4, 0.7, 1.0],
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: 110,
                                                  height: 110,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: SweepGradient(
                                                      colors: [
                                                        scoreColor,
                                                        scoreColor.withOpacity(0.8),
                                                        scoreColor,
                                                      ],
                                                      stops: const [0.0, 0.5, 1.0],
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: scoreColor.withOpacity(0.7),
                                                        blurRadius: 30,
                                                        spreadRadius: 5,
                                                      ),
                                                      BoxShadow(
                                                        color: scoreColor.withOpacity(0.4),
                                                        blurRadius: 50,
                                                        spreadRadius: 10,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${widget.result.vibeScore}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 46,
                                                        fontWeight: FontWeight.bold,
                                                        shadows: [
                                                          Shadow(
                                                            color: Colors.black38,
                                                            offset: Offset(0, 3),
                                                            blurRadius: 6,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 24),
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 24,
                                                vertical: 18,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Theme.of(context).colorScheme.surface.withOpacity(0.7),
                                                    Theme.of(context).colorScheme.surface.withOpacity(0.5),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(25),
                                                  topRight: Radius.circular(30),
                                                  bottomLeft: Radius.circular(30),
                                                  bottomRight: Radius.circular(25),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: scoreColor.withOpacity(0.2),
                                                    blurRadius: 15,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                widget.result.tagline,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.5,
                                                  letterSpacing: 0.3,
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
                            const SizedBox(height: 32),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.secondary,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                    blurRadius: 25,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(25),
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    child: const Text(
                                      'Take Another',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          SafeArea(
            child: Positioned(
              top: 12,
              left: 20,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.4),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white.withOpacity(0.95),
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
