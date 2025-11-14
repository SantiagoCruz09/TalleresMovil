import 'package:go_router/go_router.dart';
import '../views/home/home_screen.dart';
import '../views/ciclo_vida/ciclo_vida_screen.dart';
import '../views/paso_parametros/detalle_screen.dart';
import '../views/paso_parametros/paso_parametros_screen.dart';
import '../views/buttons/future_screen.dart';
import '../views/buttons/async_screen.dart';
import '../views/buttons/timer_screen.dart';
import '../views/buttons/isolate_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/evidence_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/universidades/universidades_screen.dart';
import '../views/universidades/universidad_form_screen.dart';
import '../views/taller4/taller4_screen.dart';

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
    GoRoute(
      path: '/universidades',
      name: 'universidades',
      builder: (context, state) => const UniversidadesScreen(),
    ),
    GoRoute(
      path: '/universidades/new',
      name: 'universidades_new',
      builder: (context, state) => const UniversidadFormScreen(),
    ),
    GoRoute(
      path: '/universidades/edit/:id',
      name: 'universidades_edit',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return UniversidadFormScreen(id: id);
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
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/evidence',
      name: 'evidence',
      builder: (context, state) => const EvidenceScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/taller4',
      name: 'taller4',
      builder: (context, state) => const Taller4Screen(),
    ),
  ],
);
