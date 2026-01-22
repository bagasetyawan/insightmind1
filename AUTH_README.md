# Fitur Autentikasi InsightMind

Aplikasi InsightMind sekarang dilengkapi dengan sistem autentikasi yang lengkap dan menarik.

## 📱 Halaman yang Tersedia

### 1. **Splash Screen** (`splash_page.dart`)
- Animasi logo yang smooth dengan efek scale dan fade
- Gradient background ungu yang menarik
- Loading indicator
- Otomatis redirect ke Welcome Page setelah 3 detik
- Transition yang halus antar halaman

### 2. **Welcome Page** (`welcome_page.dart`)
- Hero section dengan logo dan tagline
- 3 fitur utama aplikasi:
  - ✅ Aman & Terpercaya
  - ✅ Screening Profesional
  - ✅ Dukungan 24/7
- Tombol "Masuk" dan "Daftar"
- Animasi fade in yang smooth
- Gradient background yang menarik

### 3. **Login Page** (`login_page.dart`)
- Form login dengan validasi:
  - Email (wajib diisi, format email valid)
  - Password (minimal 6 karakter)
- Fitur "Lupa Password?"
- Toggle visibility password
- Tombol login dengan loading state
- Social login (Google) - siap diimplementasikan
- Link ke halaman register
- Error handling dan validasi input

### 4. **Register Page** (`register_page.dart`)
- Form registrasi dengan validasi:
  - Nama lengkap (wajib diisi)
  - Email (format valid)
  - Password (minimal 6 karakter)
  - Konfirmasi password (harus sama)
- Checkbox syarat & ketentuan
- Toggle visibility password
- Tombol register dengan loading state
- Social register (Google) - siap diimplementasikan
- Link ke halaman login
- Error handling dan validasi input

## 🎨 Desain Features

### Design System
- **Warna Utama**: Purple (#6C63FF)
- **Font**: Google Fonts - Poppins
- **Border Radius**: 16px (konsisten)
- **Shadows**: Soft shadow untuk kedalaman
- **Material 3**: Design system terbaru

### UI/UX Features
- ✨ Animasi smooth pada transisi
- 🎯 Form validation real-time
- 📱 Responsive design
- 🔒 Password visibility toggle
- ⚡ Loading states pada tombol
- 🎨 Gradient backgrounds
- 💫 Smooth transitions
- ✅ Error handling yang user-friendly

## 🔄 Alur Aplikasi

```
Splash Screen (3 detik)
    ↓
Welcome Page
    ├─→ Login Page → Home Page
    └─→ Register Page → Home Page
```

## 🚀 Cara Menggunakan

1. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

2. **Alur User Baru**
   - Splash Screen muncul saat pertama kali membuka app
   - Pilih "Daftar" di Welcome Page
   - Isi form registrasi
   - Centang checkbox syarat & ketentuan
   - Klik "Daftar"
   - Redirect ke Home Page

3. **Alur User Existing**
   - Splash Screen muncul
   - Pilih "Masuk" di Welcome Page
   - Masukkan email dan password
   - Klik "Masuk"
   - Redirect ke Home Page

## 📝 TODO / Next Steps

- [ ] Implementasi integrasi backend API
- [ ] Implementasi Google Sign-In
- [ ] Implementasi "Lupa Password" functionality
- [ ] Simpan status login (SharedPreferences/Secure Storage)
- [ ] Email verification
- [ ] Session management
- [ ] Biometric authentication (fingerprint/face ID)

## 🛠 Technical Details

### Dependencies
- `flutter_riverpod` - State management
- `google_fonts` - Typography

### File Structure
```
lib/
├── features/
│   └── insightmind/
│       └── presentation/
│           └── pages/
│               ├── splash_page.dart      # Splash screen
│               ├── welcome_page.dart     # Halaman pembuka
│               ├── login_page.dart       # Halaman login
│               ├── register_page.dart    # Halaman registrasi
│               └── home_page.dart        # Halaman utama
```

---

**Dibuat dengan ❤️ untuk InsightMind**
