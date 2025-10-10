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
import '../views/parcial/parcial_screen.dart';
import '../views/parcial/department_detail.dart';
import '../services/department_service.dart';
import '../models/department.dart';
import '../views/parcial/department_list.dart';
import '../views/parcial/city_list.dart';
import '../views/parcial/city_detail.dart';
import '../views/parcial/president_list.dart';
import '../views/parcial/president_detail.dart';
import '../views/parcial/attraction_list.dart';
import '../views/parcial/attraction_detail.dart';
import '../services/city_service.dart';
import '../services/president_service.dart';
import '../services/touristic_attraction_service.dart';
import '../models/city.dart';
import '../models/president.dart';
import '../models/touristic_attraction.dart';

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
    GoRoute(
      path: '/parcial',
      name: 'parcial',
      builder: (context, state) => const ParcialScreen(),
    ),
    GoRoute(
      path: '/parcial/departments',
      name: 'parcial_departments',
      builder: (context, state) => DepartmentListScreen(service: DepartmentService(baseUrl: 'https://api-colombia.com')),
    ),
    GoRoute(
      path: '/parcial/cities',
      name: 'parcial_cities',
      builder: (context, state) => CityListScreen(service: CityService(baseUrl: 'https://api-colombia.com')),
    ),
    GoRoute(
      path: '/parcial/city/:id',
      name: 'parcial_city_detail',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final extra = state.extra;
        final City? city = extra is City ? extra : null;
        return CityDetailScreen(id: id, item: city, service: CityService(baseUrl: 'https://api-colombia.com'));
      },
    ),
    GoRoute(
      path: '/parcial/presidents',
      name: 'parcial_presidents',
      builder: (context, state) => PresidentListScreen(service: PresidentService(baseUrl: 'https://api-colombia.com')),
    ),
    GoRoute(
      path: '/parcial/president/:id',
      name: 'parcial_president_detail',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final extra = state.extra;
        final President? pres = extra is President ? extra : null;
        return PresidentDetailScreen(id: id, item: pres, service: PresidentService(baseUrl: 'https://api-colombia.com'));
      },
    ),
    GoRoute(
      path: '/parcial/attractions',
      name: 'parcial_attractions',
      builder: (context, state) => AttractionListScreen(service: TouristicAttractionService(baseUrl: 'https://api-colombia.com')),
    ),
    GoRoute(
      path: '/parcial/attraction/:id',
      name: 'parcial_attraction_detail',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final extra = state.extra;
        final TouristicAttraction? att = extra is TouristicAttraction ? extra : null;
        return AttractionDetailScreen(id: id, item: att, service: TouristicAttractionService(baseUrl: 'https://api-colombia.com'));
      },
    ),
    GoRoute(
      path: '/parcial/department/:id',
      name: 'parcial_department_detail',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final extra = state.extra;
  final Department? department = extra is Department ? extra : null;
        return DepartmentDetailScreen(id: id, item: department, service: DepartmentService(baseUrl: 'https://api-colombia.com'));
      },
    ),
  ],
);
