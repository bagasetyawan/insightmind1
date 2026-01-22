import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ScreeningRecord {
  final DateTime date;
  final int score;
  final String level;

  ScreeningRecord({
    required this.date,
    required this.score,
    required this.level,
  });

  PdfColor get levelColor {
    if (score < 35) return PdfColor.fromInt(0xFF4CAF50); // Rendah - Green
    if (score < 70) return PdfColor.fromInt(0xFFFF9800); // Sedang - Orange
    return PdfColor.fromInt(0xFFF44336); // Tinggi - Red
  }

  String get condition {
    if (score < 35) return 'Tingkat Stres Rendah';
    if (score < 70) return 'Tingkat Stres Sedang';
    return 'Tingkat Stres Tinggi';
  }
}

class ScreeningPdfService {
  /// Generate PDF document untuk riwayat screening
  static Future<pw.Document> generateScreeningPdf(
    List<ScreeningRecord> records,
  ) async {
    final pdf = pw.Document();

    // Hitung statistik
    final avgScore = records.isEmpty
        ? 0.0
        : records.map((r) => r.score).reduce((a, b) => a + b) / records.length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'LAPORAN RIWAYAT SCREENING',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFF00BCD4),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'InsightMind - Aplikasi Analisis Tingkat Stres',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Dihasilkan:',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(
                    _formatDateSimple(DateTime.now()),
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // Ringkasan Statistik - Simple Table
          pw.Text(
            'RINGKASAN STATISTIK',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(
              color: PdfColors.grey600,
              width: 1,
            ),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Total Screening',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Rata-rata Skor',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Skor Terbaru',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      '${records.length}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      avgScore.toStringAsFixed(1),
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      '${records.isNotEmpty ? records.first.score : 0}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // Detail Screening
          pw.Text(
            'DETAIL SCREENING',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),

          // Table Header and Data
          pw.Table(
            border: pw.TableBorder.all(
              color: PdfColors.grey600,
              width: 1,
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(3),
            },
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF00BCD4),
                ),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'TANGGAL',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'HASIL SCREENING',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ],
              ),
              // Data Rows
              ...records.reversed.map((record) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          _formatDateWithTime(record.date),
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Expanded(
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    record.condition,
                                    style: pw.TextStyle(
                                      fontSize: 10,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.SizedBox(height: 2),
                                  pw.Text(
                                    record.level,
                                    style: pw.TextStyle(
                                      fontSize: 9,
                                      color: record.levelColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                  color: record.levelColor,
                                  width: 1,
                                ),
                              ),
                              child: pw.Text(
                                '${record.score}',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: record.levelColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
            ],
          ),
          pw.SizedBox(height: 20),

          // Footer
          pw.Divider(color: PdfColors.grey600),
          pw.SizedBox(height: 8),
          pw.Text(
            'Dokumen ini dibuat secara otomatis oleh InsightMind.',
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );

    return pdf;
  }

  /// Simpan PDF ke file
  static Future<void> savePdf(
    pw.Document pdf, {
    required String filename,
  }) async {
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: filename,
    );
  }

  /// Print PDF langsung
  static Future<void> printPdf(pw.Document pdf) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  /// Format tanggal sederhana tanpa locale dependency
  static String _formatDateSimple(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Format tanggal dengan waktu
  static String _formatDateWithTime(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
