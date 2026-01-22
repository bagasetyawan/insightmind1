import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screening_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _capturedImage;
  bool _isOpeningCamera = false;

  @override
  void initState() {
    super.initState();
    _openCamera();
  }

  Future<void> _openCamera() async {
    if (_isOpeningCamera) return;
    _isOpeningCamera = true;

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);

      if (!mounted) return;

      setState(() {
        _capturedImage = image;
      });
    } finally {
      _isOpeningCamera = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scan Wajah',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            onPressed: _openCamera,
            tooltip: 'Buka Kamera Lagi',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Silakan ambil foto wajah Anda untuk verifikasi tambahan. Setelah itu Anda dapat melanjutkan ke proses screening.',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: _capturedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.camera_alt_rounded,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '''Belum ada foto.
Tekan ikon kamera di atas untuk mengambil gambar.''',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(color: Colors.grey[700]),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(_capturedImage!.path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ScreeningPage(),
                  ),
                );
              },
              icon: const Icon(Icons.navigate_next_rounded),
              label: Text(
                'Lanjut ke Screening',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
