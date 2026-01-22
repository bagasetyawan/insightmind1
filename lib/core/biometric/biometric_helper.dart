import 'dart:io';
import 'package:flutter/material.dart';
import 'package:insightmind_app/core/biometric/face_scan_page.dart';

/// Helper untuk fitur biometrik berbasis wajah.
///
/// Membuka halaman scan wajah dan mengembalikan file gambar yang berhasil di-capture,
/// atau null jika scan dibatalkan/gagal.
class BiometricHelper {
  /// Membuka halaman scan wajah menggunakan kamera depan.
  /// Mengembalikan File gambar wajah jika terdeteksi, atau null jika dibatalkan/gagal.
  static Future<File?> scanFace(BuildContext context) async {
    if (!context.mounted) return null;

    final result = await Navigator.of(context).push<File?>(
      MaterialPageRoute(builder: (_) => const FaceScanPage()),
    );

    return result;
  }
}
