import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show WriteBuffer;
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceScanPage extends StatefulWidget {
  const FaceScanPage({super.key});

  @override
  State<FaceScanPage> createState() => _FaceScanPageState();
}

class _FaceScanPageState extends State<FaceScanPage> {
  CameraController? _controller;
  late FaceDetector _faceDetector;
  bool _detecting = false;
  bool _foundFace = false;
  // Hitung berapa frame berturut-turut yang berisi wajah
  int _consecutiveFaceFrames = 0;
  // Waktu mulai preview, untuk memastikan kamera tampil minimal beberapa detik
  late DateTime _startTime;
  // File gambar terakhir untuk API
  File? _capturedImageFile;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();

      _startTime = DateTime.now();

      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.fast,
        ),
      );

      await _controller!.startImageStream(_processImage);

      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      if (mounted) {
        Navigator.pop(context, false);
      }
    }
  }

  Future<void> _processImage(CameraImage image) async {
    if (!mounted || _detecting || _foundFace) return;
    _detecting = true;

    try {
      final inputImage = _convertCameraImage(image);
      if (inputImage == null) return;

      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty && mounted) {
        _consecutiveFaceFrames++;

        // Waktu minimal kamera aktif (misalnya 5 detik)
        final elapsed = DateTime.now().difference(_startTime);

        // Butuh beberapa frame berturut-turut + durasi minimal agar tidak langsung keluar
        if (_consecutiveFaceFrames >= 5 && elapsed.inMilliseconds >= 5000) {
          _foundFace = true;
          
          // Capture frame terakhir sebagai file untuk API
          try {
            final xFile = await _controller?.takePicture();
            if (xFile != null) {
              _capturedImageFile = File(xFile.path);
              // ignore: avoid_print
              print('Captured image: ${_capturedImageFile?.path}');
            }
          } catch (e) {
            // ignore: avoid_print
            print('Error capturing image: $e');
          }
          
          Navigator.pop(context, _capturedImageFile);
        }
      } else {
        _consecutiveFaceFrames = 0;
      }
    } catch (_) {
      // ignore
    } finally {
      _detecting = false;
    }
  }

  InputImage? _convertCameraImage(CameraImage image) {
    try {
      final WriteBuffer buffer = WriteBuffer();
      for (final plane in image.planes) {
        buffer.putUint8List(plane.bytes);
      }
      final bytes = buffer.done().buffer.asUint8List();

      final Size imageSize =
          Size(image.width.toDouble(), image.height.toDouble());

        final camera = _controller!.description;
      final imageRotation =
          InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
              InputImageRotation.rotation0deg;

      final inputImageFormat =
          InputImageFormatValue.fromRawValue(image.format.raw) ??
              InputImageFormat.yuv420;

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: imageSize,
          rotation: imageRotation,
          format: inputImageFormat,
          bytesPerRow:
              image.planes.isNotEmpty ? image.planes.first.bytesPerRow : 0,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    if (_controller != null) {
      if (_controller!.value.isInitialized) {
        _controller!.stopImageStream();
      }
      _controller!.dispose();
    }
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Calculate progress (0.0 to 1.0)
    final elapsedMs = DateTime.now().difference(_startTime).inMilliseconds;
    final progress = (elapsedMs / 5000).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Wajah'),
        backgroundColor: const Color(0xFF00BCD4),
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          // Dark overlay di atas kamera
          Container(
            color: Colors.black.withValues(alpha: 0.15),
          ),
          // Bottom detection card dengan progress bar
          Positioned(
            left: 16,
            right: 16,
            bottom: 32,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF00BCD4).withValues(alpha: 0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status text
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _foundFace
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFF00BCD4),
                          boxShadow: [
                            BoxShadow(
                              color: _foundFace
                                  ? const Color(0xFF4CAF50).withValues(alpha: 0.5)
                                  : const Color(0xFF00BCD4).withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _foundFace
                              ? 'Wajah terdeteksi! ✓'
                              : 'Sedang mendeteksi wajah...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: const Color(0xFF00BCD4),
                          value: _foundFace ? 1.0 : progress,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _foundFace
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFF00BCD4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Time indicator
                  Text(
                    '${(elapsedMs / 1000).toStringAsFixed(1)}s / 5.0s',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
