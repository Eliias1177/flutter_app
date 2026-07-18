```markdown
# Flutter App - Gestión de Notas Avanzada

Aplicación móvil desarrollada en Flutter que implementa una arquitectura completa con persistencia de datos local, consumo de API REST, procesos asíncronos y notificaciones a nivel de sistema.

## Descripción del Proyecto
Este proyecto es una solución integral que demuestra el manejo avanzado del estado y los recursos del dispositivo en Flutter. Cuenta con un sistema de autenticación (Login/Registro) con interfaz dinámica en una sola pantalla, un CRUD completo de notas sincronizado localmente y notificaciones exactas programadas por el usuario.

## Características Principales

*   **Autenticación Fluida:** Pantalla única de Login y Registro controlada por transformaciones de estado y animaciones (`AnimatedSwitcher`, `AnimatedSize`), incluyendo retroalimentación visual (*Shake Animation*) para errores de validación.
*   **Persistencia Local (SQLite):** Base de datos relacional para gestionar la sesión de los usuarios (encriptando contraseñas) y el almacenamiento en caché de las notas.
*   **Integración API REST:** Consumo de una API pública (`JSONPlaceholder`) simulando un entorno de producción para operaciones CRUD (Create, Read, Update, Delete) operando en conjunto con la base de datos local.
*   **Notificaciones Locales (Exact Alarms):** Uso de canales nativos de Android y `flutter_local_notifications` para programar alertas precisas en segundo plano, superando las restricciones de batería en versiones recientes de Android (SDK 34+).
*   **Procesos Asíncronos (Isolates):** Implementación de hilos secundarios (`compute`) para el hasheo de contraseñas con Bcrypt, evitando el bloqueo del hilo principal de la interfaz de usuario (UI).
*   **Manejo de Archivos:** Exportación e importación directa de registros hacia y desde el sistema de archivos del dispositivo en formato `.txt`.

## Tecnologías y Paquetes Utilizados
*   **Framework:** Flutter & Dart
*   **Base de Datos:** `sqflite`, `path`
*   **Seguridad:** `bcrypt`
*   **Red:** `http`
*   **Notificaciones:** `flutter_local_notifications`, `timezone`
*   **Archivos:** `path_provider`

## Requisitos Previos y Ejecución

Para correr este proyecto en tu entorno local, asegúrate de tener el SDK de Flutter instalado.

1. Clona este repositorio:
   ```bash
   git clone [https://github.com/TU_USUARIO/TU_REPOSITORIO.git](https://github.com/TU_USUARIO/TU_REPOSITORIO.git)

```

2. Instala las dependencias:
```bash
flutter pub get

```


3. Conecta un dispositivo físico o emulador (Android SDK 21 o superior requerido) y ejecuta:
```bash
flutter run

```



*Nota: Para el correcto funcionamiento de las notificaciones en Android, la aplicación solicitará permisos de "Alarmas exactas" y "Mostrar notificaciones" en su primer inicio.*

---

## Contexto Académico y Autor

Este proyecto fue desarrollado como parte de las prácticas y evaluaciones de la **Ingeniería en Tecnologías de la Información e Innovación Digital**.

**Desarrollado por:**

* Jesús Elías Arriaga Salinas
* **Institución:** Universidad Politécnica de la Región Ribereña

```

```
