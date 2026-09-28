import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/account/screens/account_screen.dart';
import '../features/affiliate/screens/generate_link_screen.dart';
import '../features/affiliate/screens/my_links_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/cashback/screens/cashback_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/orders/screens/order_detail_screen.dart';
import '../features/orders/screens/orders_screen.dart';
import '../features/shell/screens/app_shell.dart';
import '../features/wallet/screens/wallet_screen.dart';
import '../features/withdrawals/screens/new_withdrawal_screen.dart';
import '../features/withdrawals/screens/withdrawal_history_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _ordersNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'orders');
final _walletNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'wallet');
final _accountNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'account');

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authProvider,
      (_, __) => notifyListeners(),
    );
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authProvider);

    if (!authState.isInitialChecked) {
      return null;
    }

    final isLoggingIn = state.matchedLocation == '/login';
    if (!authState.isAuthenticated) {
      return isLoggingIn ? null : '/login';
    }

    if (isLoggingIn) {
      return '/app';
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  final notifier = RouterNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/app',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // App Shell with 4 tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0: Home / Dashboard
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/app',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // Tab 1: Orders
          StatefulShellBranch(
            navigatorKey: _ordersNavigatorKey,
            routes: [
              GoRoute(
                path: '/app/orders',
                builder: (context, state) => const OrdersScreen(),
              ),
            ],
          ),

          // Tab 2: Wallet
          StatefulShellBranch(
            navigatorKey: _walletNavigatorKey,
            routes: [
              GoRoute(
                path: '/app/wallet',
                builder: (context, state) => const WalletScreen(),
              ),
            ],
          ),

          // Tab 3: Account
          StatefulShellBranch(
            navigatorKey: _accountNavigatorKey,
            routes: [
              GoRoute(
                path: '/app/account',
                builder: (context, state) => const AccountScreen(),
              ),
            ],
          ),
        ],
      ),

      // Subroutes
      GoRoute(
        path: '/app/links/new',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const GenerateLinkScreen(),
      ),
      GoRoute(
        path: '/app/links',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MyLinksScreen(),
      ),
      GoRoute(
        path: '/app/orders/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return OrderDetailScreen(orderId: id);
        },
      ),
      GoRoute(
        path: '/app/cashback',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CashbackScreen(),
      ),
      GoRoute(
        path: '/app/withdrawals/new',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NewWithdrawalScreen(),
      ),
      GoRoute(
        path: '/app/withdrawals',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WithdrawalHistoryScreen(),
      ),
    ],
  );
});
