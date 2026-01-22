import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/question.dart';
import 'result_page.dart';
import 'history_page.dart';
//CLAS CONTAINER//
class ScreeningPage extends ConsumerStatefulWidget {
  const ScreeningPage({super.key});

  @override
  ConsumerState<ScreeningPage> createState() => _ScreeningPageState();
}

class _ScreeningPageState extends ConsumerState<ScreeningPage> {
  final Map<String, int> answers = {};
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextQuestion() {
    if (_currentPage < defaultQuestions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousQuestion() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  double get _progress => (answers.length / defaultQuestions.length);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5FBFC),
      appBar: AppBar(
        title: Text(
          'Screening Kesehatan Mental',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF2D2D2D),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00BCD4)),
            minHeight: 6,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pertanyaan ${_currentPage + 1} dari ${defaultQuestions.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BCD4).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${((_progress) * 100).toInt()}%',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF00BCD4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${answers.length} dari ${defaultQuestions.length} pertanyaan terjawab',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          // Questions PageView HAHAYYYY///
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: defaultQuestions.length,
              itemBuilder: (context, index) {
                final question = defaultQuestions[index];
                final selectedScore = answers[question.id];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00BCD4), Color(0xFF03A9F4)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00BCD4).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Q${index + 1}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              question.text,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Options
                      Text(
                        'Pilih jawaban yang paling sesuai:',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 16),

                      ...question.options.map((option) {
                        final isSelected = selectedScore == option.score;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                answers[question.id] = option.score;
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF00BCD4)
                                    : (isDark ? const Color(0xFF2D2D2D) : Colors.white),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF00BCD4)
                                      : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
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
                                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                              ),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey[400]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Color(0xFF00BCD4),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      option.label,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark ? Colors.grey[300] : const Color(0xFF2D2D2D)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Previous Button
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _previousQuestion,
                      icon: const Icon(Icons.arrow_back),
                      label: Text(
                        'Sebelumnya',
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

                if (_currentPage > 0) const SizedBox(width: 12),

                // Next/Submit Buttonuvjguvvhghhjvjhvggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg
                Expanded(
                  flex: _currentPage > 0 ? 1 : 1,
                  child: ElevatedButton.icon(
                    onPressed: _currentPage < defaultQuestions.length - 1
                        ? (answers.containsKey(defaultQuestions[_currentPage].id)
                            ? _nextQuestion
                            : null)
                        : (answers.length == defaultQuestions.length
                            ? () {
                                final totalScore = answers.values.fold<int>(0, (a, b) => a + b);
                                // Konversi dari 0-27 (9 questions × 3 max) ke 0-100
                                final normalizedScore = ((totalScore / 27) * 100).toInt();
                                
                                // Simpan ke historyzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
                                final history = ref.read(screeningHistoryProvider);
                                String level;
                                if (normalizedScore < 35) {
                                  level = 'Rendah';
                                } else if (normalizedScore < 70) {
                                  level = 'Sedang';
                                } else {
                                  level = 'Tinggi';
                                }
                                
                                final newRecord = ScreeningRecord(
                                  date: DateTime.now(),
                                  score: normalizedScore,
                                  level: level,
                                );

                                // Simpan dengan urutan terbaru di depan,
                                // agar konsisten dengan provider global & History.HISTORYYYY///
                                ref.read(screeningHistoryProvider.notifier).state = [
                                  newRecord,
                                  ...history,
                                ];
                                
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ResultPage(score: normalizedScore),
                                  ),
                                );
                              }
                            : null),
                    icon: Icon(
                      _currentPage < defaultQuestions.length - 1
                          ? Icons.arrow_forward
                          : Icons.assessment_rounded,
                    ),
                    label: Text(
                      _currentPage < defaultQuestions.length - 1
                          ? 'Selanjutnya'
                          : 'Lihat Hasil',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BCD4),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[500],
                    ),
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
