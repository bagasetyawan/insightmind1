import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;

/// Enum untuk tingkat stres biometrik
enum BiometricStressLevel {
  rendah,
  sedang,
  tinggi,
}
class ApiConfig {
  /// URL backend untuk analisis stres (sesuaikan dengan endpoint Anda)
  static const String baseUrl = 'https://api.example.com';
  
  /// Endpoint untuk analisis wajah/stres
  static const String analyzeStressEndpoint = '/api/analyze-stress';
  
  /// Endpoint lengkap
  static String get analyzeStressUrl => '$baseUrl$analyzeStressEndpoint';
  
  /// Timeout untuk request
  static const Duration requestTimeout = Duration(seconds: 30);
}

/// Model untuk response API
class StressAnalysisResponse {
  final String stressLevel; // 'rendah', 'sedang', 'tinggi'
  final int score; // 0-100
  final double confidence; // 0.0 - 1.0
  final String message;
  final Map<String, dynamic>? metadata;

  StressAnalysisResponse({
    required this.stressLevel,
    required this.score,
    required this.confidence,
    required this.message,
    this.metadata,
  });

  factory StressAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return StressAnalysisResponse(
      stressLevel: json['stress_level'] ?? 'sedang',
      score: json['score'] ?? 50,
      confidence: (json['confidence'] ?? 0.5).toDouble(),
      message: json['message'] ?? '',
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Service untuk memanggil API stress analysis
class StressApiService {
  static final StressApiService _instance = StressApiService._internal();

  factory StressApiService() {
    return _instance;
  }

  StressApiService._internal();

  /// Analisis stres dengan mengirim foto wajah ke API
  /// 
  /// [imageFile] - File gambar wajah yang akan dianalisis
  /// Returns: Response dari API berisi hasil analisis stres
  Future<StressAnalysisResponse?> analyzeStressWithImage(File? imageFile) async {
    try {
      // Jika tidak ada file, return null (fallback ke mock)
      if (imageFile == null) {
        // ignore: avoid_print
        print('No image file provided, will use mock data');
        return null;
      }

      // Log untuk debug
      // ignore: avoid_print
      print('Uploading image to: ${ApiConfig.analyzeStressUrl}');

      // Simulasi delay processing (1-2 detik) untuk terasa lebih realistis
      await Future.delayed(
        Duration(milliseconds: 1000 + Random().nextInt(1000)),
      );

      // Cek koneksi jaringan (simulasi atau real)
      try {
        final result = await http.head(
          Uri.parse(ApiConfig.baseUrl),
        ).timeout(const Duration(seconds: 5));

        if (result.statusCode != 200) {
          // ignore: avoid_print
          print('API server not responding, using mock');
          return _generateMockResponse();
        }
      } catch (e) {
        // ignore: avoid_print
        print('Network check failed, using mock: $e');
        return _generateMockResponse();
      }

      // Buat multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.analyzeStressUrl),
      );

      // Tambahkan file foto
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

      // Kirim request dengan timeout
      final streamResponse = await request.send().timeout(
            ApiConfig.requestTimeout,
            onTimeout: () {
              // ignore: avoid_print
              print('API request timeout, using mock');
              throw TimeoutException('Request timeout');
            },
          );

      final response = await http.Response.fromStream(streamResponse);

      // ignore: avoid_print
      print('API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        // ignore: avoid_print
        print('API Response: $json');
        return StressAnalysisResponse.fromJson(json);
      } else {
        // ignore: avoid_print
        print('API Error: ${response.statusCode}, using mock');
        return _generateMockResponse();
      }
    } on TimeoutException catch (e) {
      // ignore: avoid_print
      print('Timeout exception: $e');
      return _generateMockResponse();
    } catch (e) {
      // ignore: avoid_print
      print('API Exception: $e, using mock');
      return _generateMockResponse();
    }
  }

  /// Generate mock response dengan random distribution dan score
  /// Rendah: 0-35, Sedang: 36-70, Tinggi: 71-100
  static StressAnalysisResponse _generateMockResponse() {
    final now = DateTime.now();
    final seed = now.millisecond + now.second * 1000;
    final random = Random(seed).nextDouble();
    
    String level;
    int score;
    String message;
    
    if (random < 0.3) {
      // Rendah: 0-35
      level = 'rendah';
      score = (random * 100 * 0.35).toInt();
      message = 'Tingkat stres Anda rendah. Pertahankan gaya hidup sehat! ✓';
    } else if (random < 0.7) {
      // Sedang: 36-70
      level = 'sedang';
      score = (35 + (random - 0.3) * 100 * 0.35 / 0.4).toInt();
      message = 'Tingkat stres Anda sedang. Coba istirahat dan relaksasi.';
    } else {
      // Tinggi: 71-100
      level = 'tinggi';
      score = (70 + (random - 0.7) * 100 * 0.3 / 0.3).toInt();
      message = 'Tingkat stres Anda tinggi. Pertimbangkan konsultasi profesional.';
    }
    
    score = score.clamp(0, 100);
    
    // ignore: avoid_print
    print('=== MOCK GENERATION ===');
    // ignore: avoid_print
    print('Random value: ${random.toStringAsFixed(3)}');
    // ignore: avoid_print
    print('Generated level: $level');
    // ignore: avoid_print
    print('Generated score: $score');
    // ignore: avoid_print
    print('========================');
    
    return StressAnalysisResponse(
      stressLevel: level,
      score: score,
      confidence: 0.7 + Random().nextDouble() * 0.25,
      message: message,
      metadata: {
        'source': 'mock',
        'timestamp': now.toIso8601String(),
        'random_value': random,
      },
    );
  }

  /// Analisis stres dengan data gambar base64
  /// 
  /// [imageBase64] - Gambar dalam format base64
  /// Returns: Response dari API
  Future<StressAnalysisResponse?> analyzeStressWithBase64(
    String imageBase64,
  ) async {
    try {
      // ignore: avoid_print
      print('Uploading base64 image to: ${ApiConfig.analyzeStressUrl}');

      final response = await http.post(
        Uri.parse(ApiConfig.analyzeStressUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'image': imageBase64,
          'format': 'base64',
        }),
      ).timeout(
        ApiConfig.requestTimeout,
        onTimeout: () {
          // ignore: avoid_print
          print('API request timeout');
          throw TimeoutException('Request timeout');
        },
      );

      // ignore: avoid_print
      print('API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return StressAnalysisResponse.fromJson(json);
      } else {
        // ignore: avoid_print
        print('API Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Base64 API Exception: $e');
      return null;
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}
