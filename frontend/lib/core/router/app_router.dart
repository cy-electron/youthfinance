import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/shell/presentation/screens/app_shell.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/fun_fund/presentation/screens/fun_fund_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',

    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const AppShell(),
      ),

      GoRoute(  
        path: '/fun-fund',
        builder: (context, state) => const FunFundScreen(),
      ),
    ],
  );

  ref.listen<AsyncValue>(authProvider, (_, next) {
    final user = next.valueOrNull;

    if (user == null) {
      router.go('/login');
    }
  });

  return router;
});
