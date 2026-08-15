import 'package:go_router/go_router.dart';
import '../../features/college_search/college_search_screen.dart';
import '../../features/navigation/main_navigation_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/student_register_screen.dart';
import '../../features/student/student_home_screen.dart';
import '../../features/parent/parent_home_screen.dart';
import '../../features/student/student_documents_screen.dart';
import '../../features/chatbot/student_chat_screen.dart';
import '../services/auth_service.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) async {
    final isLoggedIn = AuthService.isLoggedIn;
    final isAuthRoute = state.uri.path == '/login' || 
                        state.uri.path == '/register' || 
                        state.uri.path == '/auth';
    
    // If already logged in and trying to go to login/register/auth, redirect to app.
    // Always allow /splash to play its full luxury animation before routing!
    if (isLoggedIn && isAuthRoute) {
      return '/app';
    }
    
    return null; // Let the splash screen and other routes render smoothly
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/search-college',
      builder: (context, state) => const CollegeSearchScreen(),
    ),
    GoRoute(
      path: '/app',
      builder: (context, state) => const MainNavigationScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) {
        final role = state.uri.queryParameters['role'] ?? 'student';
        return LoginScreen(role: role);
      },
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const StudentRegisterScreen(),
    ),
    GoRoute(
      path: '/student-home',
      builder: (context, state) => const StudentHomeScreen(),
    ),
    GoRoute(
      path: '/parent-home',
      builder: (context, state) => const ParentHomeScreen(),
    ),
    GoRoute(
      path: '/student-documents',
      builder: (context, state) {
        final category = state.uri.queryParameters['category'] ?? 'document';
        return StudentDocumentsScreen(category: category);
      },
    ),
    GoRoute(
      path: '/student-chat',
      builder: (context, state) => const StudentChatScreen(),
    ),
  ],
);
