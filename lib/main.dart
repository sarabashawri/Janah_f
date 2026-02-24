import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/user_type_selection_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Guardian imports
import 'screens/guardian/guardian_login_screen.dart';
import 'screens/guardian/guardian_register_screen.dart';
import 'screens/guardian/guardian_forgot_password_screen.dart';
import 'screens/guardian/guardian_home_screen.dart';
import 'screens/guardian/create_report_screen.dart';
import 'screens/guardian/reports_list_screen.dart';
import 'screens/guardian/report_details_screen.dart';
import 'screens/guardian/profile_screen.dart';
import 'screens/guardian/notifications_screen.dart';
import 'screens/guardian/support_screen.dart';
import 'screens/guardian/about_screen.dart';

// Rescuer imports
import 'screens/rescuer/rescuer_login_screen.dart';
import 'screens/rescuer/rescuer_home_screen.dart';
import 'screens/rescuer/missions_list_screen.dart';
import 'screens/rescuer/mission_details_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const JanahApp());
}

class JanahApp extends StatelessWidget {
  const JanahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'جناح - نظام البحث والإنقاذ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [Locale('ar', 'SA')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/user-type': (context) => const UserTypeSelectionScreen(),
        
        // Guardian routes
        '/guardian/login': (context) => const GuardianLoginScreen(),
        '/guardian/register': (context) => const GuardianRegisterScreen(),
        '/guardian/forgot-password': (context) => const GuardianForgotPasswordScreen(),
        '/guardian/home': (context) => const GuardianHomeScreen(),
        '/guardian/create-report': (context) => const CreateReportScreen(),
        '/guardian/reports': (context) => const ReportsListScreen(),
        '/guardian/report-details': (context) => const ReportDetailsScreen(),
        '/guardian/profile': (context) => const ProfileScreen(),
        '/guardian/notifications': (context) => const NotificationsScreen(),
        '/guardian/support': (context) => const SupportScreen(),
        '/guardian/about': (context) => const AboutScreen(),
        
        // Rescuer routes
        '/rescuer/login': (context) => const RescuerLoginScreen(),
        '/rescuer/home': (context) => const RescuerHomeScreen(),
        '/rescuer/missions': (context) => const MissionsListScreen(),
        '/rescuer/mission-details': (context) => const MissionDetailsScreen(),
      },
    );
  }
}
