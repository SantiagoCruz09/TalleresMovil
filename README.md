
# TalleresMovil 

Santiago Alejandro Santacruz Cuellar

230222033
Resumen
-------
Este proyecto es una aplicación Flutter de ejemplo desarrollada como parte del Taller 2. Incluye una estructura sencilla de rutas con `go_router`, varias pantallas de demostración (Home, Ciclo de Vida, Paso de Parámetros) y widgets reutilizables (`BaseView`, `CustomDrawer`). El objetivo del README es explicar la arquitectura, las rutas, cómo se pasan parámetros, y justificar las decisiones de diseño y widgets usados.

Actualizaciones recientes: se añadieron demos sobre concurrencia y asincronía (ejemplos de `Future`, `async/await` y `Timer`) y se actualizó el demo de `Isolate` para usar `compute()` con soporte de iteraciones configurables y timeout para evitar bloqueos en la UI.

Arquitectura y navegación
------------------------
- `MaterialApp.router` con `go_router` (archivo: `lib/routes/app_router.dart`).
- Rutas principales definidas:
	- `/` (name: `home`) → `lib/views/home/home_screen.dart` (HomeScreen)
	- `/ciclo` (name: `ciclo`) → `lib/views/ciclo_vida/ciclo_vida_screen.dart` (CicloVidaScreen)
	- `/parametros` (name: `parametros`) → `lib/views/paso_parametros/paso_parametros_screen.dart` (PasoParametrosScreen)
	- `/detalle/:mensaje` (name: `detalle`) → `lib/views/paso_parametros/detalle_screen.dart` (DetalleScreen)

Paso de parámetros
------------------
- Parámetros sencillos se envían por la ruta (path parameter):
	- Ejemplo: `context.go('/detalle/Hola desde go()')` o `context.push('/detalle/Hola desde push()')`.
	- En `DetalleScreen` el parámetro se recibe desde `GoRouter` y se inyecta al constructor: `DetalleScreen(mensaje: mensaje)`.
- En `DetalleScreen` se registra en consola mediante `debugPrint` y se muestra en la UI "Mensaje recibido: ... (Se registró en la consola)".

Widgets principales y por qué se eligieron
-----------------------------------------
- `BaseView` (`lib/widgets/base_view.dart`)
	- Propósito: wrapper reutilizable para pantallas con `AppBar`, `Drawer` y `floatingActionButton` opcional.
	- Razón: evita duplicación y centraliza la estructura común de las pantallas.

- `CustomDrawer` (`lib/widgets/custom_drawer.dart`)
	- Propósito: menú lateral con navegación a las rutas principales.
	- Razón: proporciona un punto único para agregar navegación y futuros ítems.

- `HomeScreen` (`lib/views/home/home_screen.dart`)
	- Contiene un encabezado visual (imagen), cards tipo showcase, botones de acción y tabs.
	- Razón: demuestra un layout más profesional y componentes interactivos (GridView, Card, InkWell).

- `CicloVidaScreen` (`lib/views/ciclo_vida/ciclo_vida_screen.dart`)
	- Demo para observar métodos del ciclo de vida (`initState`, `build`, `dispose`, etc.).
	- Incluye `LifecycleChild` para forzar `initState`/`dispose` al mostrar/ocultar.
	- Razón: educativo — útil para entender cuándo Flutter reconstruye widgets.

- `PasoParametrosScreen` y `DetalleScreen` (`lib/views/paso_parametros/*`)
	- Propósito: enseñar diferentes formas de navegar con `go_router` (`go`, `push`, `replace`) y recibir parámetros.
	- Razón: muestra patrones comunes para pasar datos simples por rutas.

Decisiones de diseño
--------------------
- Uso de `go_router` facilita rutas nombradas y parámetros en path. Es más mantenible que `Navigator.pushNamed` en apps con rutas complejas.
- Uso de `Card`, `InkWell` y `ClipRRect` para crear una UI con aspecto moderno (elevación, esquinas redondeadas, imágenes recortadas).
- Las imágenes actualmente se cargan desde Unsplash (URLs públicas). Para producción se recomienda moverlas a `assets/`.
- Los logs de ciclo de vida usan `print`/`debugPrint`. Para una app real se recomienda usar la librería `logging` o persistir eventos en un backend o archivo local.

Cómo ejecutar
------------
1. Asegúrate de tener Flutter instalado y configurado en tu máquina.
2. Desde la carpeta del proyecto:

```bash
flutter pub get
flutter analyze
flutter run

-------
Aplicación Flutter de ejemplo usada en el Taller 2. Contiene demos de navegación, concurrencia y ahora integra dos APIs públicas:

- API Art Institute (APPI): listado y detalle de obras (ya disponible en el menú APPI).
- API-Colombia (parcial): listados y detalle para
	- Departamentos
	- Ciudades
	- Presidentes
	- Atracciones turísticas

La app usa `go_router` para navegación, `http` para peticiones y patrones separados por capas (models/services/views).

Arquitectura y navegación
------------------------
- `MaterialApp.router` con `go_router` (`lib/routes/app_router.dart`).
- Rutas relevantes añadidas (entre otras):
	- `/parcial` → `lib/views/parcial/parcial_screen.dart` (pantalla central del parcial con botones hacia los listados)
	- `/parcial/departments` → listado Departamentos (`lib/views/parcial/department_list.dart`)
	- `/parcial/department/:id` → detalle Departamento (`lib/views/parcial/department_detail.dart`)
	- `/parcial/cities` → listado Ciudades (`lib/views/parcial/city_list.dart`)
	- `/parcial/city/:id` → detalle Ciudad (`lib/views/parcial/city_detail.dart`)
	- `/parcial/presidents` → listado Presidentes (`lib/views/parcial/president_list.dart`)
	- `/parcial/president/:id` → detalle Presidente (`lib/views/parcial/president_detail.dart`)
	- `/parcial/attractions` → listado Atracciones (`lib/views/parcial/attraction_list.dart`)
	- `/parcial/attraction/:id` → detalle Atracción (`lib/views/parcial/attraction_detail.dart`)
	- `/appi` y `/appi/:id` → integraciones APPI (Art Institute)

Cómo acceder
------------
- Abre el Drawer y pulsa "Parcial" para ir a la pantalla central del parcial. Desde allí accede a los listados.

Integración API-Colombia (parcial)
---------------------------------
Se implementó una integración mínima con la API pública de Colombia para consumir los endpoints mencionados. Cambios principales:

- Models: `lib/models/department.dart`, `lib/models/city.dart`, `lib/models/president.dart`, `lib/models/touristic_attraction.dart`.
- Services: `lib/services/department_service.dart`, `lib/services/city_service.dart`, `lib/services/president_service.dart`, `lib/services/touristic_attraction_service.dart`.
- Views (list y detail): `lib/views/parcial/*_list.dart`, `lib/views/parcial/*_detail.dart`.

Notas técnicas sobre el parsing
- Las respuestas de la API pueden llegar en dos formatos comunes: una lista directa o un wrapper `{ "data": [...] }`. Los servicios manejan ambos casos.
- Los modelos usan parsing defensivo: funciones helper para convertir `String`/`num` a `int`/`double` y extraer campos anidados (por ejemplo `department` dentro de una `city`). Esto evita errores cuando los tipos vienen como strings o cuando hay objetos anidados.

Diseño y UX de los listados
---------------------------
- Listados actualizados con un estilo más profesional:
	- Uso de `Card` + `ListTile` con `CircleAvatar` (iniciales), subtítulos con metadatos y `trailing` con flecha.
	- `RefreshIndicator` para pull-to-refresh.
	- Manejo de estados: carga, error y vacío con mensajes claros.
	- Botón de volver en AppBar que lleva a la pantalla `/parcial`.

Registros / Logs
---------------
- Se añadieron `debugPrint` en:
	- Cada pantalla de listado (registro al entrar y cuando llegan los items).
	- Cada servicio HTTP (registro al iniciar la petición, elementos parseados y errores por item).
- Para ver los logs abre la app con `flutter run` y observa la consola. Ejemplos:
	- DepartmentListScreen: init - solicitando departamentos
	- DepartmentService: GET https://api-colombia.com/api/v1/Department
	- DepartmentService: items parseados=42
	- DepartmentListScreen: items obtenidos=42

Pruebas y ejecución
-------------------
1. Obtener dependencias:

```powershell
flutter pub get
```

2. Analizar el proyecto:

```powershell
flutter analyze
```

3. Ejecutar en un dispositivo o emulador y ver logs:

```powershell
flutter run
```

Desde la app: Drawer → Parcial → elegir listado (Departamentos/Ciudades/Presidentes/Atracciones o APPI). Hacer pull-to-refresh para recargar.

Errores y manejo defensivo
-------------------------
- Si la API devuelve arrays mixtos o strings en lugar de objetos, los servicios filtran elementos no-Map y registran en consola los items ignorados. Esto evita que la UI se rompa por formatos inesperados.
- En caso de respuestas anidadas, los modelos intentan extraer el campo correcto (por ejemplo `department.id` dentro de `city`). Si necesitas modelos más exactos (Country, Region, Maps, NaturalAreas, etc.) puedo añadir clases anidadas y mapearlas explícitamente.

Ficheros importantes añadidos (resumen)
--------------------------------------
- Models: `lib/models/department.dart`, `lib/models/city.dart`, `lib/models/president.dart`, `lib/models/touristic_attraction.dart`
- Services: `lib/services/department_service.dart`, `lib/services/city_service.dart`, `lib/services/president_service.dart`, `lib/services/touristic_attraction_service.dart`
- Views: `lib/views/parcial/parcial_screen.dart`, `lib/views/parcial/*_list.dart`, `lib/views/parcial/*_detail.dart`, además de las pantallas APPI ya existentes en `lib/views/appi/`.
- Router: rutas añadidas en `lib/routes/app_router.dart`.


Parcial
--------------------------------------

- Rutas y vistas nuevas: se agregó navegación y pantallas para consumir la API-Colombia (Departamentos, Ciudades, Presidentes, Atracciones). Las rutas relevantes están listadas en la sección "Arquitectura y navegación" arriba.
- Modelos y servicios: creación de modelos defensivos y servicios HTTP que aceptan respuestas con wrapper `{ "data": [...] }` o listas directas. Archivos en `lib/models/` y `lib/services/`.
- UI mejorada para listados: cada listado utiliza `Card` + `ListTile`, `RefreshIndicator`, manejo de estados (carga/error/vacío) y un botón de volver en el `AppBar` que regresa a `/parcial`.
- Logs detallados: todos los listados y servicios emiten `debugPrint` para:
	- indicar cuando se inicia una petición HTTP (URL)
	- informar cuántos items válidos fueron parseados
	- registrar items ignorados o errores de parseo por elemento
	- informar cuando la pantalla recibe la lista (conteo)

- Parsing defensivo: los modelos usan helpers para convertir `String`/`num` a `int`/`double` y extraer campos anidados de objetos JSON, evitando errores de tipado en tiempo de ejecución.

- Botón "volver": cada listado ahora muestra un icono de back en el `AppBar` que lleva a la pantalla `/parcial`. Si prefieres que haga `context.pop()` en vez de `context.go('/parcial')`, dímelo y lo cambio.


