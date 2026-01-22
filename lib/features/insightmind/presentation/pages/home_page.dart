import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'history_page.dart' as history_page;
import 'profile_page.dart';
import 'screening_page.dart';
import 'biometric_stress_result_page.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/screening_history_provider.dart' as global_history;
import 'package:insightmind_app/core/biometric/biometric_helper.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeContent(),
    history_page.HistoryPage(),
    ConsultationPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Sync dengan provider
    ref.read(navigationIndexProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accent = Color(0xFF00BCD4);

    // Listen to navigation changes from provider
    ref.listen(navigationIndexProvider, (previous, next) {
      if (!mounted) return;
      if (_selectedIndex != next) {
        setState(() {
          _selectedIndex = next;
        });
      }
    });

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isDark ? const Color(0xFF1B1B1F) : Colors.white,
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.06) : accent.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.35 : 0.12),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              height: 72,
              indicatorColor: accent.withOpacity(0.16),
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.show_chart_outlined),
                  selectedIcon: Icon(Icons.show_chart_rounded),
                  label: 'History',
                ),
                NavigationDestination(
                  icon: Icon(Icons.medical_services_outlined),
                  selectedIcon: Icon(Icons.medical_services_rounded),
                  label: 'Konsultasi',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final userName = authState.user?.name ?? 'Pengguna';
    final firstName = userName.split(' ').first;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [
                  Color(0xFF121212),
                  Color(0xFF1E1E1E),
                ]
              : const [
                  Color(0xFFE0F7FA),
                  Color(0xFFFDFEFF),
                ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Profile
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00BCD4).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: authState.user?.profileImage != null
                        ? ClipOval(
                            child: Image.network(
                              authState.user!.profileImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Text(
                              firstName[0].toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat Datang!',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: isDark ? Colors.grey[400] : const Color(0xFF8E8E93),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$firstName ',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Hero Card
              _HomeHeroCard(),
              const SizedBox(height: 30),
              
              // Aktivitas Anda
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Aktivitas Anda",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                      ),
                    ),
                  ],
                ),
              ),
              _ProgressCards(),
              const SizedBox(height: 32),
              
              // Tips Hari Ini
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00E5FF), Color(0xFF00BCD4)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Tips Kesehatan Mental",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                      ),
                    ),
                  ],
                ),
              ),
              _ReflectionCards(),
              const SizedBox(height: 32),
              
              // Features Grid
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Fitur Lainnya",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                      ),
                    ),
                  ],
                ),
              ),
              _FeaturesGrid(),
            ],
          ),
        ),
      ),
    );
  }
}
//adwadwa
class ConsultationPage extends StatelessWidget {
  const ConsultationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgGradient = isDark
        ? const [Color(0xFF121212), Color(0xFF1E1E1E)]
        : const [Color(0xFFE0F7FA), Color(0xFFFDFEFF)];

    final doctors = [
      {
        'name': 'Dr. Andini, Sp.KJ',
        'spec': 'Psikiater',
        'loc': 'RS Sehat Jiwa',
        'contact': '08xx-xxxx-1001',
      },
      {
        'name': 'dr. Raka, M.Psi',
        'spec': 'Psikolog Klinis',
        'loc': 'Klinik Bahagia',
        'contact': '08xx-xxxx-2002',
      },
      {
        'name': 'Dr. Lestari, Sp.KJ',
        'spec': 'Psikiater',
        'loc': 'RS Sentosa',
        'contact': '08xx-xxxx-3003',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: bgGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  _ConsultActionCard(
                    title: 'Konsultasi Profesional',
                    description: 'Pilih dokter/psikolog untuk konsultasi sesuai kebutuhan Anda',
                    icon: Icons.medical_services_rounded,
                    isDark: isDark,
                    onTap: () => _openDoctorListPage(context, doctors),
                  ),
                  const SizedBox(height: 12),
                  _ConsultActionCard(
                    title: 'Mindfulness & Meditasi',
                    description: 'Praktikkan mindfulness 10-15 menit setiap hari',
                    icon: Icons.self_improvement_rounded,
                    isDark: isDark,
                    onTap: () => _showMeditationSheet(context),
                  ),
                  const SizedBox(height: 12),
                  _ConsultActionCard(
                    title: 'Olahraga Teratur',
                    description: 'Minimal 30 menit aktivitas fisik, 3-4 kali seminggu',
                    icon: Icons.fitness_center_rounded,
                    isDark: isDark,
                    onTap: () => _showExerciseSheet(context),
                  ),
                ],
              ),
            ],
            
          ),
        ),
      ),
    );
  }

  void _openDoctorListPage(BuildContext context, List<Map<String, String>> doctors) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DoctorListPage(doctors: doctors),
      ),
    );
  }

  void _showMeditationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rekomendasi Meditasi', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.timelapse_rounded, color: Color(0xFF23D5E3)),
                title: Text('Meditasi Napas 10 menit', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                subtitle: Text('Fokus pada napas, hitung 1-10 berulang', style: GoogleFonts.poppins(fontSize: 12)),
              ),
              ListTile(
                leading: const Icon(Icons.self_improvement_rounded, color: Color(0xFF23D5E3)),
                title: Text('Body Scan', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                subtitle: Text('Tarik napas pelan sambil memindai tubuh dari kepala ke kaki', style: GoogleFonts.poppins(fontSize: 12)),
              ),
              ListTile(
                leading: const Icon(Icons.nightlight_round, color: Color(0xFF23D5E3)),
                title: Text('Wind-down sebelum tidur', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                subtitle: Text('5 menit pernapasan 4-7-8 untuk relaksasi', style: GoogleFonts.poppins(fontSize: 12)),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('Tutup', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showExerciseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rekomendasi Olahraga', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.directions_walk_rounded, color: Color(0xFF23D5E3)),
                title: Text('Jalan cepat 30 menit', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                subtitle: Text('3-4 kali seminggu, pagi atau sore', style: GoogleFonts.poppins(fontSize: 12)),
              ),
              ListTile(
                leading: const Icon(Icons.directions_bike_rounded, color: Color(0xFF23D5E3)),
                title: Text('Bersepeda ringan 20-30 menit', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                subtitle: Text('Pilih rute datar untuk menjaga ritme', style: GoogleFonts.poppins(fontSize: 12)),
              ),
              ListTile(
                leading: const Icon(Icons.sports_gymnastics_rounded, color: Color(0xFF23D5E3)),
                title: Text('Latihan peregangan 10 menit', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                subtitle: Text('Lakukan sebelum/ setelah kerja untuk meredakan tegang', style: GoogleFonts.poppins(fontSize: 12)),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('Tutup', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}

class DoctorListPage extends StatelessWidget {
  final List<Map<String, String>> doctors;

  const DoctorListPage({super.key, required this.doctors});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF203A43),
        title: Text('Daftar Dokter', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            final d = doctors[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF23D5E3),
                  child: const Icon(Icons.medical_services_rounded, color: Colors.white),
                ),
                title: Text(d['name'] ?? '-', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
                subtitle: Text('Konsultasi', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
                trailing: const Icon(Icons.more_horiz_rounded, color: Colors.white70),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DoctorChatPage(
                      doctorName: d['name'] ?? '-',
                      contact: d['contact'] ?? '-',
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ConsultActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _ConsultActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = isDark
        ? const [Color(0xFF1F4D5F), Color(0xFF0D3B4C)]
        : const [Color(0xFF23D5E3), Color(0xFF29ABE2)];
    final surfaceColor = isDark ? Colors.white.withOpacity(0.14) : Colors.white.withOpacity(0.16);
    final arrowColor = isDark ? Colors.white70 : const Color(0xFF2D2D2D);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(isDark ? 0.14 : 0.18),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: surfaceColor,
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: arrowColor),
          ],
        ),
      ),
    );
  }
}

void showDoctorContacts(BuildContext context, String name, String contact) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF23D5E3),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
                      Text('Kontak tersedia', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ContactRow(label: 'Nomor utama', value: contact),
            const SizedBox(height: 8),
            _ContactRow(label: 'Hotline klinik', value: '119 ext 8'),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Tutup', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      );
    },
  );
}

// Progress Cards Widget dengan akses ke provider
class _ProgressCards extends ConsumerWidget {
  const _ProgressCards();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Gunakan riwayat global yang juga tersimpan di Firestore
    final historyState = ref.watch(global_history.screeningHistoryProvider);

    // Samakan dengan History: terapkan filter periode Mingguan/Bulanan
    final selectedPeriod = ref.watch(history_page.selectedPeriodProvider);
    final now = DateTime.now();
    final days = selectedPeriod == 'Mingguan' ? 7 : 30;
    final filteredHistory = historyState.historyList
      .where((record) => now.difference(record.date).inDays < days)
      .toList();

    final totalTests = filteredHistory.length;
    final latestScore =
      filteredHistory.isNotEmpty ? filteredHistory.first.score : null;
    const maxScore = 100; // Maksimal skor setelah normalisasi (0-100)
    final scorePercentage = latestScore != null ? latestScore / maxScore : 0.0;

    return Row(
      children: [
        // Total Tes Card
        Expanded(
          child: InkWell(
            onTap: () {
              final homePageState =
                  context.findAncestorStateOfType<_HomePageState>();
              if (homePageState != null) {
                homePageState._onItemTapped(1);
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF2D2D2D),
                          const Color(0xFF3D3D3D),
                        ]
                      : [
                          Colors.white,
                          const Color(0xFFF5FBFC),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF00BCD4).withOpacity(0.1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00BCD4).withOpacity(isDark ? 0.2 : 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00BCD4).withOpacity(0.2),
                          const Color(0xFF80DEEA).withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00BCD4).withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Text(
                      '📊',
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total Tes',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$totalTests',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark ? Colors.white : const Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Screening yang dilakukan',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Skor Terakhir Card
        Expanded(
          child: InkWell(
            onTap: () {
              final homePageState =
                  context.findAncestorStateOfType<_HomePageState>();
              if (homePageState != null) {
                homePageState._onItemTapped(1);
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF2D2D2D),
                          const Color(0xFF3D3D3D),
                        ]
                      : [
                          Colors.white,
                          const Color(0xFFFFF8F5),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9800).withOpacity(isDark ? 0.2 : 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF9800).withOpacity(0.2),
                          const Color(0xFFFFB74D).withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF9800).withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Text(
                      '📈',
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Skor Terakhir',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          latestScore != null ? '$latestScore' : '-',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF2D2D2D),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: Stack(
                          children: [
                            Center(
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(
                                  value: scorePercentage,
                                  strokeWidth: 5,
                                  backgroundColor: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[200],
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF00BCD4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hasil screening terakhir',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Hero Card Widget
class _HomeHeroCard extends ConsumerWidget {
  const _HomeHeroCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1F4D5F),
                  const Color(0xFF0D3B4C),
                ]
              : [
                  const Color(0xFF00D4E8),
                  const Color(0xFF0097A7),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color:
                (isDark ? Colors.black : const Color(0xFF00BCD4)).withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.psychology_alt_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Cek Kondisi Mental Anda',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Mulai perjalanan kesehatan mental Anda hari ini. Screening dapat membantu Anda memahami kondisi diri dengan lebih baik.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    final authState = ref.read(authProvider);

                    if (!authState.isLoggedIn) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Anda harus login terlebih dahulu untuk melakukan screening. Silakan masuk melalui menu Profil.',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Tampilkan pilihan: biometrik atau manual
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (sheetContext) {
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pilih Cara Mulai Screening',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Anda dapat menggunakan scan wajah/biometrik atau lanjut secara manual.',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 20),
                              ListTile(
                                leading: const Icon(
                                  Icons.face_retouching_natural_rounded,
                                  color: Color(0xFF00BCD4),
                                ),
                                title: Text(
                                  'Scan Biometrik Wajah',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  'Gunakan Face ID / biometrik sebelum mulai screening.',
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                                onTap: () async {
                                  Navigator.of(sheetContext).pop();
                                  final imageFile =
                                    await BiometricHelper.scanFace(context);
                                  if (!context.mounted) return;

                                  if (imageFile == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Scan wajah gagal atau dibatalkan. Silakan coba lagi atau pilih opsi manual.',
                                          style: GoogleFonts.poppins(),
                                        ),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    return;
                                  }

                                  // Jika scan wajah berhasil, langsung tampilkan hasil deteksi stres biometrik
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => BiometricStressResultPage(
                                        imageFile: imageFile,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(
                                  Icons.edit_note_rounded,
                                  color: Color(0xFF03A9F4),
                                ),
                                title: Text(
                                  'Isi Screening Secara Manual',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  'Langsung menuju form screening tanpa biometrik.',
                                  style:
                                      GoogleFonts.poppins(fontSize: 12),
                                ),
                                onTap: () {
                                  Navigator.of(sheetContext).pop();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ScreeningPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0097A7),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.2),
                  ),
                  child: Text(
                    'Ayo Mulai Sekarang',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 0.3,
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

// Reflection Cards Widget
class _ReflectionCards extends StatelessWidget {
  const _ReflectionCards();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ReflectionCard(
            isDark: isDark,
            icon: '🧘',
            title: 'Tenangkan Pikiran',
            description: 'Luangkan 5 menit untuk bernapas dalam-dalam. Tarik napas perlahan, tahan sebentar, lalu hembuskan. Rasakan ketenangan yang datang.',
            color: const Color(0xFF00BCD4),
          ),
          const SizedBox(width: 16),
          _ReflectionCard(
            isDark: isDark,
            icon: '💭',
            title: 'Ekspresikan Perasaan',
            description: 'Tulis atau ceritakan perasaanmu hari ini. Mengekspresikan emosi dapat membantu Anda memahami diri dengan lebih baik.',
            color: const Color(0xFF03A9F4),
          ),
          const SizedBox(width: 16),
          _ReflectionCard(
            isDark: isDark,
            icon: '🌱',
            title: 'Berkembang Setiap Hari',
            description: 'Perubahan kecil yang konsisten menghasilkan hasil besar. Mulai dari hal sederhana, seperti berjalan pagi atau membaca buku.',
            color: const Color(0xFF00ACC1),
          ),
        ],
      ),
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  final bool isDark;
  final String icon;
  final String title;
  final String description;
  final Color color;

  const _ReflectionCard({
    required this.isDark,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark ? [
            const Color(0xFF2D2D2D),
            const Color(0xFF3D3D3D),
          ] : [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? color.withOpacity(0.2) : Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              icon,
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// Features Grid Widget
class _FeaturesGrid extends ConsumerWidget {
  const _FeaturesGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _FeatureCard(
          icon: Icons.history_rounded,
          title: "Riwayat",
          subtitle: "Lihat hasil screening",
          gradient: const LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
          ),
          onTap: () {
            // Navigasi ke History Page
            final homePageState = context.findAncestorStateOfType<_HomePageState>();
            if (homePageState != null) {
              homePageState._onItemTapped(1);
            }
          },
        ),
        _FeatureCard(
          icon: Icons.article_rounded,
          title: "Artikel",
          subtitle: "Baca tips kesehatan",
          gradient: const LinearGradient(
            colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
          ),
          onTap: () {
            _showArticlesDialog(context);
          },
        ),
        _FeatureCard(
          icon: Icons.phone_in_talk_rounded,
          title: "Konsultasi",
          subtitle: "Hubungi profesional",
          gradient: const LinearGradient(
            colors: [Color(0xFFFF5722), Color(0xFFFF7043)],
          ),
          onTap: () {
            _showConsultationDialog(context);
          },
        ),
        _FeatureCard(
          icon: Icons.support_agent_rounded,
          title: "Bantuan",
          subtitle: "Pusat informasi",
          gradient: const LinearGradient(
            colors: [Color(0xFF00BCD4), Color(0xFF26C6DA)],
          ),
          onTap: () {
            _showHelpDialog(context);
          },
        ),
      ],
    );
  }

  void _showArticlesDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.article_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Artikel Kesehatan Mental',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _ArticleItem(
                title: '5 Cara Mengelola Stres',
                description: 'Pelajari teknik efektif untuk mengurangi stres dalam kehidupan sehari-hari.',
                icon: '📚',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _ArticleItem(
                title: 'Pentingnya Kesehatan Mental',
                description: 'Memahami mengapa kesehatan mental sama pentingnya dengan kesehatan fisik.',
                icon: '🧠',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _ArticleItem(
                title: 'Meditasi untuk Pemula',
                description: 'Panduan memulai praktik meditasi untuk ketenangan pikiran.',
                icon: '🧘',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _ArticleItem(
                title: 'Mengenali Tanda Kecemasan',
                description: 'Identifikasi gejala awal kecemasan dan cara mengatasinya.',
                icon: '⚠️',
                isDark: isDark,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: GoogleFonts.poppins(
                color: const Color(0xFF9C27B0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConsultationDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF5722), Color(0xFFFF7043)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Konsultasi Profesional',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hubungi profesional kesehatan mental untuk konsultasi lebih lanjut:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            _ContactItem(
              icon: Icons.local_hospital_rounded,
              title: 'Hotline Kesehatan Mental',
              subtitle: '119 ext 8 (24/7)',
              color: const Color(0xFFFF5722),
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _ContactItem(
              icon: Icons.psychology_rounded,
              title: 'Konsultasi Psikolog',
              subtitle: 'insightmind@psikolog.id',
              color: const Color(0xFF9C27B0),
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _ContactItem(
              icon: Icons.phone_rounded,
              title: 'WhatsApp Konseling',
              subtitle: '+62 812-3456-7890',
              color: const Color(0xFF25D366),
              isDark: isDark,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: GoogleFonts.poppins(
                color: const Color(0xFFFF5722),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00BCD4), Color(0xFF26C6DA)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Pusat Bantuan',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cara Menggunakan Aplikasi:',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 16),
              _HelpStep(
                number: '1',
                title: 'Lakukan Screening',
                description: 'Klik tombol "Ayo Mulai Sekarang" untuk memulai tes screening kesehatan mental.',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _HelpStep(
                number: '2',
                title: 'Lihat Hasil',
                description: 'Setelah selesai, Anda akan melihat hasil dan rekomendasi.',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _HelpStep(
                number: '3',
                title: 'Cek Riwayat',
                description: 'Pantau perkembangan kesehatan mental Anda melalui menu Riwayat.',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _HelpStep(
                number: '4',
                title: 'Dapatkan Bantuan',
                description: 'Jika diperlukan, hubungi profesional melalui menu Konsultasi.',
                isDark: isDark,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00BCD4).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF00BCD4),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Butuh bantuan lebih lanjut? Hubungi kami di support@insightmind.id',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark ? Colors.grey[300] : const Color(0xFF00BCD4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Mengerti',
              style: GoogleFonts.poppins(
                color: const Color(0xFF00BCD4),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widgets for Dialog Content
class _ArticleItem extends StatelessWidget {
  final String title;
  final String description;
  final String icon;
  final bool isDark;

  const _ArticleItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3D3D3D) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    height: 1.4,
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

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isDark;

  const _ContactItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3D3D3D) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : color,
                    fontWeight: FontWeight.w500,
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

class _HelpStep extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final bool isDark;

  const _HelpStep({
    required this.number,
    required this.title,
    required this.description,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00BCD4), Color(0xFF26C6DA)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DoctorChatPage extends StatefulWidget {
  final String doctorName;
  final String contact;

  const DoctorChatPage({super.key, required this.doctorName, required this.contact});

  @override
  State<DoctorChatPage> createState() => _DoctorChatPageState();
}

class _DoctorChatPageState extends State<DoctorChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat - ${widget.doctorName}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF29ABE2),
                  child: Text(
                    _initial(widget.doctorName),
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(widget.doctorName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (_, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF29ABE2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _messages[index],
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey[300],
                      child: Text(
                        _initial('Anda'),
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Tulis pesan...',
                      hintStyle: GoogleFonts.poppins(fontSize: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _send,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Icon(Icons.send_rounded, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(text);
      _controller.clear();
    });
  }

  String _initial(String text) {
    if (text.isEmpty) return '?';
    return text.trim()[0].toUpperCase();
  }
}

class _ContactRow extends StatelessWidget {
  final String label;
  final String value;

  const _ContactRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy_rounded, size: 18),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: value));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Disalin: $value'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
      ],
    );
  }
}
