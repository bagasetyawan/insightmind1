import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'detailed_stats_page.dart';
import 'pdf_preview_page.dart';
import '../../../../providers/screening_history_provider.dart' as global_history;

// Provider untuk menyimpan history screening (tanpa data dummy, diisi saat user melakukan screening)
final screeningHistoryProvider = StateProvider<List<ScreeningRecord>>((ref) => []);

class ScreeningRecord {
  final DateTime date;
  final int score;
  final String level;

  ScreeningRecord({
    required this.date,
    required this.score,
    required this.level,
  });

  Color get levelColor {
    if (score < 35) return const Color(0xFF4CAF50); // Rendah - Green
    if (score < 70) return const Color(0xFFFF9800); // Sedang - Orange
    return const Color(0xFFF44336); // Tinggi - Red
  }

  IconData get levelIcon {
    if (score < 35) return Icons.sentiment_very_satisfied_rounded; // Rendah
    if (score < 70) return Icons.sentiment_neutral_rounded; // Sedang
    return Icons.sentiment_very_dissatisfied_rounded; // Tinggi
  }

  String get condition {
    if (score < 35) return 'Tingkat Stres Rendah';
    if (score < 70) return 'Tingkat Stres Sedang';
    return 'Tingkat Stres Tinggi';
  }
}

// Provider untuk filter periode
final selectedPeriodProvider = StateProvider<String>((ref) => 'Mingguan');

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sinkronkan dengan riwayat global yang disimpan di Firestore
    final globalState = ref.watch(global_history.screeningHistoryProvider);
    
    // Selalu sinkronkan data dari global provider ke local provider
    final mapped = globalState.historyList
        .map(
          (h) => ScreeningRecord(
            date: h.date,
            score: h.score,
            level: h.severity,
          ),
        )
        .toList();
    
    // Update local provider dengan data terbaru dari global
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(screeningHistoryProvider.notifier).state = mapped;
    });
    
    final allHistory = ref.watch(screeningHistoryProvider);
    final selectedPeriod = ref.watch(selectedPeriodProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Filter history berdasarkan periode
    final history = _filterByPeriod(allHistory, selectedPeriod);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar background only
            SliverAppBar(
              expandedHeight: 100,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF00BCD4),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF00BCD4), Color(0xFF03A9F4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'Riwayat Screening',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Filter Period Selector
                    Row(
                      children: [
                        Expanded(
                          child: _buildPeriodFilter(ref, 'Mingguan', selectedPeriod),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPeriodFilter(ref, 'Bulanan', selectedPeriod),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Button ke Statistik Detail
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DetailedStatsPage(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00BCD4), Color(0xFF03A9F4)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00BCD4).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.analytics_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Lihat Statistik Detail',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Statistics Overview
                    Text(
                      'Ringkasan ${selectedPeriod == 'Mingguan' ? '7 Hari' : '30 Hari'} Terakhir',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildStatisticsGrid(context, history),

                    const SizedBox(height: 32),

                    // Score Trend Chart
                    Text(
                      'Grafik Perkembangan Skor',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildScoreChart(context, history),

                    const SizedBox(height: 32),

                    // Download PDF Button
                    if (history.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          // Convert ScreeningRecord ke ScreeningRecordPDF
                          final pdfRecords = history
                              .map((r) => ScreeningRecordPDF(
                                    date: r.date,
                                    score: r.score,
                                    level: r.level,
                                  ))
                              .toList();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PdfPreviewPage(
                                records: pdfRecords,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF00BCD4).withOpacity(0.8),
                                const Color(0xFF03A9F4).withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF00BCD4),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00BCD4).withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.file_download_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Download Riwayat sebagai PDF',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),

                    // History List
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Riwayat Lengkap',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${history.length}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            if (history.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => _showDeleteAllDialog(context, ref, isDark),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.delete_sweep_rounded,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Hapus',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: Colors.red,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (history.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00BCD4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF00BCD4).withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.swipe_left_rounded,
                              color: const Color(0xFF00BCD4),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Geser ke kiri untuk menghapus riwayat',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF00BCD4),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    ...history.asMap().entries.map((entry) {
                      final index = entry.key;
                      final record = entry.value;
                      return _buildHistoryCard(context, ref, record, index);
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid(BuildContext context, List<ScreeningRecord> history) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: isDark ? Colors.grey[600] : Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada data screening',
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final avgScore = history.isEmpty
      ? 0.0
      : history.map((r) => r.score).reduce((a, b) => a + b) / history.length;
    
    final totalScreenings = history.length;
    // Data terbaru disimpan di urutan pertama (newest first),
    // jadi gunakan elemen pertama sebagai "skor terakhir".
    final lastScore = history.isNotEmpty ? history.first.score : 0;
    // Perubahan dibanding screening sebelumnya (jika ada)
    int improvement = 0;
    if (history.length >= 2) {
      try {
        improvement = history.first.score - history[1].score;
      } catch (e) {
        improvement = 0;
      }
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.0,
      children: [
        _buildStatCard(context, 'Rata-rata\nSkor', avgScore.toStringAsFixed(1), Icons.trending_up_rounded, const Color(0xFF00BCD4)),
        _buildStatCard(context, 'Total\nScreening', '$totalScreenings', Icons.assignment_turned_in_rounded, const Color(0xFF2196F3)),
        _buildStatCard(context, 'Skor\nTerakhir', '$lastScore', Icons.assignment_rounded, const Color(0xFFFF9800)),
        _buildStatCard(context, 'Perubahan', improvement > 0 ? '+$improvement' : '$improvement', 
            improvement > 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, 
            improvement > 0 ? const Color(0xFF4CAF50) : const Color(0xFFE91E63)),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF2D2D2D),
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreChart(BuildContext context, List<ScreeningRecord> history) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (history.isEmpty) {
      return Container(
        height: 250,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.insert_chart_outlined,
                size: 64,
                color: isDark ? Colors.grey[600] : Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada data untuk ditampilkan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tren Skor',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${history.length} Data',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00BCD4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: history.map((record) {
                final maxScore = 100.0;
                final height = (record.score / maxScore) * 140;
                final isToday = DateTime.now().day == record.date.day &&
                    DateTime.now().month == record.date.month;
                
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${record.score}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isToday 
                                ? const Color(0xFF00BCD4)
                                : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          height: height,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isToday
                                  ? [
                                      const Color(0xFF00BCD4),
                                      const Color(0xFF03A9F4),
                                    ]
                                  : [
                                      record.levelColor,
                                      record.levelColor.withOpacity(0.7),
                                    ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                            boxShadow: isToday
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF00BCD4).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${record.date.day}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                            color: isToday 
                                ? const Color(0xFF00BCD4)
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, WidgetRef ref, ScreeningRecord record, int index) {
    final dateStr = _formatDate(record.date);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key('${record.date.millisecondsSinceEpoch}_$index'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Hapus Riwayat?',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                    ),
                  ),
                ],
              ),
              content: Text(
                'Apakah Anda yakin ingin menghapus riwayat screening tanggal $dateStr? Tindakan ini tidak dapat dibatalkan.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                  height: 1.5,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    'Hapus',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) async {
        // Hapus berdasarkan kecocokan tanggal+skor agar index selalu valid
        await ref
            .read(global_history.screeningHistoryProvider.notifier)
            .removeScreeningByDateScore(record.date, record.score);
        
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Riwayat berhasil dihapus',
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.red, Color(0xFFE53935)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.delete_rounded,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              'Hapus',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [record.levelColor, record.levelColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: record.levelColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  record.levelIcon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.condition,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      record.level,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: record.levelColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [record.levelColor, record.levelColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${record.score}',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<ScreeningRecord> _filterByPeriod(List<ScreeningRecord> history, String period) {
    final now = DateTime.now();
    final days = period == 'Mingguan' ? 7 : 30;
    
    return history.where((record) {
      return now.difference(record.date).inDays < days;
    }).toList();
  }

  Widget _buildPeriodFilter(WidgetRef ref, String period, String selectedPeriod) {
    final isSelected = period == selectedPeriod;
    
    return GestureDetector(
      onTap: () {
        ref.read(selectedPeriodProvider.notifier).state = period;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF00BCD4), Color(0xFF03A9F4)],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00BCD4).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              period == 'Mingguan' ? Icons.calendar_view_week_rounded : Icons.calendar_month_rounded,
              color: isSelected ? Colors.white : const Color(0xFF00BCD4),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              period,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF2D2D2D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    
    final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    
    final dayName = days[date.weekday % 7];
    final monthName = months[date.month - 1];
    final day = date.day;
    final year = date.year;
    
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    if (diff == 0) {
      return 'Hari ini, $dayName, $day $monthName $year • $hour:$minute';
    } else if (diff == 1) {
      return 'Kemarin, $dayName, $day $monthName $year • $hour:$minute';
    } else {
      return '$dayName, $day $monthName $year • $hour:$minute';
    }
  }

  void _showDeleteAllDialog(BuildContext context, WidgetRef ref, bool isDark) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Hapus Semua Riwayat?',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus SEMUA riwayat screening? Semua data statistik dan grafik akan hilang. Tindakan ini tidak dapat dibatalkan.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Pop dialog terlebih dahulu
                Navigator.of(dialogContext).pop();
                
                // Lakukan deletion operation setelah dialog tertutup
                await Future.delayed(const Duration(milliseconds: 300));
                
                // Hapus semua riwayat (lokal dan Firestore)
                await ref.read(global_history.screeningHistoryProvider.notifier).clearAll();
                // Hapus dari state lokal juga
                ref.read(screeningHistoryProvider.notifier).state = [];
                
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(
                          'Semua riwayat berhasil dihapus',
                          style: GoogleFonts.poppins(),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Hapus Semua',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
