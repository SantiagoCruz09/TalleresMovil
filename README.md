
# TalleresMovi2 - Grupo 2

Resumen
-------
Este proyecto es una aplicación Flutter de ejemplo desarrollada como parte del Taller 2. Incluye una estructura sencilla de rutas con `go_router`, varias pantallas de demostración (Home, Ciclo de Vida, Paso de Parámetros) y widgets reutilizables (`BaseView`, `CustomDrawer`). El objetivo del README es explicar la arquitectura, las rutas, cómo se pasan parámetros, y justificar las decisiones de diseño y widgets usados.

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
```

Notas y próximos pasos sugeridos
-------------------------------
- Cambiar imágenes remotas por assets locales para funcionamiento offline.
- Centralizar temas en `lib/themes/app_theme.dart` (ya existe una configuración base).
- Reemplazar `print` por `debugPrint` o `logging` para mejor control de salida.
- Añadir tests unitarios y de widget para las pantallas críticas.

Conclusiones (opinión del autor)
--------------------------------
He priorizado claridad educativa y una UI limpia. La estructura con `go_router` y widgets reutilizables facilita extender la app. Si implementas assets locales y un sistema de logging, la app tendrá una base sólida para producción.

Si quieres, actualizo el README para incluir diagramas de rutas, agregar instrucciones para generar assets locales, o añadir ejemplos de tests. Dime qué prefieres y lo hago.
