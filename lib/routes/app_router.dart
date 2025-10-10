import 'package:go_router/go_router.dart';
import '../views/home/home_screen.dart';
import '../views/ciclo_vida/ciclo_vida_screen.dart';
import '../views/paso_parametros/detalle_screen.dart';
import '../views/paso_parametros/paso_parametros_screen.dart';
import '../views/buttons/future_screen.dart';
import '../views/buttons/async_screen.dart';
import '../views/buttons/timer_screen.dart';
import '../views/buttons/isolate_screen.dart';
import '../models/appi_item.dart';
import '../views/appi/list_screen.dart';
import '../views/appi/detail_screen.dart';
import '../services/appi_service.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/ciclo',
      name: 'ciclo',
      builder: (context, state) => const CicloVidaScreen(),
    ),
    GoRoute(
      path: '/parametros',
      name: 'parametros',
      builder: (context, state) => const PasoParametrosScreen(),
    ),
    GoRoute(
      path: '/future',
      name: 'future',
      builder: (context, state) => const FutureScreen(),
    ),
    GoRoute(
      path: '/async',
      name: 'async',
      builder: (context, state) => const AsyncScreen(),
    ),
    GoRoute(
      path: '/timer',
      name: 'timer',
      builder: (context, state) => const TimerScreen(),
    ),
    GoRoute(
      path: '/isolate',
      name: 'isolate',
      builder: (context, state) => const IsolateScreen(),
    ),
    // APPI: listado y detalle
    GoRoute(
      path: '/appi',
      name: 'appi',
      builder: (context, state) => AppiListScreen(
        service: AppiService(baseUrl: 'https://api.artic.edu/api/v1/artworks'),
      ),
    ),
    GoRoute(
      path: '/appi/:id',
      name: 'appi_detail',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final extra = state.extra;
        final AppiItem? item = extra is AppiItem ? extra : null;
        return AppiDetailScreen(id: id, item: item, service: AppiService(baseUrl: 'https://api.artic.edu/api/v1/artworks'));
      },
    ),
    GoRoute(
      path: '/detalle/:mensaje',
      name: 'detalle',
      builder: (context, state) {
        final mensaje = state.pathParameters['mensaje'] ?? 'Sin mensaje';
        return DetalleScreen(mensaje: mensaje);
      },
    ),
  ],
);
