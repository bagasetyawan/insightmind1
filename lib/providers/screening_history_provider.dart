import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

// Model untuk screening history
class ScreeningHistory {
  final DateTime date;
  final int score;
  final String condition;
  final String severity;

  ScreeningHistory({
    required this.date,
    required this.score,
    required this.condition,
    required this.severity,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'score': score,
    'condition': condition,
    'severity': severity,
  };

  factory ScreeningHistory.fromJson(Map<String, dynamic> json) => ScreeningHistory(
    date: DateTime.parse(json['date']),
    score: json['score'],
    condition: json['condition'],
    severity: json['severity'],
  );
}

// State untuk menyimpan list history
class ScreeningHistoryState {
  final List<ScreeningHistory> historyList;

  ScreeningHistoryState({this.historyList = const []});

  ScreeningHistoryState copyWith({List<ScreeningHistory>? historyList}) {
    return ScreeningHistoryState(
      historyList: historyList ?? this.historyList,
    );
  }

  // Get total screening count
  int get totalScreenings => historyList.length;

  // Get latest score
  int? get latestScore => historyList.isEmpty ? null : historyList.first.score;

  // Get latest screening
  ScreeningHistory? get latestScreening => historyList.isEmpty ? null : historyList.first;
}

// Notifier untuk manage history
class ScreeningHistoryNotifier extends StateNotifier<ScreeningHistoryState> {
  ScreeningHistoryNotifier() : super(ScreeningHistoryState());

  void addScreening(ScreeningHistory screening) {
    final updatedList = [screening, ...state.historyList];
    state = state.copyWith(historyList: updatedList);
  }

  /// Tambah record screening baru dengan parameter score, condition, severity
  /// Ini adalah convenience method yang langsung membuat ScreeningHistory dan persist
  Future<void> addRecord({
    required int score,
    required String condition,
    required String severity,
  }) async {
    final screening = ScreeningHistory(
      date: DateTime.now(),
      score: score,
      condition: condition,
      severity: severity,
    );
    await addScreeningAndPersist(screening);
  }

  /// Tambah screening baru dan simpan ke Firestore untuk user yang sedang login
  Future<void> addScreeningAndPersist(ScreeningHistory screening) async {
    // Update state lokal terlebih dahulu
    addScreening(screening);

    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Jika belum login, hanya simpan lokal (tidak ke Firestore)
      return;
    }

    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('screenings')
          .doc();

      await docRef.set(screening.toJson());
    } catch (_) {
      // Untuk saat ini, abaikan error jaringan dan tetap gunakan data lokal
    }
  }

  /// Hapus screening pada index tertentu dan hapus dari Firestore
  Future<void> removeScreening(int index) async {
    // Validasi index
    if (index < 0 || index >= state.historyList.length) {
      return; // Index tidak valid, skip
    }
    
    final screening = state.historyList[index];
    
    // Update state lokal
    final updatedList = List<ScreeningHistory>.from(state.historyList);
    updatedList.removeAt(index);
    state = state.copyWith(historyList: updatedList);

    // Hapus dari Firestore jika user login
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('screenings')
          .where('date', isEqualTo: screening.date.toIso8601String())
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (_) {
      // Abaikan error dan tetap gunakan state lokal
    }
  }

  /// Hapus screening berdasarkan kecocokan tanggal dan skor
  Future<void> removeScreeningByDateScore(DateTime date, int score) async {
    final idx = state.historyList.indexWhere(
      (h) => h.date.millisecondsSinceEpoch == date.millisecondsSinceEpoch && h.score == score,
    );

    if (idx == -1) return;

    await removeScreening(idx);
  }

  /// Hapus SEMUA riwayat screening dari state lokal dan Firestore
  Future<void> clearAll() async {
    // Clear state lokal
    state = ScreeningHistoryState();

    // Hapus semua dari Firestore jika user login
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final collectionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('screenings');

      final querySnapshot = await collectionRef.get();
      
      // Delete all documents
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (_) {
      // Abaikan error
    }
  }

  /// Muat ulang semua riwayat screening dari Firestore untuk user yang sedang login
  Future<void> loadFromFirestore() async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = ScreeningHistoryState();
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('screenings')
          .orderBy('date', descending: true)
          .get();

      final historyList = querySnapshot.docs
          .map((doc) => ScreeningHistory.fromJson(doc.data()))
          .toList();

      state = ScreeningHistoryState(historyList: historyList);
    } catch (_) {
      // Jika gagal memuat, biarkan state apa adanya
    }
  }
}

// Provider
final screeningHistoryProvider = StateNotifierProvider<ScreeningHistoryNotifier, ScreeningHistoryState>((ref) {
  return ScreeningHistoryNotifier();
});
