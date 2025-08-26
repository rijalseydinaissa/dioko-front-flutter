import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payments_app/features/auth/presentation/login_screen.dart';
import 'package:payments_app/features/auth/presentation/register_screen.dart';
import 'package:payments_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:payments_app/features/payments/presentation/payment_form_screen.dart';
import 'package:payments_app/features/payments/presentation/payments_list_screen.dart';
import 'package:payments_app/features/payments/presentation/payment_detail_screen.dart';
import 'package:payments_app/features/auth/data/auth_repository.dart';

final _rootNavKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavKey,
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
    GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
    GoRoute(
      path: '/',
      redirect: (ctx, state) async {
        final container = ProviderScope.containerOf(ctx);
        final authed = await container.read(authRepositoryProvider).isAuthenticated();
        return authed ? '/dashboard' : '/login';
      },
    ),
    GoRoute(path: '/dashboard', builder: (c, s) => const DashboardScreen()),
    GoRoute(path: '/payments', builder: (c, s) => const PaymentsListScreen()),
    GoRoute(path: '/payments/new', builder: (c, s) => const PaymentFormScreen()),
    GoRoute(
      path: '/payments/:id',
      builder: (c, s) => PaymentDetailScreen(paymentId: s.pathParameters['id']!),
    ),
  ],
);