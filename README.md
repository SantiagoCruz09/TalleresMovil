
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

## Nuevo: Login y evidencia de sesión

Se añadió una funcionalidad de autenticación de prueba para el flujo de demostración y evidencias. No se elimina nada del README original; a continuación se describe lo nuevo.

- Botón Login en el Drawer: ahora el `CustomDrawer` incluye un ítem "Login" que abre la ruta `/login`.

- `LoginScreen` (`/login`):
	- Interfaz con campos de correo y contraseña, precargados para pruebas con:
		- Email: `santiagocuellar0908@gmail.com`
		- Contraseña: `Santiago315`
	- Checkbox "Recordarme": si el usuario lo marca se guardan credenciales seguras en `flutter_secure_storage` (keys: `saved_email`, `saved_password`).
	- Al ingresar correctamente (credenciales de prueba), el flujo hace lo siguiente:
		- Guarda datos no sensibles en `SharedPreferences`: `id` (ej. "9"), `name` ("Santiago Cuellar") y `email`.
		- Guarda en `flutter_secure_storage` valores sensibles: `access_token` (token demo), `token_type` (por ejemplo "bearer") y `expires_in` (segundos, p. ej. "7200").
		- Navega automáticamente a la ruta `/evidence`.

- `EvidenceScreen` (`/evidence`): pantalla de evidencia que muestra:
	- ID, nombre y email leídos desde `SharedPreferences` (datos no sensibles).
	- Card con el Token JWT enmascarado y un botón para copiar el token al portapapeles.
	- Card con Tipo de token (por ejemplo `bearer`).
	- Card con tiempo de expiración (en segundos).
	- Botón "Cerrar sesión" que borra `id`, `name`, `email` de `SharedPreferences` y borra `access_token`, `refresh_token`, `token_type`, `expires_in`, `saved_email`, `saved_password` de `flutter_secure_storage`, luego regresa a la pantalla principal.

- Dependencias añadidas:
	- `flutter_secure_storage` (para almacenamiento seguro de credenciales y tokens).
	- `shared_preferences` (para datos no sensibles como nombre, email y id).

Cómo probar lo nuevo
1. Instalar dependencias y ejecutar la app:
```powershell
cd 'c:\Users\ASUS\Documents\Mobiles\grupo_2'
flutter pub get
flutter analyze
flutter run
````markdown

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

Conclusiones
--------------------------------
He priorizado claridad educativa y una UI limpia. La estructura con `go_router` y widgets reutilizables facilita extender la app. Si implementas assets locales y un sistema de logging, la app tendrá una base sólida para producción.

## Nuevo: Login y evidencia de sesión

Se añadió una funcionalidad de autenticación de prueba para el flujo de demostración y evidencias. No se elimina nada del README original; a continuación se describe lo nuevo.

- Botón Login en el Drawer: ahora el `CustomDrawer` incluye un ítem "Login" que abre la ruta `/login`.

- `LoginScreen` (`/login`):
	- Interfaz con campos de correo y contraseña, precargados para pruebas con:
		- Email: `santiagocuellar0908@gmail.com`
		- Contraseña: `Santiago315`
	- Checkbox "Recordarme": si el usuario lo marca se guardan credenciales seguras en `flutter_secure_storage` (keys: `saved_email`, `saved_password`).
	- Al ingresar correctamente (credenciales de prueba), el flujo hace lo siguiente:
		- Guarda datos no sensibles en `SharedPreferences`: `id` (ej. "9"), `name` ("Santiago Cuellar") y `email`.
		- Guarda en `flutter_secure_storage` valores sensibles: `access_token` (token demo), `token_type` (por ejemplo "bearer") y `expires_in` (segundos, p. ej. "7200").
		- Navega automáticamente a la ruta `/evidence`.

- `EvidenceScreen` (`/evidence`): pantalla de evidencia que muestra:
	- ID, nombre y email leídos desde `SharedPreferences` (datos no sensibles).
	- Card con el Token JWT enmascarado y un botón para copiar el token al portapapeles.
	- Card con Tipo de token (por ejemplo `bearer`).
	- Card con tiempo de expiración (en segundos).
	- Botón "Cerrar sesión" que borra `id`, `name`, `email` de `SharedPreferences` y borra `access_token`, `refresh_token`, `token_type`, `expires_in`, `saved_email`, `saved_password` de `flutter_secure_storage`, luego regresa a la pantalla principal.

- Dependencias añadidas:
	- `flutter_secure_storage` (para almacenamiento seguro de credenciales y tokens).
	- `shared_preferences` (para datos no sensibles como nombre, email y id).

Cómo probar lo nuevo
1. Instalar dependencias y ejecutar la app:
```powershell
cd 'c:\Users\ASUS\Documents\Mobiles\grupo_2'
flutter pub get
flutter analyze
flutter run
```
2. En la app:
	- Abrir el Drawer y tocar "Login".
	- Verás el formulario con email y contraseña ya llenos.
	- (Opcional) Marcar "Recordarme" para que las credenciales se guarden en almacenamiento seguro.
	- Pulsar "Ingresar" → se navegará a "Evidencia de sesión" donde aparecerán ID, nombre, email, token (enmascarado), tipo y expiración.
	- Pulsar "Cerrar sesión" limpia los datos guardados y vuelve al Home.

````

## Solución práctica para CORS (Registro)

Si al probar el registro desde el navegador recibes un mensaje como "XMLHttpRequest error" o la petición aparece bloqueada, aquí tienes una guía práctica que agregamos al repositorio para resolver el bloqueo durante el desarrollo.

1) Proxy local (recomendado para pruebas desde web)

   - Hemos añadido un proxy de desarrollo en `tools/cors-proxy/` que reenvía peticiones al destino y agrega cabeceras CORS permisivas.
   - Archivos disponibles:
     - `tools/cors-proxy/server.js`
     - `tools/cors-proxy/package.json`
     - `tools/cors-proxy/README.md`
   - Pasos rápidos para usarlo (PowerShell):
```powershell
cd 'C:\Users\ASUS\Documents\Mobiles\grupo_2\tools\cors-proxy'
npm install
node server.js
# o npm start
```
   - En la app (pantalla Registro) marca "Usar proxy CORS (solo para pruebas)" y deja `http://localhost:8080/` (prellenado). La app hará la petición a:

```
http://localhost:8080/https://parking.visiontic.com.co/api/users
```

   - Nota: el proxy es solo para desarrollo y no debe usarse en producción.

2) Ejecutar en emulador/dispositivo (alternativa segura)

   - Ejecuta la app en Android/iOS (emulador o dispositivo conectado). Las peticiones HTTP desde la app nativa no se ven afectadas por CORS del navegador.
```powershell
flutter run -d emulator-5554
```

3) Pedir CORS al API (solución definitiva)

   - Pide al administrador del servidor que añada `Access-Control-Allow-Origin` para tu origen o `*` si procede.

4) Verificaciones rápidas

   - Comprobar que el proxy responde:
```powershell
Invoke-WebRequest -Uri "http://localhost:8080/https://parking.visiontic.com.co/api/users" -Method OPTIONS
```



## Nuevo: Universidades

Se añadió una nueva opción en el `CustomDrawer` llamada "Universidades" que navega a la ruta `/universidades`.

- Archivo principal: `lib/widgets/custom_drawer.dart` (ListTile con icono `Icons.school` que hace `context.go('/universidades')`).
- Ruta registrada en: `lib/routes/app_router.dart` (GoRoute con path `/universidades`).
- Pantalla placeholder: `lib/views/universidades/universidades_screen.dart`.

Cómo probarlo
1. Levanta la app (emulador o web):

```powershell
cd 'c:\Users\ASUS\Documents\Mobiles\grupo_2'
flutter pub get
flutter run
```

2. En la app:
	 - Abre el Drawer (menú lateral).
	 - Toca "Universidades".
	 - Verás la pantalla placeholder con el título "Universidades" y un mensaje indicando que es un placeholder.

Notas y próximos pasos sugeridos
- Actualmente la pantalla es un placeholder para evitar errores de importación. Puedo implementar:
	- una lista que consuma una API pública de universidades (por ejemplo, datos mock o una API abierta),
	- búsqueda/paginación, y
	- pantalla de detalle por universidad con más información e imagen.

Indícame si quieres que implemente la lista real ahora y cuál fuente de datos prefieres (mock local, API pública o tu propio endpoint).

## Configurar Firebase para el módulo "Universidades"

El módulo `universidades` usa Cloud Firestore. Antes de ejecutar la app con Firestore debes configurar tu proyecto Firebase y añadir los archivos de configuración nativos o usar `flutterfire` para generar `firebase_options.dart`.

Pasos mínimos:

1. Crea un proyecto en https://console.firebase.google.com/ y añade las plataformas que vayas a usar (Android, iOS, Web).

2. Android: descarga `google-services.json` y colócalo en `android/app/`.

3. iOS: descarga `GoogleService-Info.plist` y añádelo al Runner target en Xcode (`ios/Runner`).

4. Web: opcionalmente genera `lib/firebase_options.dart` con `flutterfire` o añade el objeto `FirebaseOptions` al inicializar Firebase en `main.dart`.

5. (Recomendado) Instala y usa la CLI `flutterfire` para generar las opciones automáticamente:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

6. Instala dependencias y ejecuta la app:

```powershell
cd 'c:\Users\ASUS\Documents\Mobiles\grupo_2'
flutter pub get
flutter run
```

Notas de seguridad y pruebas

- Asegúrate de configurar reglas de seguridad de Firestore para el entorno de desarrollo. Para pruebas locales puedes permitir lectura/escritura, pero NO lo uses así en producción.
- Si no quieres conectar a Firebase ahora, la pantalla `Universidades` seguirá funcionando pero sin datos (requiere inicializar Firebase para la colección real).




# #   T a l l e r   4 
 
 S e   a � a d i �   u n a   n u e v a   o p c i � n   e n   e l   D r a w e r   l l a m a d a   * * T a l l e r   4 * *   p a r a   l a   s i g u i e n t e   e t a p a   d e l   c u r s o . 
 
 -   * * R u t a : * *   \ / t a l l e r 4 \ ` n -   * * A r c h i v o : * *   \ l i b / v i e w s / t a l l e r 4 / t a l l e r 4 _ s c r e e n . d a r t \ ` n -   * * I c o n o : * *   \ I c o n s . w o r k \ ` n -   * * E s t a d o : * *   P a n t a l l a   p l a c e h o l d e r   l i s t a   p a r a   i m p l e m e n t a r   c o n t e n i d o 
 
 C � m o   a c c e d e r : 
 1 .   A b r e   l a   a p p 
 2 .   T o c a   e l   i c o n o   d e l   m e n �   ( D r a w e r ) 
 3 .   S e l e c c i o n a   ' T a l l e r   4 ' 
 4 .   V e r � s   l a   p a n t a l l a   p l a c e h o l d e r 
 
 E l   c o n t e n i d o   d e l   T a l l e r   4   s e   a g r e g a r �   s e g � n   l a s   i n s t r u c c i o n e s   q u e   p r o p o r c i o n e s . 
  
 