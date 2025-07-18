# Feature: Events

## Descripción
Esta feature permite mostrar eventos/popups al usuario cuando abre la aplicación. Los eventos son imágenes que el administrador puede configurar desde un panel web.

## Arquitectura

### Estructura de Carpetas
```
lib/features/events/
├── data/
│   ├── datasources/
│   │   └── events_remote_datasource.dart
│   ├── models/
│   │   └── event_model.dart
│   ├── repositories/
│   │   └── events_repository_impl.dart
│   └── services/
│       └── events_service.dart
├── domain/
│   ├── entities/
│   │   └── event.dart
│   ├── repositories/
│   │   └── events_repository.dart
│   └── usecases/
│       └── get_future_events.dart
└── presentation/
    ├── bloc/
    │   ├── events_bloc.dart
    │   ├── events_event.dart
    │   └── events_state.dart
    └── widgets/
        ├── event_popup_dialog.dart
        └── events_handler.dart
```

## Funcionalidades

### 1. Carga de Eventos
- Obtiene eventos futuros desde la API
- Filtra eventos activos (fecha actual o futura)
- Maneja errores de red y servidor

### 2. Mostrar en Cada Inicio
- Se muestra el evento cada vez que el usuario abre la app
- No hay persistencia local para evitar repetición
- Siempre muestra el primer evento activo disponible

### 3. Interfaz de Usuario
- Popup modal con imagen del evento
- Diseño responsivo (16:9 aspect ratio)
- Animaciones suaves
- Botón de cerrar

## Especificaciones de Imagen

### Dimensiones Recomendadas
- **Ratio**: 16:9 (landscape)
- **Ancho**: 1080px
- **Alto**: 608px
- **Tamaño máximo**: 2MB
- **Formatos**: JPEG, PNG, WebP

### Validaciones
- Mínimo: 400x300px
- Máximo: 1200x900px
- Formato: jpg, jpeg, png, webp

## API Endpoint

### Obtener Eventos Futuros
```
GET /users/events/by/future
```

### Respuesta
```json
{
  "message": "Future events fetched successfully",
  "events": [
    {
      "id": 1,
      "id_user": 1,
      "date_event": "2025-12-17T00:00:00.000Z",
      "img_path": "https://example.com/image.jpg",
      "createdAt": "2025-12-17T00:00:00.000Z",
      "updatedAt": "2025-12-17T00:00:00.000Z"
    }
  ],
  "success": true
}
```

## Integración

### En AppShell
La feature se integra automáticamente en el AppShell y muestra eventos al abrir la aplicación.

### BlocProvider
```dart
BlocProvider<EventsBloc>(
  create: (_) => EventsBloc(
    getFutureEvents: GetFutureEvents(eventsRepository),
  ),
),
```

### EventsHandler
```dart
EventsHandler(
  child: Scaffold(
    // ... resto del contenido
  ),
),
```

## Flujo de Funcionamiento

1. **Al abrir la app**: Se cargan eventos futuros
2. **Filtrado**: Se muestran solo eventos activos (fecha actual o futura)
3. **Popup**: Se muestra el primer evento activo
4. **Cierre**: El usuario cierra el popup y continúa con la app
5. **Repetición**: El evento se mostrará nuevamente en el próximo inicio de la app

## Configuración del Panel de Administración

### Funcionalidades Necesarias
- Subir imágenes con validaciones
- Configurar fechas de eventos
- Activar/desactivar eventos
- Vista previa de eventos
- Gestión de eventos existentes

### Validaciones del Backend
- Tamaño de archivo máximo
- Formatos permitidos
- Dimensiones mínimas/máximas
- Fechas válidas

## Consideraciones Técnicas

### Performance
- Cache de imágenes
- Lazy loading
- Validación de fechas en servidor

### UX
- No bloquear navegación principal
- Animaciones suaves
- Opción de cerrar

### Seguridad
- Validar URLs de imágenes
- Sanitizar datos del admin
- Límites de tamaño de archivo 