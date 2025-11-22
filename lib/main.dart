import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'src/features/auth/presentation/login_screen.dart';
import 'src/features/auth/presentation/registration_screen.dart';
import 'src/features/auth/data/services/auth_service.dart';
import 'src/features/auth/presentation/providers/auth_provider.dart';
import 'src/features/auth/domain/models/user_model.dart';
import 'src/features/dashboard/presentation/dashboard_screen.dart';
import 'src/features/camera/presentation/camera_screen.dart';
import 'src/features/camera/presentation/image_preview_screen.dart';
import 'src/features/profile/presentation/profile_screen.dart';
import 'src/features/complaints/presentation/screens/complaints_screen.dart';
import 'src/features/complaints/presentation/screens/complaint_detail_screen.dart';
import 'src/features/complaints/domain/models/complaint_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  await authService.initialize();
  
  // Create demo users for testing if no users exist
  final allUsers = authService.getAllUsers();
  if (allUsers.isEmpty) {
    await _createDemoUsers(authService);
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(authService),
        ),
      ],
      child: const KrisiBandhuApp(),
    ),
  );
}

Future<void> _createDemoUsers(AuthService authService) async {
  // Demo farmer
  final farmerUser = User(
    userId: 'demo_farmer_001',
    name: 'Demo Farmer',
    email: 'farmer@demo.com',
    phone: '9876543210',
    role: 'farmer',
    password: 'demo123',
    village: 'Demo Village',
    district: 'Demo District',
    state: 'Demo State',
    farmSize: 5.0,
    aadharNumber: '123456789012',
    cropTypes: ['Wheat', 'Rice', 'Maize'],
  );
  
  // Demo official
  final officialUser = User(
    userId: 'demo_official_001',
    name: 'Demo Official',
    email: 'official@demo.com',
    phone: '9876543211',
    role: 'official',
    password: 'demo123',
    officialId: 'OFF-2025-001',
    designation: 'Insurance Officer',
    department: 'Agriculture Insurance',
    assignedDistrict: 'Demo District',
  );
  
  await authService.register(farmerUser);
  await authService.register(officialUser);
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

final GoRouter _buildRouter(BuildContext context) {
  return GoRouter(
    redirect: (BuildContext context, GoRouterState state) {
      final authProvider = context.read<AuthProvider>();
      final isLoggedIn = authProvider.isLoggedIn;
      final isLoggingIn = state.matchedLocation == '/';
      final isRegistering = state.matchedLocation == '/register';

      if (!isLoggedIn && !isLoggingIn && !isRegistering) {
        return '/';
      }
      if (isLoggedIn && (isLoggingIn || isRegistering)) {
        return '/dashboard';
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/register',
        builder: (BuildContext context, GoRouterState state) {
          return const RegistrationScreen();
        },
      ),
      GoRoute(
        path: '/dashboard',
        builder: (BuildContext context, GoRouterState state) {
          return const DashboardScreen();
        },
      ),
      GoRoute(
        path: '/camera',
        builder: (BuildContext context, GoRouterState state) {
          return const CameraScreen();
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'preview',
            builder: (BuildContext context, GoRouterState state) {
              final imagePath = state.extra as String;
              return ImagePreviewScreen(imagePath: imagePath);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        builder: (BuildContext context, GoRouterState state) {
          return const ProfileScreen();
        },
      ),
      GoRoute(
        path: '/complaints',
        builder: (BuildContext context, GoRouterState state) {
          return const ComplaintsScreen();
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'detail',
            builder: (BuildContext context, GoRouterState state) {
              final complaint = state.extra as Complaint;
              return ComplaintDetailScreen(complaint: complaint);
            },
          ),
        ],
      ),
    ],
  );
}

class KrisiBandhuApp extends StatelessWidget {
  const KrisiBandhuApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Color(0xFF2E7D32); // Deep Green
    const Color secondaryColor = Color(0xFFFFA000); // Amber

    final TextTheme appTextTheme = TextTheme(
      displayLarge: GoogleFonts.merriweather(fontSize: 57, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.robotoSlab(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.openSans(fontSize: 14),
      labelLarge: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.bold),
    );

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
        secondary: secondaryColor,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.robotoSlab(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primarySeedColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8.0),

      )
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
        secondary: secondaryColor,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.robotoSlab(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: secondaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
       cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
      )
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          routerConfig: _buildRouter(context),
          title: 'Krashi Bandhu',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
        );
      },
    );
  }
}
