# 🔄 Update Alur Aplikasi InsightMind

## Perubahan Utama

Aplikasi InsightMind telah diperbarui dengan alur baru yang lebih user-friendly:

### ❌ Alur Lama (Sebelumnya)
```
Splash Screen → Welcome Page → Login/Register → Home
```
**Masalah**: User harus login terlebih dahulu untuk menggunakan aplikasi

### ✅ Alur Baru (Sekarang)
```
Onboarding (Pengenalan) → Home (Langsung bisa digunakan)
                           ↓
                      Menu Profil
                           ↓
                    Login/Register (Opsional)
```
**Keuntungan**: User bisa langsung menggunakan aplikasi tanpa login

---

## 📱 Halaman Baru

### 1. **Onboarding Page** (Halaman Pengenalan)
Menggantikan Splash Screen dan Welcome Page dengan experience yang lebih baik:

#### Fitur:
- **4 Slides Pengenalan**:
  1. Selamat datang di InsightMind
  2. Screening Mental Health
  3. Pantau Perkembangan
  4. Dukungan Profesional

- **Interactive UI**:
  - Swipe untuk navigasi antar slide
  - Page indicators (dots)
  - Tombol "Lewati" di pojok kanan atas
  - Tombol "Lanjutkan" / "Mulai Sekarang"
  
- **Design**:
  - Ikon besar dengan gradient berbeda per slide
  - Animasi smooth saat berpindah slide
  - Typography yang jelas dan mudah dibaca

### 2. **Profile Page - Guest Mode** (Halaman Profil)
Halaman profil sekarang memiliki 2 tampilan berbeda:

#### A. Tampilan Tamu (Belum Login) ✨
- **Header**: Ilustrasi user dengan teks "Belum Login"
- **Manfaat Login** (3 Cards):
  - 📑 Simpan Riwayat - Semua hasil screening tersimpan
  - 📊 Pantau Progress - Lihat perkembangan kesehatan mental
  - ☁️ Sinkronisasi Data - Akses dari perangkat manapun
  
- **Call-to-Action Buttons**:
  - Tombol "Masuk" (Primary - Purple)
  - Tombol "Daftar Akun Baru" (Outline)
  - Link "Lanjutkan Tanpa Login"

#### B. Tampilan User Login (Setelah Login)
- Foto profil dengan gradient
- Nama dan email user
- Menu items:
  - ✏️ Edit Profil
  - 📋 Riwayat Screening
  - ⚙️ Pengaturan
  - ❓ Bantuan
  - 🔒 Kebijakan Privasi
  - 🚪 Keluar (merah)

---

## 🎯 User Flow

### Scenario 1: User Baru (Tanpa Login)
```
1. Buka Aplikasi
   ↓
2. Lihat Onboarding (4 slides)
   ↓
3. Klik "Mulai Sekarang"
   ↓
4. Langsung masuk ke Home Page
   ↓
5. Bisa langsung menggunakan fitur:
   - Screening mental health
   - Lihat tips kesehatan
   - Akses fitur-fitur lainnya
   ↓
6. Jika ingin save data:
   - Buka Menu Profil
   - Klik "Masuk" atau "Daftar"
```

### Scenario 2: User yang Ingin Login dari Awal
```
1. Buka Aplikasi
   ↓
2. Lihat Onboarding
   ↓
3. Klik "Lewati" (skip onboarding)
   ↓
4. Masuk ke Home Page
   ↓
5. Buka Menu Profil
   ↓
6. Klik "Masuk"
   ↓
7. Login berhasil → Kembali ke Home
```

### Scenario 3: User yang Sudah Login
```
1. Buka Aplikasi
   ↓
2. Skip Onboarding (sudah pernah buka)
   ↓
3. Auto-login jika ada session
   ↓
4. Langsung ke Home dengan status login
```

---

## 🎨 Perubahan UI/UX

### Onboarding Page
- **Warna per Slide**:
  - Slide 1: Purple (#6C63FF)
  - Slide 2: Green (#4CAF50)
  - Slide 3: Orange (#FF9800)
  - Slide 4: Blue (#2196F3)

- **Spacing**: Padding konsisten 40px horizontal
- **Typography**: 
  - Title: 26px, Bold
  - Description: 16px, Regular

### Profile Page (Guest)
- **Ilustrasi**: Circle dengan gradient subtle
- **Benefit Cards**: White background dengan border purple
- **Buttons**: Full width, 56px height
- **Spacing**: Generous padding untuk readability

---

## 🔧 Technical Details

### File Structure
```
lib/features/insightmind/presentation/pages/
├── onboarding_page.dart      ✨ NEW - Pengenalan aplikasi
├── home_page.dart             - Dashboard utama
├── profile_page.dart          🔄 UPDATED - Guest + Logged in view
├── login_page.dart            🔄 UPDATED - Success message
├── register_page.dart         🔄 UPDATED - Success message
├── screening_page.dart        - Kuesioner
├── result_page.dart           - Hasil screening
├── welcome_page.dart          ⚠️ DEPRECATED - Tidak digunakan lagi
└── splash_page.dart           ⚠️ DEPRECATED - Tidak digunakan lagi
```

### State Management (Next Steps)
```dart
// TODO: Implementasi dengan Riverpod
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final bool isLoggedIn;
  final User? user;
  final bool hasSeenOnboarding;
  
  // ...
}
```

### Navigation Logic
```dart
// Di app.dart
home: const OnboardingPage()

// Setelah onboarding
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => const HomePage()),
)

// Setelah login/register
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => const HomePage()),
  (route) => false, // Remove all previous routes
)
```

---

## ✅ Checklist Implementasi

- [x] Buat Onboarding Page dengan 4 slides
- [x] Update Profile Page dengan guest view
- [x] Update Profile Page dengan logged in view
- [x] Update Login Page dengan success message
- [x] Update Register Page dengan success message
- [x] Update app.dart untuk use OnboardingPage
- [x] Update navigation flow

### 🚧 TODO - Next Steps

- [ ] Implementasi SharedPreferences untuk:
  - [ ] Flag "hasSeenOnboarding" (jangan tampilkan lagi)
  - [ ] Save login state
  - [ ] Save user data

- [ ] State Management:
  - [ ] Setup AuthProvider dengan Riverpod
  - [ ] Manage login/logout state
  - [ ] Persist authentication

- [ ] Backend Integration:
  - [ ] Connect login API
  - [ ] Connect register API
  - [ ] Handle token storage
  - [ ] Handle refresh token

- [ ] Profile Features:
  - [ ] Edit profil functionality
  - [ ] Upload foto profil
  - [ ] View riwayat screening
  - [ ] Settings page

---

## 🎯 Keuntungan Alur Baru

### 1. **Better User Experience**
- User bisa langsung explore aplikasi
- Tidak ada barrier untuk mencoba fitur
- Lebih welcoming untuk user baru

### 2. **Lower Friction**
- Tidak memaksa login di awal
- User decide sendiri kapan mau login
- Onboarding yang informatif

### 3. **Higher Conversion**
- User bisa coba dulu sebelum commit
- Login hanya jika butuh save data
- Lebih natural flow

### 4. **Flexibility**
- Support guest mode
- Support logged in mode
- Easy to switch between modes

---

## 📊 Comparison

| Aspek | Alur Lama | Alur Baru |
|-------|-----------|-----------|
| Time to first use | 3-5 menit (harus register) | 30 detik |
| User friction | Tinggi | Rendah |
| Guest access | ❌ Tidak ada | ✅ Tersedia |
| Onboarding | Minimal | Informatif |
| Profile access | Auto tersedia | Via menu profil |
| Data persistence | Wajib login | Optional |

---

**Update Date**: November 18, 2025  
**Version**: 2.0  
**Status**: ✅ Implemented
