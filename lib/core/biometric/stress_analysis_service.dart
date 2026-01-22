import 'dart:io';
import 'dart:math';
import 'package:insightmind_app/core/biometric/stress_api_service.dart';

/// Result dari stress analysis yang berisi level dan score
class StressAnalysisResult {
  final BiometricStressLevel level;
  final int score; // 0-100
  final String message;

  StressAnalysisResult({
    required this.level,
    required this.score,
    required this.message,
  });
}

/// Service untuk analisis tingkat stres (mock atau API)
class StressAnalysisService {
  static final StressAnalysisService _instance =
      StressAnalysisService._internal();

  factory StressAnalysisService() {
    return _instance;
  }

  StressAnalysisService._internal();

  /// Analisis tingkat stres dengan file gambar.
  ///
  /// Return StressAnalysisResult yang berisi level dan score.
  Future<StressAnalysisResult> analyzeStress({File? imageFile}) async {
    // ignore: avoid_print
    print('=== Starting Stress Analysis ===');

    if (imageFile != null && imageFile.existsSync()) {
      // ignore: avoid_print
      print('Image file found: ${imageFile.path}');
    } else {
      // ignore: avoid_print
      print('No image file provided');
    }

    // Simulasi delay processing (1-2 detik) untuk terasa seperti API
    await Future.delayed(
      Duration(milliseconds: 1000 + Random().nextInt(1000)),
    );

    // Selalu gunakan mock dengan random distribution
    final result = _generateMockResult();
    // ignore: avoid_print
    print('Generated result: level=${result.level}, score=${result.score}');
    // ignore: avoid_print
    print('=== Stress Analysis Complete ===');
    return result;
  }

  /// Generate mock result dengan score dan level
  static StressAnalysisResult _generateMockResult() {
    final seed = DateTime.now().microsecond;
    final random = Random(seed).nextDouble();

    BiometricStressLevel level;
    int score;
    String message;

    if (random < 0.3) {
      // Rendah: 0-35
      level = BiometricStressLevel.rendah;
      score = (random * 100 * 0.35).toInt();
      message = 'Tingkat stres Anda rendah. Pertahankan gaya hidup sehat! ✓';
    } else if (random < 0.7) {
      // Sedang: 36-70
      level = BiometricStressLevel.sedang;
      score = (35 + (random - 0.3) * 100 * 0.35 / 0.4).toInt();
      message = 'Tingkat stres Anda sedang. Coba istirahat dan relaksasi.';
    } else {
      // Tinggi: 71-100
      level = BiometricStressLevel.tinggi;
      score = (70 + (random - 0.7) * 100 * 0.3 / 0.3).toInt();
      message =
          'Tingkat stres Anda tinggi. Pertimbangkan konsultasi profesional.';
    }

    score = score.clamp(0, 100);

    // ignore: avoid_print
    print(
        'Mock: seed=$seed, random=${random.toStringAsFixed(3)}, level=$level, score=$score');

    return StressAnalysisResult(
      level: level,
      score: score,
      message: message,
    );
  }
}

