import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/controllers/auth_controller.dart';
import 'app/controllers/library_controller.dart';
import 'app/models/game.dart';
import 'app/screens/home_shell.dart';
import 'app/screens/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(GameAdapter());
  }
  final libraryBox = await Hive.openBox<Game>('library_games');
  final preferences = await SharedPreferences.getInstance();

  Get.put<SharedPreferences>(preferences);
  Get.put(
    AuthController(
      preferences,
      initialEmail: preferences.getBool('isLoggedIn') == true
          ? preferences.getString('email')
          : null,
    ),
  );
  Get.put(LibraryController(libraryBox));
  runApp(const HydraGamesApp());
}

class HydraGamesApp extends StatelessWidget {
  const HydraGamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF42D392);
    const backgroundColor = Color(0xFF0B0B0D);
    const surfaceColor = Color(0xFF17191F);
    const blueColor = Color(0xFF4F8CFF);

    return GetMaterialApp(
      title: 'Hydra Games',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: Brightness.dark,
              primary: seedColor,
              secondary: blueColor,
              surface: backgroundColor,
            ).copyWith(
              primary: seedColor,
              secondary: blueColor,
              surface: backgroundColor,
              onSurface: Colors.white,
              surfaceContainerLowest: backgroundColor,
              surfaceContainerLow: surfaceColor,
              surfaceContainer: surfaceColor,
              surfaceContainerHigh: const Color(0xFF20232B),
              surfaceContainerHighest: const Color(0xFF282C36),
            ),
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          color: surfaceColor,
          elevation: 1,
          shadowColor: Color(0x33000000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: Color(0xFF2C303A)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: Color(0xFF2C303A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: Color(0xFF2C303A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: seedColor, width: 1.6),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 74,
          backgroundColor: surfaceColor,
          indicatorColor: const Color(0xFF3B2830),
          elevation: 8,
          shadowColor: const Color(0x140F0B1C),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontSize: 12,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ),
      ),
      home: Get.find<AuthController>().isAuthenticated.value
          ? const HomeShell()
          : const LoginPage(),
    );
  }
}
