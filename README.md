# 🧠 InsightMind App

**InsightMind** adalah aplikasi mobile untuk screening kesehatan mental yang dibuat dengan Flutter. Aplikasi ini menyediakan penilaian singkat status mental dengan interface yang modern dan user-friendly.

## ✨ Fitur Utama

### 🎯 Onboarding & Guest Mode
- **Onboarding interaktif** dengan 4 slides pengenalan
- **Guest mode** - gunakan aplikasi tanpa login
- **Optional login** - login hanya jika ingin save data
- Tombol "Lewati" untuk skip onboarding

### 🔐 Autentikasi (Optional)
- **Login** via menu profil
- **Register** dengan validasi lengkap
- Social login (Google) - siap diintegrasikan
- Password visibility toggle
- Profile page dengan 2 mode (Guest & Logged In)

### 🏠 Home & Dashboard
- Dashboard dengan greeting dinamis berdasarkan waktu
- Hero card untuk memulai screening
- Quick stats (Status kesehatan & jumlah screening)
- Daily tips kesehatan mental (3 tips berbeda)
- Features grid (Riwayat, Artikel, Konsultasi, Bantuan)

### 🧪 Mental Health Screening
- Kuesioner screening mental health
- Hasil screening dengan interpretasi
- Riwayat screening

### 👤 Profile
- Manajemen profil pengguna

## 🎨 Design System

### Color Palette
- **Primary**: `#6C63FF` (Purple)
- **Secondary**: `#8E7BFF` (Light Purple)
- **Accent**: `#B39DFF` (Lighter Purple)
- **Background**: `#F8F9FA`
- **Text**: `#2D2D2D`

### Typography
- **Font**: Google Fonts - Poppins
- **Material 3** Design System

### UI Components
- Border radius konsisten (16-24px)
- Soft shadows untuk depth
- Smooth animations dan transitions
- Gradient backgrounds

## 📱 Halaman Aplikasi

```
├── 🎯 Onboarding Page        # Pengenalan aplikasi (4 slides)
├── 🏠 Home Page              # Dashboard utama (langsung akses)
├── 🧪 Screening Page         # Kuesioner screening
├── 📊 Result Page            # Hasil screening
└── 👤 Profile Page           # Profil & Login/Register
    ├── Guest View           # Belum login
    └── Logged In View       # Sudah login
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code
- Device atau Emulator

### Instalasi

1. **Clone repository**
   ```bash
   git clone <repository-url>
   cd insightmind_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run aplikasi**
   ```bash
   # Android/iOS
   flutter run
   
   # Web
   flutter run -d chrome
   
   # Windows
   flutter run -d windows
   ```

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1    # State management
  google_fonts: ^6.1.0        # Typography
  cupertino_icons: ^1.0.8
```

## 📂 Struktur Folder

```
lib/
├── main.dart                 # Entry point
├── src/
│   └── app.dart             # MaterialApp configuration
├── core/                    # Core utilities
├── features/
│   └── insightmind/
│       ├── data/           # Data layer
│       ├── domain/         # Business logic
│       └── presentation/   # UI layer
│           ├── pages/
│           │   ├── onboarding_page.dart     ✨ NEW
│           │   ├── home_page.dart
│           │   ├── profile_page.dart        🔄 UPDATED
│           │   ├── login_page.dart          🔄 UPDATED
│           │   ├── register_page.dart       🔄 UPDATED
│           │   ├── screening_page.dart
│           │   ├── result_page.dart
│           │   ├── welcome_page.dart        ⚠️ DEPRECATED
│           │   └── splash_page.dart         ⚠️ DEPRECATED
│           └── providers/
└── providers/              # Global providers
```

## 🎯 Alur Aplikasi

### Alur Baru (User-Friendly) ✨
```
App Launch
    ↓
Onboarding (4 slides pengenalan)
    ↓
[Lewati] atau [Lanjutkan/Mulai Sekarang]
    ↓
Home Page (Langsung bisa digunakan sebagai Guest)
    ↓
Menu Profil → Login/Register (Optional)
    ↓
Logged In → Save data & akses fitur premium
```

### Keuntungan:
- ✅ User bisa langsung coba aplikasi
- ✅ Tidak ada barrier/friction
- ✅ Login hanya jika butuh save data
- ✅ Better user experience

## 📝 TODO / Roadmap

### Short Term
- [ ] Implementasi backend API
- [ ] Integrasi database (Firebase/REST API)
- [ ] Google Sign-In implementation
- [ ] Email verification
- [ ] Forgot password functionality

### Medium Term
- [ ] Notifikasi push
- [ ] Dark mode
- [ ] Multi-language support
- [ ] Offline mode
- [ ] Data caching

### Long Term
- [ ] Konsultasi online dengan profesional
- [ ] Chat support
- [ ] Artikel kesehatan mental
- [ ] Progress tracking
- [ ] Reminder untuk screening berkala
- [ ] Export hasil screening (PDF)

## 🔒 Security Notes

- Password minimal 6 karakter
- Form validation di semua input
- TODO: Implementasi secure storage untuk token
- TODO: Implementasi encryption untuk data sensitif

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test

# Run with coverage
flutter test --coverage
```

## 📚 Documentation

Lihat dokumentasi tambahan:
- [FLOW_UPDATE.md](FLOW_UPDATE.md) - ✨ Update alur aplikasi & penjelasan lengkap
- [AUTH_README.md](AUTH_README.md) - Detail fitur autentikasi
- [DESIGN_PREVIEW.md](DESIGN_PREVIEW.md) - Preview desain dan spesifikasi

## 🤝 Contributing

Contributions are welcome! Silakan buat pull request atau laporkan issue.

## 📄 License

This project is private and proprietary.

## 👥 Team

- **KELOMPOK KOPLAK** - Development Team

## 📞 Support

Jika ada pertanyaan atau issue, silakan hubungi tim development.

---

**Dibuat dengan ❤️ untuk Kesehatan Mental yang Lebih Baik**

