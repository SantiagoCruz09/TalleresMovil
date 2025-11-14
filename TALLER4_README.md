flu# Taller 4 - Lista de Tareas Offline-First

## Descripción

Módulo completo de **lista de tareas con sincronización offline-first**, que demuestra arquitectura limpia, manejo de estado con Provider, SQLite para persistencia local, API REST para sincronización, y manejo robusto de errores.

## Objetivos de Aprendizaje

✅ **Arquitectura limpia**: Separación de capas (data/local, data/remote, repositories, providers, views)  
✅ **State Management**: Manejo de estado con Provider y ChangeNotifier  
✅ **Persistencia local**: SQLite con sqflite para almacenamiento offline  
✅ **API REST**: Integración con endpoints HTTP con manejo de errores  
✅ **Sincronización**: Cola de operaciones para sincronizar cambios cuando hay conexión  
✅ **Offline-First**: Leer local + escribir local + sincronizar en background  
✅ **Manejo de conectividad**: Detección automática de cambios de conexión  

## Estructura del Proyecto

```
lib/
├── data/
│   ├── local/
│   │   └── database_helper.dart          # SQLite singleton + CRUD + queue
│   ├── remote/
│   │   └── api_client.dart               # HTTP client + error handling
│   └── repositories/
│       └── task_repository.dart          # Lógica offline-first + sync
├── models/
│   ├── task.dart                         # Modelo Task (id, title, completed, updatedAt)
│   ├── task_exception.dart               # Excepciones personalizadas
│   └── queue_operation.dart              # Modelo para operaciones pendientes
├── providers/
│   └── task_provider.dart                # ChangeNotifier + state management
└── views/
    └── taller4/
        ├── taller4_screen.dart           # Entry point → TaskListScreen
        ├── task_list_screen.dart         # Pantalla principal (lista, filtros)
        ├── task_form_screen.dart         # Formulario crear/editar
        └── widgets/
            ├── task_item.dart            # Tarjeta de tarea individual
            ├── sync_indicator.dart       # Indicador de estado de sincronización
            └── filter_chips.dart         # Chips de filtro (todas/pendientes/completadas)
```

## Bases de Datos

### Tabla: `tasks`
```sql
CREATE TABLE tasks (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  completed INTEGER DEFAULT 0,
  updated_at TEXT NOT NULL,
  deleted INTEGER DEFAULT 0,
  created_at TEXT NOT NULL
)
```

### Tabla: `queue_operations`
```sql
CREATE TABLE queue_operations (
  id TEXT PRIMARY KEY,
  entity TEXT NOT NULL,           -- 'task'
  entity_id TEXT NOT NULL,        -- task id
  op TEXT NOT NULL,               -- 'create'|'update'|'delete'
  payload TEXT NOT NULL,          -- JSON serializado
  created_at TEXT NOT NULL,
  attempt_count INTEGER DEFAULT 0,
  last_error TEXT
)
```

## API Contrato

### Endpoints

```
GET    /api/tasks              → List[Task]
GET    /api/tasks/{id}         → Task
POST   /api/tasks              → Task (cuerpo: {title, completed})
PUT    /api/tasks/{id}         → Task
DELETE /api/tasks/{id}         → {}
```

### Headers Personalizados

```
Content-Type: application/json
Accept: application/json
X-Request-ID: {uuid}                    # Para idempotencia
Idempotency-Key: {uuid}                 # Alternativo
```

### Modelo Task (JSON)

```json
{
  "id": "uuid-v4",
  "title": "Hacer compras",
  "completed": false,
  "updatedAt": "2025-11-12T10:30:00.000Z"
}
```

## Flujo Offline-First

### 1. Lectura (READ)
```
1. Leer del SQLite local
2. Mostrar inmediatamente al usuario
3. Si conectado:
   → Sincronizar en background (no bloquea UI)
```

### 2. Escritura (CREATE/UPDATE/DELETE)
```
1. Validar entrada
2. Guardar en SQLite local (optimistic update)
3. Encolar operación en queue_operations
4. Si conectado:
   → Sincronizar en background
5. Mostrar feedback al usuario
```

### 3. Sincronización (SYNC)
```
1. Verificar conectividad
2. Si conectado:
   → Obtener operaciones pendientes de queue
   → Procesar cada una (CREATE/UPDATE/DELETE)
   → Si éxito: remover de queue
   → Si error: registrar intento + error
3. Reintentar con exponential backoff (hasta 3 intentos)
4. Actualizar estado sync (idle/syncing/success/error)
```

## Uso de la Aplicación

### Desde el Drawer
1. Abre el app
2. Toca el ícono de menú (hamburguesa)
3. Selecciona "Taller4"

### Pantalla Principal (TaskListScreen)
- **Crear tarea**: FAB (botón flotante "+")
- **Editar tarea**: Toca el ícono de menú (⋮) en la tarjeta → "Editar"
- **Marcar como completada**: Checkbox a la izquierda
- **Eliminar tarea**: Toca el ícono de menú (⋮) en la tarjeta → "Eliminar"
- **Filtrar**: Chips "Todas", "Pendientes", "Completadas"
- **Sync indicator**: Barra superior mostrando estado (Sincronizando / Sincronizado / Error)

### Formulario (TaskFormScreen)
- Ingresa título
- Si editas: checkbox "Marcar como completada"
- Botón "Crear" o "Actualizar"
- Botón "Cancelar"

## Configuración

### Cambiar URL del API

En `lib/data/remote/api_client.dart`:
```dart
final apiClient = ApiClient();
apiClient.setBaseUrl('http://tu-servidor.com/api');
```

O editar la constante:
```dart
String baseUrl = 'http://localhost:3000/api';
```

### Timeout de Solicitudes

En `lib/data/remote/api_client.dart`:
```dart
final Duration timeout = const Duration(seconds: 10);
```

## Testing Manual

### Escenario 1: Crear tarea en línea
1. Asegurar que el dispositivo tiene conexión
2. Abrir Taller4
3. FAB → Ingresar "Comprar leche" → Crear
4. **Esperado**: Tarea aparece en lista localmente + sincroniza automáticamente

### Escenario 2: Crear tarea sin conexión
1. Desconectar red (modo Airplane o desactivar WiFi)
2. FAB → Ingresar "Lavar coche" → Crear
3. **Esperado**: Tarea aparece en lista localmente
4. Reconectar red
5. **Esperado**: Sync indicator muestra "Sincronizando..." → "Sincronizado"
6. Tarea se envía al servidor

### Escenario 3: Editar y filtrar
1. Editar una tarea (cambiar título)
2. Usar chips: "Pendientes" → muestra solo no completadas
3. Marcar como completada
4. Usar chip "Completadas" → muestra solo completadas

### Escenario 4: Reintentos en error
1. Desconectar (sin conexión)
2. Crear tarea
3. Reconectar (conexión lenta/timeout)
4. **Esperado**: Sistema intenta resincronizar (hasta 3 reintentos)

## Dependencias Clave

```yaml
provider: ^6.1.0              # State management
sqflite: ^2.2.8+4             # SQLite
path: ^1.8.3                  # Rutas de archivos
connectivity_plus: ^5.0.0     # Detección de conectividad
uuid: ^4.0.0                  # Generación de IDs únicos
http: ^0.13.6                 # Cliente HTTP
```

## Manejo de Errores

### Excepciones Personalizadas

- **NetworkException**: Error de conexión
- **TimeoutException**: Solicitud agotó timeout
- **SyncException**: Error de sincronización (4xx, 5xx)
- **DatabaseException**: Error de SQLite
- **ValidationException**: Error de validación de entrada

### Flujo de Errores

```dart
try {
  // operación
} catch (e) {
  if (e is NetworkException) {
    // Mostrar: "Sin conexión"
  } else if (e is TimeoutException) {
    // Mostrar: "Servidor no respondió"
  } else if (e is ValidationException) {
    // Mostrar: "Entrada inválida"
  }
}
```

## Extensiones Futuras

- [ ] Agregar búsqueda de tareas
- [ ] Ordenar por fecha / alfabético
- [ ] Compartir tareas (sincronización multi-usuario)
- [ ] Notificaciones locales para recordatorios
- [ ] Exportar/importar a JSON o CSV
- [ ] Estadísticas (% completado)
- [ ] Categorías o etiquetas

## Troubleshooting

### Las tareas no persisten
- ✓ Verificar que SQLite esté correctamente inicializado (check logs)
- ✓ Revisar permisos de almacenamiento (Android)

### Las tareas no se sincronizan
- ✓ Verificar conectividad (ping a servidor)
- ✓ Revisar URL del API en ApiClient
- ✓ Revisar logs de error (queue_operations table)

### Errores de compilación
- ✓ Ejecutar `flutter pub get`
- ✓ Ejecutar `flutter pub upgrade`
- ✓ Limpiar: `flutter clean`

## Recursos

- [Provider Docs](https://pub.dev/packages/provider)
- [SQLite Best Practices](https://www.sqlite.org/bestpractice.html)
- [Sqflite Docs](https://pub.dev/packages/sqflite)
- [Clean Architecture](https://resocoder.com/flutter-clean-architecture)

---

**Autor**: Taller 2 - Grupo 2  
**Fecha**: Noviembre 2025  
**Estado**: ✅ Funcional (Fase 7 completada)

## Actualizaciones recientes (resumen de cambios añadidos)

He añadido varias funcionalidades y mejoras solicitadas durante la iteración. Este apartado describe los cambios nuevos, cómo funcionan y cómo probarlos.

### 1) Campos adicionales en la tarea
- `description` (opcional): texto libre para detalles de la tarea.
- `dueDate` (opcional): fecha límite (DateTime) para la tarea.

Estos campos ya están contemplados en el modelo (`lib/models/task.dart`), serialización (`toMap` / `toJson`) y se muestran en la UI (`TaskItem`).

### 2) Formulario actualizado
El formulario de crear/editar (`lib/views/taller4/task_form_screen.dart`) ahora incluye:
- Campo "Descripción" (multilínea).
- Selector de fecha (DatePicker) para `dueDate`.

Al enviar, el provider recibe y muestra estos valores inmediatamente.

### 3) Visualización inmediata (almacenamiento temporal / optimista)
Para garantizar que la tarea creada se vea de inmediato en la lista sin depender de la base de datos ni del servidor, se implementó un comportamiento optimista en memoria:

- Cuando creas una tarea, se inserta una tarea temporal en memoria con un id tipo `tmp-<timestamp>-<random>` y aparece de inmediato en la parte superior de la lista.
- En background (asincrónico) se intenta persistir la tarea mediante el repositorio. Si la persistencia retorna con éxito, la tarea temporal se reemplaza por la tarea persistida (con id definitivo).
- Si eliminas una tarea temporal, se borra solo localmente (no se intenta eliminar en el repo porque no existe aún allí).

Esto está implementado en `lib/providers/task_provider.dart` y evita que la UI dependa del flujo de persistencia para mostrar la tarea.

### 4) Eliminación inmediata
La eliminación es optimista: al pulsar eliminar la tarea desaparece inmediatamente de la lista. Si la tarea ya existía en el repositorio, la eliminación se envía en background.

### 5) Base de datos y migración
- Se añadió soporte para `description` y `due_date` en la tabla `tasks`.
- La versión de la BD se incrementó a `2` y el `onUpgrade` añade las columnas si vienen de una versión anterior.

Archivo principal: `lib/data/local/database_helper.dart` (migración y schema).

### 6) Selector de color (ThemeProvider)
- Añadí un `ThemeProvider` simple (`lib/providers/theme_provider.dart`) y un menú en la AppBar para seleccionar colores.
- Colores disponibles: Indigo, Green, Purple, Orange, Teal.
- El color seleccionado se aplica al `AppBar` y al fondo de la pantalla.

### 7) Archivos modificados (lista rápida)
- `lib/models/task.dart`  -- nuevos campos `description`, `dueDate` y serialización.
- `lib/data/local/database_helper.dart` -- columnas nuevas & onUpgrade (version = 2).
- `lib/data/repositories/task_repository.dart` -- create/update ahora aceptan description y dueDate.
- `lib/providers/task_provider.dart` -- lógica optimista (tareas temporales, sincronización en background, eliminación optimista).
- `lib/providers/theme_provider.dart` -- nuevo provider para color de la UI.
- `lib/views/taller4/task_form_screen.dart` -- formulario con description y date picker.
- `lib/views/taller4/task_list_screen.dart` -- aplicación del color y menú selector en AppBar.
- `lib/views/taller4/widgets/task_item.dart` -- muestra descripción y dueDate en subtítulo.

### 8) Cómo probar rápidamente estas nuevas funcionalidades
1. Parar y ejecutar la app (no solo hot reload):
```powershell
cd "c:\Users\ASUS\Documents\Mobiles\grupo_2"
flutter run
```
2. Abrir Drawer → `Taller4`.
3. Crear una tarea con título, descripción y seleccionar fecha. Al pulsar "Crear":
  - La tarea deberá aparecer inmediatamente en la parte superior de la lista (temporalmente).
  - Si la app tiene conectividad, en segundos la tarea temporal se reemplazará por la persistida (internamente).
4. Eliminar la tarea con el icono/el botón de eliminar: la tarea desaparece inmediatamente.
5. Probar el selector de color en la AppBar (icono paleta) para cambiar el color de la página.

### 9) Notas y recomendaciones
- Si quieres la versión más simple (solo almacenamiento temporal en memoria sin intentar persistencia en background), puedo desactivar las llamadas al repo y dejar TODO en memoria (útil para pruebas rápidas). Dime si prefieres esto.
- Si quieres persistir el color seleccionado entre sesiones, puedo integrar `shared_preferences` y guardar la preferencia.
- Fase 8 (mock API + tests) aún pendiente; si deseas que avance con eso, lo implemento a continuación.

---

Si quieres que ajuste el flujo (por ejemplo: no crear tarea temporal, o guardar color en preferencias), dime cuál y lo hago a continuación.
