
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
```

Notas y próximos pasos sugeridos
-------------------------------
- Cambiar imágenes remotas por assets locales para funcionamiento offline.
- Centralizar temas en `lib/themes/app_theme.dart` (ya existe una configuración base).
- Reemplazar `print` por `debugPrint` o `logging` para mejor control de salida.
- Añadir tests unitarios y de widget para las pantallas críticas.

Demos de concurrencia/async
---------------------------
- `FutureScreen` (`lib/views/buttons/future_screen.dart`): demo que muestra cómo lanzar un `Future` (simulación de llamada de red con `Future.delayed`) y actualizar la UI cuando completa. Imprime progreso en consola con `debugPrint` y muestra un indicador de carga mientras se ejecuta.
- `AsyncScreen` (`lib/views/buttons/async_screen.dart`): demo de `async`/`await` que encapsula tareas asíncronas en un método `async`, usa banderas `_running` para deshabilitar botones y registra inicio/fin en la consola.
- `TimerScreen` (`lib/views/buttons/timer_screen.dart`): demo que usa `Timer.periodic` para emitir ticks periódicos, actualizar la UI con los segundos transcurridos y cancelar el `Timer` en `dispose`.

Cronómetro (implementación detallada)
-----------------------------------
- La pantalla `TimerScreen` implementa un cronómetro completo pensado para cumplir exactamente el requisito:
	- Botones: Iniciar / Pausar / Reanudar / Reiniciar.
	- Actualización del tiempo: por defecto cada 100 ms (se puede ajustar a 1000 ms para 1 s cambiando la constante `_tickMs`).
	- Limpieza de recursos: el `Timer` se cancela en `dispose()` y también al pausar o reiniciar, evitando fugas de memoria o llamadas fuera de la vista.
	- Visualización: el tiempo se muestra en un `Text` grande con formato `MM:SS.cc` (minutos:segundos.centisegundos) para que funcione como un marcador.
	- Comportamiento: al iniciar se crea un `Timer.periodic`, al pausar se cancela el timer y se guarda el tiempo transcurrido, al reanudar se vuelve a crear el timer continuando desde el tiempo guardado, y al reiniciar vuelve a cero.
	- Logs: la implementación emite `debugPrint` en eventos clave (start/pause/resume/reset y cada tick) para seguimiento en la consola.


Actualización reciente: demo de Isolate
-------------------------------------
- Se actualizó el demo de Isolate (`lib/views/buttons/isolate_screen.dart`) para usar `compute()` en lugar de manejar `Isolate.spawn` y puertos manualmente. `compute()` usa isolates internamente y simplifica la ejecución de funciones pesadas en background.
- La tarea ahora acepta un parámetro `iterations` y por defecto en la demo se ejecutan 10 iteraciones (configurables). Cada iteración realiza un bucle interno que se puede ajustar con la constante `inner` en la función `heavyComputation`.
- Se añadió un `timeout` de 30 segundos para evitar que la UI quede esperando indefinidamente; en caso de timeout se muestra `Resultado: Timeout al ejecutar la tarea`.
- Recomendación: si necesitas comunicación más compleja (mensajes continuos o streams), vuelve al patrón manual con `ReceivePort/SendPort` pero asegurando cierre y manejo de excepciones. Para tareas puntuales y puras, `compute()` es la vía preferida.

Conclusiones
--------------------------------
He priorizado claridad educativa y una UI limpia. La estructura con `go_router` y widgets reutilizables facilita extender la app. Si implementas assets locales y un sistema de logging, la app tendrá una base sólida para producción.

APPI — Integración con Art Institute of Chicago API
--------------------------------------------------
Se añadió una integración experimental para consumir la API pública de Art Institute of Chicago (endpoint usado: `https://api.artic.edu/api/v1/artworks`). Esta integración incluye:

- Servicio: `lib/services/appi_service.dart`
	- Métodos principales:
		- `fetchItems({int page = 1, int limit = 12})` — solicita la lista de obras y devuelve una `List<AppiItem>`.
		- `fetchItemById(String id)` — solicita el detalle de una obra por `id`.
	- Logs en consola usando `debugPrint` para indicar cuando se solicita una página, cuántos items llegaron y los ids/títulos de los items obtenidos.

- Modelo: `lib/models/appi_item.dart`
	- Campos mapeados (ejemplo): `id`, `title`, `description`, `image_id`, `imageUrl`, `artistDisplay`, `placeOfOrigin`, `dateDisplay`.
	- La descripción se sanea (se eliminan tags HTML simples) para evitar que aparezcan etiquetas en la UI.
	- Si `image_id` existe se construye una URL IIIF (`https://www.artic.edu/iiif/2/{image_id}/full/{width},/0/default.jpg`) como fuente preferente de la imagen.

- Vistas:
	- Listado: `lib/views/appi/list_screen.dart`
		- Muestra título, artista, lugar, fecha y una descripción corta (saneada).
		- Usa `AdaptiveNetworkImage` (`lib/widgets/adaptive_network_image.dart`) para intentar cargar una o varias fuentes de imagen y evitar mostrar imágenes rotas.
		- Incluye un botón en el AppBar para volver al Home.
		- Incluye un toggle en el AppBar para ocultar items sin imagen (por defecto ocultos), útil para evitar mostrar resultados con imágenes dañadas.
	- Detalle: `lib/views/appi/detail_screen.dart`
		- Muestra la imagen grande (con fallback placeholder si falla), título, artistDisplay, placeOfOrigin, dateDisplay y descripción completa.
		- Botón "Volver" que intenta `pop()` y, si no hay historial, hace `goNamed('appi')` para volver al listado.

Notas importantes y limitaciones
- Algunas imágenes devueltas por la API pueden responder con 403 o estar inaccesibles desde ciertas ubicaciones; por eso implementamos:
	- Fallbacks en `AdaptiveNetworkImage` y uso del campo `thumbnail.lqip` cuando esté disponible.
	- Opción en la UI para ocultar los elementos que no tengan imagen disponible.
- La integración actual no persiste caché de imágenes ni realiza HEAD checks (lo cual podría incrementar la latencia). Si quieres, puedo añadir caching (p. ej. con `cached_network_image`) o comprobaciones HEAD para filtrar items con imágenes inaccesibles antes de mostrarlos.

Cómo probar la integración APPI
1. Ejecuta desde la raíz del proyecto:

```bash
flutter pub get
flutter run
```

2. Abre el Drawer y selecciona "APPI".
3. Observa la consola donde ejecutaste `flutter run` para ver los `debugPrint` con el progreso de la petición (p. ej. items recibidos, ids, errores de petición si los hay).

Mejoras posibles (opcional):
- Paginación / carga infinita para navegar más resultados.
- Probar varias construcciones IIIF (distintos `width`) antes de caer a `thumbnail.lqip` para reducir 403.
- Añadir cache de imágenes con `cached_network_image`.
- Extraer más campos en `AppiItem` (por ejemplo `medium_display`, `credit_line`, `dimensions`) para enriquecer la pantalla de detalle.

Si quieres que documente en el README ejemplos de JSON retornado o copie un ejemplo concreto de la respuesta para pruebas offline, dímelo y lo agrego sin modificar lo que ya existe.