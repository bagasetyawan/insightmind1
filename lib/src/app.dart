import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../features/insightmind/presentation/pages/home_page.dart';

class InsightMindApp extends ConsumerWidget {
  const InsightMindApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'InsightMind',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: lightTheme.copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      darkTheme: darkTheme.copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      home: const HomePage(),
      routes: {
        '/screening': (context) => const Placeholder(),
      },
    );
  }
}
