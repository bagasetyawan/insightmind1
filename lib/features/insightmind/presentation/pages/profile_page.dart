import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/screening_history_provider.dart' as global_history;
import '../../../../providers/theme_provider.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'history_page.dart' as history_page;
//fsefeadawd
// Provider untuk navigasi ke History
final navigationIndexProvider = StateProvider<int>((ref) => 0);
//adwwad
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      body: SafeArea(
        child: authState.isLoggedIn 
            ? _buildLoggedInView(context, ref, authState) 
            : _buildGuestView(context, ref),
      ),
    );
  }

  // Tampilan untuk user yang sudah login
  Widget _buildLoggedInView(BuildContext context, WidgetRef ref, AuthState authState) {
    final user = authState.user!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Profile Picture
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00BCD4), Color(0xFF03A9F4)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00BCD4).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: user.profileImage != null
                ? ClipOval(
                    child: Image.network(
                      user.profileImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: GoogleFonts.poppins(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          Text(
            user.name,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Profile Info Card - Selalu tampil
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00BCD4).withOpacity(0.1),
                  const Color(0xFF03A9F4).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00BCD4).withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi Akun',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.person_outline, 'Nama Lengkap', user.name),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.email_outlined, 'Email', user.email),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.badge_outlined, 'ID Pengguna', user.id.substring(0, 8)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Menu Items
          _buildMenuItem(
            icon: Icons.history_rounded,
            title: 'Riwayat Screening',
            onTap: () {
              // Set index ke 1 untuk History page
              ref.read(navigationIndexProvider.notifier).state = 1;
            },
          ),
          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: 'Pengaturan',
            onTap: () {
              _showSettingsDialog(context, ref, authState.user!);
            },
          ),
          const SizedBox(height: 20),
          _buildMenuItem(
            icon: Icons.logout_rounded,
            title: 'Keluar',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    'Keluar',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  content: Text(
                    'Apakah Anda yakin ingin keluar?',
                    style: GoogleFonts.poppins(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.poppins(color: Colors.grey[600]),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Logout user
                        ref.read(authProvider.notifier).logout();

                        // Clear all screening histories (lokal dan Firestore)
                        await ref.read(global_history.screeningHistoryProvider.notifier).clearAll();

                        // Kembali ke tab Home
                        ref.read(navigationIndexProvider.notifier).state = 0;

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Berhasil keluar',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: const Color(0xFF4CAF50),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Keluar',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ],
                ),
              );
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  // Tampilan untuk guest (belum login)
  Widget _buildGuestView(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // Illustration
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00BCD4).withOpacity(0.2),
                  const Color(0xFF03A9F4).withOpacity(0.2),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              size: 100,
              color: Color(0xFF00BCD4),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Title
          Text(
            'Belum Login',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D2D2D),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Login atau daftar untuk mendapatkan pengalaman penuh dan menyimpan riwayat screening Anda',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Benefits
          _buildBenefitCard(
            icon: Icons.bookmark_outline,
            title: 'Simpan Riwayat',
            description: 'Semua hasil screening tersimpan dengan aman',
          ),
          const SizedBox(height: 16),
          _buildBenefitCard(
            icon: Icons.timeline_rounded,
            title: 'Pantau Progress',
            description: 'Lihat perkembangan kesehatan mental Anda',
          ),
          const SizedBox(height: 16),
          _buildBenefitCard(
            icon: Icons.cloud_sync_outlined,
            title: 'Sinkronisasi Data',
            description: 'Akses data Anda dari perangkat manapun',
          ),
          
          const SizedBox(height: 40),
          
          // Login Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Masuk',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Register Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF00BCD4),
                side: const BorderSide(color: Color(0xFF00BCD4), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Daftar Akun Baru',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Continue as Guest
          TextButton(
            onPressed: () {
              // Already on home page, just show a message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Anda sedang menggunakan aplikasi sebagai tamu',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: const Color(0xFF00BCD4),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: Text(
              'Lanjutkan Tanpa Login',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive 
                ? Colors.red.withOpacity(0.1)
                : const Color(0xFF00BCD4).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : const Color(0xFF00BCD4),
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : const Color(0xFF2D2D2D),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey[400],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00BCD4).withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00BCD4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF00BCD4),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF00BCD4),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Dialog functions
  void _showEditProfileDialog(BuildContext context, WidgetRef ref, User user) {
    final TextEditingController nameController = TextEditingController(text: user.name);
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    bool showPasswordSection = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Profil', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username Section
                Text(
                  'Username',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan username baru',
                    hintStyle: GoogleFonts.poppins(fontSize: 13),
                    prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF00BCD4)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF00BCD4)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2),
                    ),
                  ),
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 20),
                
                // Password Section Toggle
                InkWell(
                  onTap: () {
                    setState(() {
                      showPasswordSection = !showPasswordSection;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        showPasswordSection ? Icons.lock_open : Icons.lock_outline,
                        color: const Color(0xFF00BCD4),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ubah Password',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: const Color(0xFF00BCD4),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        showPasswordSection ? Icons.expand_less : Icons.expand_more,
                        color: const Color(0xFF00BCD4),
                      ),
                    ],
                  ),
                ),
                
                if (showPasswordSection) const SizedBox(height: 16),
                if (showPasswordSection) Text(
                  'Password Lama',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
                ),
                if (showPasswordSection) const SizedBox(height: 6),
                if (showPasswordSection) TextField(
                  controller: currentPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Masukkan password lama',
                    hintStyle: GoogleFonts.poppins(fontSize: 13),
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF00BCD4), size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                if (showPasswordSection) const SizedBox(height: 12),
                if (showPasswordSection) Text(
                  'Password Baru',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
                ),
                if (showPasswordSection) const SizedBox(height: 6),
                if (showPasswordSection) TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Masukkan password baru',
                    hintStyle: GoogleFonts.poppins(fontSize: 13),
                    prefixIcon: const Icon(Icons.lock, color: Color(0xFF00BCD4), size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                if (showPasswordSection) const SizedBox(height: 12),
                if (showPasswordSection) Text(
                  'Konfirmasi Password Baru',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
                ),
                if (showPasswordSection) const SizedBox(height: 6),
                if (showPasswordSection) TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Konfirmasi password baru',
                    hintStyle: GoogleFonts.poppins(fontSize: 13),
                    prefixIcon: const Icon(Icons.lock_clock, color: Color(0xFF00BCD4), size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: GoogleFonts.poppins(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                // Validasi
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Username tidak boleh kosong', style: GoogleFonts.poppins()),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                if (showPasswordSection) {
                  if (currentPasswordController.text.isEmpty ||
                      newPasswordController.text.isEmpty ||
                      confirmPasswordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Semua field password harus diisi', style: GoogleFonts.poppins()),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  if (newPasswordController.text != confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Password baru tidak cocok', style: GoogleFonts.poppins()),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  if (newPasswordController.text.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Password minimal 6 karakter', style: GoogleFonts.poppins()),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                }
                
                // Update user data
                final updatedUser = User(
                  id: user.id,
                  name: nameController.text.trim(),
                  email: user.email,
                  profileImage: user.profileImage,
                );
                
                ref.read(authProvider.notifier).updateUser(updatedUser);
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      showPasswordSection
                          ? 'Profil dan password berhasil diperbarui'
                          : 'Profil berhasil diperbarui',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: const Color(0xFF4CAF50),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Simpan', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, WidgetRef ref, User user) {
    showDialog(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final themeMode = ref.watch(themeProvider);
          final isDark = themeMode == ThemeMode.dark;
          
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
            title: Text(
              'Pengaturan',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF2D2D2D),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: Color(0xFF00BCD4)),
                  title: Text(
                    'Edit Profil',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFF00BCD4),
                  ),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _showEditProfileDialog(context, ref, user);
                  },
                ),
                Divider(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  height: 16,
                ),
                ListTile(
                  leading: Icon(
                    themeMode == ThemeMode.dark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: const Color(0xFF00BCD4),
                  ),
                  title: Text(
                    themeMode == ThemeMode.dark ? 'Mode Gelap' : 'Mode Terang',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                    ),
                  ),
                  trailing: Switch(
                    value: themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      ref.read(themeProvider.notifier).toggleTheme();
                    },
                    activeColor: const Color(0xFF00BCD4),
                    inactiveTrackColor: isDark
                        ? Colors.grey[700]
                        : Colors.grey[300],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Tutup',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF00BCD4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Bantuan', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cara Menggunakan Aplikasi:',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 12),
              _buildHelpItem('1. Klik "Mulai Screening" untuk memulai tes kesehatan mental'),
              _buildHelpItem('2. Jawab semua pertanyaan dengan jujur'),
              _buildHelpItem('3. Lihat hasil dan rekomendasi setelah selesai'),
              _buildHelpItem('4. Cek riwayat screening di menu Riwayat'),
              const SizedBox(height: 16),
              Text(
                'Butuh bantuan lebih lanjut?',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Email: support@insightmind.com\nTelepon: 021-12345678',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Mengerti', style: GoogleFonts.poppins(color: const Color(0xFF00BCD4))),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 16, color: Color(0xFF00BCD4)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: GoogleFonts.poppins(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Kebijakan Privasi', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'InsightMind menghargai privasi Anda. Berikut kebijakan kami:',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              const SizedBox(height: 16),
              _buildPrivacyItem('Data Pribadi', 'Kami mengumpulkan dan menyimpan data pribadi Anda dengan aman.'),
              _buildPrivacyItem('Hasil Screening', 'Hasil screening Anda bersifat pribadi dan tidak dibagikan kepada pihak ketiga.'),
              _buildPrivacyItem('Keamanan Data', 'Data Anda dienkripsi dan disimpan dengan standar keamanan tinggi.'),
              _buildPrivacyItem('Penggunaan Data', 'Data hanya digunakan untuk meningkatkan layanan aplikasi.'),
              const SizedBox(height: 16),
              Text(
                'Terakhir diperbarui: November 2025',
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Saya Mengerti', style: GoogleFonts.poppins(color: const Color(0xFF00BCD4))),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
