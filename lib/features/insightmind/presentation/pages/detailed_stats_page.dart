import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'history_page.dart';
import '../../../../providers/screening_history_provider.dart' as global_history;
import 'home_page.dart' show DoctorListPage;

// Helper functions
Map<String, dynamic> _calculateStats(List<ScreeningRecord> history) {
  if (history.isEmpty) {
    return {
      'average': 0.0,
      'highest': 0,
      'lowest': 0,
      'total': 0,
      'improvement': 0,
      'trend': 'stable',
      'normalCount': 0,
      'ringanCount': 0,
      'beratCount': 0,
    };
  }

  final scores = history.map((r) => r.score).toList();
  final average = scores.reduce((a, b) => a + b) / scores.length;
  final highest = scores.reduce((a, b) => a > b ? a : b);
  final lowest = scores.reduce((a, b) => a < b ? a : b);
  
  // Hitung improvement
  int improvement = 0;
  if (history.length >= 2) {
    // Ambil paling banyak 3 data terbaru untuk dibandingkan dengan sisanya.
    final recentCount = history.length >= 3 ? 3 : history.length;
    final recent = history.sublist(history.length - recentCount);
    final recentAvg = recent.map((r) => r.score).reduce((a, b) => a + b) / recent.length;

    final older = history.sublist(0, history.length - recentCount);
    if (older.isNotEmpty) {
      final olderAvg = older.map((r) => r.score).reduce((a, b) => a + b) / older.length;
      improvement = (olderAvg - recentAvg).round();
    }
  }
  
  // Tentukan trend
  String trend = 'stable';
  if (improvement > 3) {
    trend = 'improving';
  } else if (improvement < -3) {
    trend = 'declining';
  }
  
  // Hitung distribusi level (gunakan skala 0-100 yang sudah dinormalisasi)
  int normalCount = history.where((r) => r.score < 35).length;          // Rendah
  int ringanCount = history.where((r) => r.score >= 35 && r.score < 70).length;  // Sedang
  int beratCount = history.where((r) => r.score >= 70).length;          // Tinggi

  return {
    'average': average,
    'highest': highest,
    'lowest': lowest,
    'total': history.length,
    'improvement': improvement,
    'trend': trend,
    'normalCount': normalCount,
    'ringanCount': ringanCount,
    'beratCount': beratCount,
  };
}

class DetailedStatsPage extends ConsumerWidget {
  const DetailedStatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Utamakan data lokal HistoryPage, namun fallback ke riwayat global
    // (yang juga memuat data dari Firestore) jika lokal masih kosong.
    var history = ref.watch(screeningHistoryProvider);
    if (history.isEmpty) {
      final globalState = ref.watch(global_history.screeningHistoryProvider);
      if (globalState.historyList.isNotEmpty) {
        history = globalState.historyList
            .map(
              (h) => ScreeningRecord(
                date: h.date,
                score: h.score,
                level: h.severity,
              ),
            )
            .toList();
      }
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? Colors.white : const Color(0xFF2D2D2D);
    final secondaryText = isDark ? Colors.white70 : Colors.grey[600];
    final bgGradient = isDark
      ? const [Color(0xFF121212), Color(0xFF1E1E1E)]
      : const [Color(0xFFE0F7FA), Color(0xFFFDFEFF)];
    
    // Kalkulasi statistik
    final stats = _calculateStats(history);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? const [Color(0xFF1F4D5F), Color(0xFF0D3B4C)]
                  : const [Color(0xFF00D4E8), Color(0xFF0097A7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Statistik Detail',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: bgGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 110,
                        width: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF23D5E3), Color(0xFF29ABE2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.insert_chart_outlined, color: Colors.white, size: 48),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Belum ada data screening',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Mulai screening untuk melihat statistik',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroHeader(context, stats, isDark),
                      const SizedBox(height: 24),
                      _buildOverviewSection(context, stats, isDark, primaryText, secondaryText),
                      const SizedBox(height: 24),
                      _buildTrendSection(context, history, stats, isDark, primaryText, secondaryText),
                      const SizedBox(height: 24),
                      _buildDistributionSection(context, history, isDark, primaryText, secondaryText),
                      const SizedBox(height: 24),
                      _buildBestWorstSection(context, history, isDark, primaryText, secondaryText),
                      const SizedBox(height: 24),
                      _buildRecommendationsSection(context, stats, isDark, primaryText, secondaryText),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, Map<String, dynamic> stats, bool isDark) {
    final trend = stats['trend'];
    final accent = trend == 'improving'
        ? const Color(0xFF00E676)
        : trend == 'declining'
            ? const Color(0xFFFF7043)
            : const Color(0xFF29ABE2);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                colors: [accent.withOpacity(0.18), Colors.white.withOpacity(0.06)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [const Color(0xFF00D4E8), const Color(0xFF0097A7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withOpacity(isDark ? 0.35 : 0.18), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: (isDark ? accent : const Color(0xFF00BCD4)).withOpacity(isDark ? 0.2 : 0.26),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 86,
            width: 86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [accent, accent.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.45),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Text(
                stats['average'].toStringAsFixed(1),
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kesehatan Mental Anda',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  trend == 'improving'
                      ? 'Trend membaik, lanjutkan kebiasaan baik.'
                      : trend == 'declining'
                          ? 'Perhatikan gejala, coba kurangi stres.'
                          : 'Stabil, pertahankan ritme yang nyaman.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildTagChip('Total Tes ${stats['total']}', Icons.timeline, accent),
                    _buildTagChip('Tertinggi ${stats['highest']}', Icons.arrow_outward_rounded, accent),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(BuildContext context, Map<String, dynamic> stats, bool isDark, Color primaryText, Color? secondaryText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Ringkasan Umum',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: primaryText,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: (isDark ? Colors.white : const Color(0xFF00BCD4)).withOpacity(0.15)),
              ),
              child: Text(
                'Realtime insight',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? secondaryText : const Color(0xFF0097A7),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 26,
              child: _buildStatCard(
                'Rata-rata',
                stats['average'].toStringAsFixed(1),
                Icons.analytics_rounded,
                const Color(0xFF23D5E3),
                isDark,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 26,
              child: _buildStatCard(
                'Total Tes',
                '${stats['total']}',
                Icons.assignment_turned_in_rounded,
                const Color(0xFF7C6FF6),
                isDark,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 26,
              child: _buildStatCard(
                'Tertinggi',
                '${stats['highest']}',
                Icons.arrow_upward_rounded,
                const Color(0xFFFFA726),
                isDark,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 26,
              child: _buildStatCard(
                'Terendah',
                '${stats['lowest']}',
                Icons.arrow_downward_rounded,
                const Color(0xFF66BB6A),
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                colors: [color.withOpacity(0.18), Colors.white.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.white, const Color(0xFFF7FCFD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(isDark ? 0.35 : 0.18), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : color).withOpacity(isDark ? 0.25 : 0.12),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.white.withOpacity(0.12) : color.withOpacity(0.16),
            ),
            child: Icon(icon, color: isDark ? Colors.white : color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendSection(BuildContext context, List<ScreeningRecord> history, Map<String, dynamic> stats, bool isDark, Color primaryText, Color? secondaryText) {
    final trend = stats['trend'];
    final improvement = stats['improvement'];
    
    IconData trendIcon;
    Color trendColor;
    String trendText;
    
    if (trend == 'improving') {
      trendIcon = Icons.trending_up_rounded;
      trendColor = const Color(0xFF4CAF50);
      trendText = 'Kondisi membaik';
    } else if (trend == 'declining') {
      trendIcon = Icons.trending_down_rounded;
      trendColor = const Color(0xFFFF5722);
      trendText = 'Perlu perhatian';
    } else {
      trendIcon = Icons.trending_flat_rounded;
      trendColor = const Color(0xFF2196F3);
      trendText = 'Kondisi stabil';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                colors: [trendColor.withOpacity(0.32), trendColor.withOpacity(0.14)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.white, Colors.white.withOpacity(0.94)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: trendColor.withOpacity(isDark ? 0.45 : 0.22), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: trendColor.withOpacity(isDark ? 0.35 : 0.15),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.white.withOpacity(0.18) : trendColor.withOpacity(0.12),
            ),
            child: Icon(trendIcon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trendText,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : primaryText,
                  ),
                ),
                if (improvement != 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      improvement > 0
                          ? 'Perbaikan ${improvement.abs()} poin'
                          : 'Penurunan ${improvement.abs()} poin',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : secondaryText,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: improvement.abs() / 20.0 > 1 ? 1 : improvement.abs() / 20.0,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.18),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionSection(BuildContext context, List<ScreeningRecord> history, bool isDark, Color primaryText, Color? secondaryText) {
    final total = history.length;
    final normalCount = history.where((r) => r.score < 35).length;           // Rendah
    final ringanCount = history.where((r) => r.score >= 35 && r.score < 70).length;  // Sedang
    final beratCount = history.where((r) => r.score >= 70).length;           // Tinggi

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distribusi Kondisi',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: primaryText,
          ),
        ),
        const SizedBox(height: 16),
        _buildDistributionBar('Rendah (0-34)', normalCount, total, const Color(0xFF4CAF50), isDark, primaryText, secondaryText),
        const SizedBox(height: 12),
        _buildDistributionBar('Sedang (35-70)', ringanCount, total, const Color(0xFFFF9800), isDark, primaryText, secondaryText),
        const SizedBox(height: 12),
        _buildDistributionBar('Tinggi (71-100)', beratCount, total, const Color(0xFFF44336), isDark, primaryText, secondaryText),
      ],
    );
  }

  Widget _buildDistributionBar(String label, int count, int total, Color color, bool isDark, Color primaryText, Color? secondaryText) {
    final percentage = total > 0 ? (count / total * 100) : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: primaryText,
                ),
              ),
              Text(
                '$count kali (${percentage.toStringAsFixed(1)}%)',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 12,
              backgroundColor: isDark ? Colors.white.withOpacity(0.15) : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestWorstSection(BuildContext context, List<ScreeningRecord> history, bool isDark, Color primaryText, Color? secondaryText) {
    final sorted = List<ScreeningRecord>.from(history)
      ..sort((a, b) => a.score.compareTo(b.score));
    
    final best = sorted.first;
    final worst = sorted.last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hari Terbaik & Terburuk',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: primaryText,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDayCard(
                'Terbaik',
                best,
                Icons.sentiment_very_satisfied_rounded,
                const Color(0xFF4CAF50),
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDayCard(
                'Perlu Perbaikan',
                worst,
                Icons.sentiment_dissatisfied_rounded,
                const Color(0xFFFF5722),
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDayCard(String title, ScreeningRecord record, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                colors: [color.withOpacity(0.28), Colors.white.withOpacity(0.06)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.white, const Color(0xFFF8FBFC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(isDark ? 0.5 : 0.2), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.35 : 0.14),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: isDark ? Colors.white : color, size: 32),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${record.score}',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(record.date),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(BuildContext context, Map<String, dynamic> stats, bool isDark, Color primaryText, Color? secondaryText) {
    final trend = stats['trend'];
    
    final List<Map<String, dynamic>> recommendations = [];

    // Selalu tampilkan opsi konsultasi profesional terlebih dahulu
    recommendations.add({
      'icon': Icons.local_hospital_rounded,
      'title': 'Konsultasi Profesional',
      'desc': 'Pilih dokter/psikolog untuk konsultasi sesuai kebutuhan Anda',
      'type': 'doctor',
    });

    if (trend == 'declining') {
      recommendations.add({
        'icon': Icons.self_improvement_rounded,
        'title': 'Tingkatkan Self-Care',
        'desc': 'Luangkan lebih banyak waktu untuk merawat diri sendiri',
        'type': 'tip',
      });
    }
    
    recommendations.add({
      'icon': Icons.spa_rounded,
      'title': 'Mindfulness & Meditasi',
      'desc': 'Praktikkan mindfulness 10-15 menit setiap hari',
      'type': 'mind',
    });
    
    recommendations.add({
      'icon': Icons.fitness_center_rounded,
      'title': 'Olahraga Teratur',
      'desc': 'Minimal 30 menit aktivitas fisik, 3-4 kali seminggu',
      'type': 'exercise',
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rekomendasi untuk Anda',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Aksi singkat yang bisa langsung dijalankan',
                  style: GoogleFonts.poppins(fontSize: 12, color: secondaryText),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: (isDark ? Colors.white : const Color(0xFF00BCD4)).withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.touch_app_rounded, size: 16, color: Colors.white70),
                  const SizedBox(width: 6),
                  Text('Tap untuk aksi', style: GoogleFonts.poppins(fontSize: 11, color: secondaryText)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...recommendations.map((rec) => _buildRecommendationCard(
          context,
          rec,
          isDark,
        )).toList(),
      ],
    );
  }

  Widget _buildRecommendationCard(BuildContext context, Map<String, dynamic> rec, bool isDark) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (rec['type'] == 'doctor') {
          _openDoctorListPage(context);
        } else if (rec['type'] == 'mind' || rec['type'] == 'exercise') {
          if (rec['type'] == 'mind') {
            _showMeditationSheet(context);
          } else {
            _showExerciseSheet(context);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Rekomendasi: ${rec['title']}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF1F8FE5), Color(0xFF23D5E3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Colors.white, Color(0xFFF7FCFD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.25) : const Color(0xFF00BCD4).withOpacity(0.24),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : const Color(0xFF00BCD4)).withOpacity(isDark ? 0.25 : 0.14),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.white.withOpacity(0.18) : const Color(0xFF00BCD4).withOpacity(0.18),
              ),
              child: Icon(rec['icon'], color: isDark ? Colors.white : const Color(0xFF0097A7), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rec['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rec['desc'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : const Color(0xFF4A4A4A),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white : const Color(0xFF2D2D2D), size: 22),
          ],
        ),
      ),
    );
  }

  void _openDoctorListPage(BuildContext context) {
    final doctors = [
      {
        'name': 'Dr. Andini, Sp.KJ',
        'spec': 'Psikiater',
        'loc': 'RS Sehat Jiwa',
        'contact': '08xx-xxxx-1001',
      },
      {
        'name': 'dr. Raka, M.Psi',
        'spec': 'Psikolog Klinis',
        'loc': 'Klinik Bahagia',
        'contact': '08xx-xxxx-2002',
      },
      {
        'name': 'Dr. Lestari, Sp.KJ',
        'spec': 'Psikiater',
        'loc': 'RS Sentosa',
        'contact': '08xx-xxxx-3003',
      },
    ];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DoctorListPage(doctors: doctors),
      ),
    );
  }

  void _showMeditationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rekomendasi Meditasi', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.timelapse_rounded, color: Color(0xFF23D5E3)),
                title: Text('Meditasi Napas 10 menit', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                subtitle: Text('Fokus pada napas, hitung 1-10 berulang', style: GoogleFonts.poppins(fontSize: 12)),
              ),
              ListTile(
                leading: const Icon(Icons.self_improvement_rounded, color: Color(0xFF23D5E3)),
                title: Text('Body Scan', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                subtitle: Text('Tarik napas pelan sambil memindai tubuh dari kepala ke kaki', style: GoogleFonts.poppins(fontSize: 12)),
              ),
              ListTile(
                leading: const Icon(Icons.nightlight_round, color: Color(0xFF23D5E3)),
                title: Text('Wind-down sebelum tidur', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                subtitle: Text('5 menit pernapasan 4-7-8 untuk relaksasi', style: GoogleFonts.poppins(fontSize: 12)),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('Tutup', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showExerciseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rekomendasi Olahraga', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.directions_walk_rounded, color: Color(0xFF23D5E3)),
                title: Text('Jalan cepat 30 menit', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                subtitle: Text('3-4 kali seminggu, pagi atau sore', style: GoogleFonts.poppins(fontSize: 12)),
              ),
              ListTile(
                leading: const Icon(Icons.directions_bike_rounded, color: Color(0xFF23D5E3)),
                title: Text('Bersepeda ringan 20-30 menit', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                subtitle: Text('Pilih rute datar untuk menjaga ritme', style: GoogleFonts.poppins(fontSize: 12)),
              ),
              ListTile(
                leading: const Icon(Icons.sports_gymnastics_rounded, color: Color(0xFF23D5E3)),
                title: Text('Latihan peregangan 10 menit', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                subtitle: Text('Lakukan sebelum/ setelah kerja untuk meredakan tegang', style: GoogleFonts.poppins(fontSize: 12)),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('Tutup', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]}';
  }

