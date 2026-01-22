import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';
import '../../../../providers/screening_history_provider.dart';

class ResultPage extends ConsumerStatefulWidget {
  final int score;
  const ResultPage({super.key, required this.score});

  @override
  ConsumerState<ResultPage> createState() => _ResultPageState();
}
//RAZIF//
class _ResultPageState extends ConsumerState<ResultPage> {
  @override
  void initState() {
    super.initState();
    // Save screening result when page is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prediction = getMentalHealthPrediction(widget.score);
      ref.read(screeningHistoryProvider.notifier).addScreeningAndPersist(
            ScreeningHistory(
              date: DateTime.now(),
              score: widget.score,
              condition: prediction['condition'] as String,
              severity: prediction['level'] as String,
            ),
          );
    });
  }

  Map<String, dynamic> getMentalHealthPrediction(int score) {
    // Score range: 0-100
    if (score >= 71) {
      return {
        'level': 'Tinggi',
        'condition': 'Tingkat Stres Tinggi',
        'icon': Icons.warning_amber_rounded,
        'color': const Color(0xFFF44336),
        'bgColor': const Color(0xFFFFEBEE),
        'description': 'Anda mengalami tingkat stres yang tinggi yang memerlukan perhatian serius.',
        'recommendation': [
          'Segera konsultasi dengan profesional kesehatan mental',
          'Hubungi hotline kesehatan mental: 119 ext 8',
          'Jangan ragu untuk meminta bantuan dari orang terdekat',
          'Pertimbangkan untuk mendapatkan terapi profesional',
        ],
      };
    } else if (score >= 36) {
      return {
        'level': 'Sedang',
        'condition': 'Tingkat Stres Sedang',
        'icon': Icons.priority_high_rounded,
        'color': const Color(0xFFFF9800),
        'bgColor': const Color(0xFFFFF3E0),
        'description': 'Anda mengalami tingkat stres yang sedang. Ada beberapa gejala yang perlu diperhatikan.',
        'recommendation': [
          'Pertimbangkan konseling atau terapi ringan',
          'Tingkatkan aktivitas fisik secara rutin',
          'Praktikkan manajemen stres dan relaksasi',
          'Luangkan waktu untuk hobi dan istirahat',
        ],
      };
    } else {
      return {
        'level': 'Rendah',
        'condition': 'Tingkat Stres Rendah',
        'icon': Icons.check_circle_outline_rounded,
        'color': const Color(0xFF4CAF50),
        'bgColor': const Color(0xFFF1F8E9),
        'description': 'Tingkat stres Anda rendah. Kesehatan mental dalam kondisi baik. Pertahankan pola hidup sehat!',
        'recommendation': [
          'Pertahankan kebiasaan positif Anda',
          'Tetap jaga pola tidur yang cukup',
          'Lakukan aktivitas yang Anda nikmati',
          'Bangun dan pertahankan hubungan sosial yang sehat',
        ],
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final prediction = getMentalHealthPrediction(widget.score);
    final maxScore = 100; // Skor maksimal dari screening (0-100)
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Hasil Screening',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF2D2D2D),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Score Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    prediction['color'] as Color,
                    (prediction['color'] as Color).withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (prediction['color'] as Color).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      prediction['icon'] as IconData,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Skor Anda',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${widget.score}',
                        style: GoogleFonts.poppins(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 4),
                        child: Text(
                          '/ $maxScore',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      prediction['level'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Condition Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D2D2D) : (prediction['bgColor'] as Color),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (prediction['color'] as Color).withOpacity(isDark ? 0.4 : 0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.psychology_outlined,
                        color: prediction['color'] as Color,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Prediksi Kondisi',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    prediction['condition'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: prediction['color'] as Color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    prediction['description'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDark ? Colors.grey[300] : const Color(0xFF5D5D5D),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Recommendations Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        color: prediction['color'] as Color,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Rekomendasi',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...(prediction['recommendation'] as List<String>).map(
                    (rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: prediction['color'] as Color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              rec,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: isDark ? Colors.grey[300] : Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.amber.withOpacity(0.15) 
                    : Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.withOpacity(isDark ? 0.4 : 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.amber[700],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Hasil ini bersifat edukatif dan bukan diagnosis medis. Konsultasikan dengan profesional untuk evaluasi lebih lanjut.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark ? Colors.amber[300] : Colors.amber[900],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(
                      'Ulangi',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00BCD4),
                      side: const BorderSide(color: Color(0xFF00BCD4), width: 2),
                      minimumSize: const Size(0, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.home_rounded),
                    label: Text(
                      'Beranda',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BCD4),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
