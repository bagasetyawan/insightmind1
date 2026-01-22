import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:insightmind_app/core/biometric/stress_analysis_service.dart';
import 'package:insightmind_app/core/biometric/stress_api_service.dart'
    show BiometricStressLevel;
import 'package:insightmind_app/providers/screening_history_provider.dart';
//dwada
/// Halaman hasil deteksi stres berbasis biometrik (scan wajah).
class BiometricStressResultPage extends ConsumerStatefulWidget {
  /// File gambar wajah yang di-capture saat scan (opsional)
  final File? imageFile;

  const BiometricStressResultPage({
    super.key,
    this.imageFile,
  });

  @override
  ConsumerState<BiometricStressResultPage> createState() =>
      _BiometricStressResultPageState();
}

class _BiometricStressResultPageState extends ConsumerState<BiometricStressResultPage> {
  late Future<StressAnalysisResult> _stressAnalysisFuture;

  @override
  void initState() {
    super.initState();
    // Mulai analisis stres saat page dibuka
    // Pass imageFile ke service untuk API integration
    _stressAnalysisFuture = StressAnalysisService().analyzeStress(
      imageFile: widget.imageFile,
    );
  }

  String _getTitle(BiometricStressLevel level) {
    switch (level) {
      case BiometricStressLevel.rendah:
        return 'Rendah';
      case BiometricStressLevel.sedang:
        return 'Sedang';
      case BiometricStressLevel.tinggi:
        return 'Tinggi';
    }
  }

  Color _getColor(BiometricStressLevel level) {
    switch (level) {
      case BiometricStressLevel.rendah:
        return const Color(0xFF4CAF50);
      case BiometricStressLevel.sedang:
        return const Color(0xFFFFC107);
      case BiometricStressLevel.tinggi:
        return const Color(0xFFF44336);
    }
  }

  /// Simpan hasil ke screening history
  void _saveToHistory(StressAnalysisResult result) {
    try {
      ref.read(screeningHistoryProvider.notifier).addRecord(
            score: result.score,
            condition: 'Deteksi Stres Biometrik',
            severity: _getTitle(result.level),
          );
      // ignore: avoid_print
      print('Result saved to history: score=${result.score}, level=${result.level}');
    } catch (e) {
      // ignore: avoid_print
      print('Error saving to history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hasil Deteksi Stres',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: FutureBuilder<StressAnalysisResult>(
        future: _stressAnalysisFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Menganalisis stres Anda...',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tunggu sebentar',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan: ${snapshot.error}',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: Text(
                'Data tidak ditemukan',
                style: GoogleFonts.poppins(),
              ),
            );
          }

          final result = snapshot.data!;
          final title = _getTitle(result.level);
          final color = _getColor(result.level);

          // Simpan ke history saat data tersedia
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _saveToHistory(result);
          });

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Deteksi Biometrik (Wajah)',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Berikut adalah hasil analisis tingkat stres berdasarkan scan wajah yang baru saja Anda lakukan.',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.15),
                        color.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tingkat Stres Anda',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(biometrik)',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Score display
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Skor Stres',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              '${result.score} / 100',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Score range info
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rentang Skor:',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  result.level == BiometricStressLevel.rendah
                                      ? '0 - 35 (Rendah)'
                                      : result.level == BiometricStressLevel.sedang
                                          ? '36 - 70 (Sedang)'
                                          : '71 - 100 (Tinggi)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        result.message,
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Catatan:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fitur ini masih dalam tahap pengembangan. Hasil deteksi biometrik bersifat indikatif dan sebaiknya dikombinasikan dengan penilaian diri atau konsultasi profesional.',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Kembali ke Beranda',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
