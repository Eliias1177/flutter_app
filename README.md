
```markdown
# Gestión de Notas Avanzada - App en Flutter

Aplicación móvil multiplataforma desarrollada en Flutter con arquitectura robusta. Implementa autenticación, persistencia local, consumo de APIs, procesos asíncronos mediante Isolates y notificaciones nativas a nivel de sistema.

---

## Contexto Académico

* **Institución:** Universidad Politécnica de la Región Ribereña (UPRR)
* **Carrera:** Ingeniería en Tecnologías de la Información e Innovación Digital
* **Materia:** 
* **Grupo:** 
* **Autores:** 
  * Jesús Elías Arriaga Salinas
* **Profesor:**
  * Jonathan Elí Sáenz Meléndez 

---

## Descripción del Proyecto

Este proyecto es una prueba de concepto integral que demuestra el manejo avanzado del hardware y software de un dispositivo mediante Flutter. La aplicación incluye un sistema de Login/Registro animado, una base de datos local cifrada y sincronización simulada con una API REST en la nube. Supera las restricciones modernas de Android (SDK 34+) gestionando permisos para alarmas exactas y ejecutando notificaciones reales en segundo plano, además de permitir la exportación de registros locales a archivos .txt.

---

## Características Principales

1. **Interfaz Dinámica (UI/UX):** Transiciones fluidas en una sola pantalla para Login y Registro, con validaciones en tiempo real y retroalimentación táctil/visual (animación Shake) para errores de validación.
2. **Seguridad con Isolates:** Uso de hilos secundarios (compute) para encriptar contraseñas mediante Bcrypt, evitando la saturación del hilo principal de la interfaz.
3. **Persistencia Híbrida (SQLite + REST API):** Almacenamiento local mediante sentencias SQL nativas sincronizado con llamadas asíncronas a una API pública (JSONPlaceholder).
4. **Notificaciones Nativas:** Programación de alarmas exactas a través de canales nativos de Android para notificar recordatorios de notas en el futuro.
5. **Manejo del Sistema de Archivos:** Escritura y lectura de archivos de texto plano (.txt) directamente en el almacenamiento interno del dispositivo.

---

## Herramientas y Tecnologías Usadas

### Frameworks y Lenguajes
* **Flutter (SDK):** Framework principal para desarrollo UI multiplataforma.
* **Dart:** Lenguaje de programación.

### Dependencias / Paquetes (Pub.dev)
* sqflite y path: Motor de base de datos local.
* bcrypt: Criptografía para protección de credenciales.
* http: Cliente para peticiones REST (GET, POST, PUT, DELETE).
* flutter_local_notifications y timezone: Gestión de alertas nativas en segundo plano.
* path_provider: Acceso a directorios seguros del sistema de archivos.

### Software e Infraestructura
* **Git y GitHub:** Control de versiones y alojamiento de código.
* **Android Studio:** Gestión de emuladores y herramientas del SDK de Android.
* **Visual Studio 2022:** Compilador C++ para despliegue en Windows Desktop.
* **DB Browser for SQLite:** Herramienta visual para auditar y depurar la base de datos local generada.

### Inteligencia Artificial
* **Gemini:** Utilizado para asistencia en la arquitectura de código, resolución de conflictos de dependencias nativas de Gradle/Kotlin (SDK 36) y depuración del flujo de estados (resolución de Futures en setState).

---

## Entornos de Pruebas Comprobados

Este código ha sido compilado y probado exitosamente en las siguientes plataformas:
* Dispositivo Físico: POCO X7 Pro (Android, HyperOS/MIUI) - Arquitectura ARM64.
* Emulador Android: API 34+ (Arquitectura x86_64).
* Escritorio: Windows 10/11 Desktop (Nativo).

---

## Cómo compilarlo y correrlo (Guía Paso a Paso)

No necesitas un editor específico (como VS Code o Android Studio) para correr esto, puedes hacerlo directamente desde tu terminal de comandos (CMD, PowerShell o Bash).

### 1. Prerequisitos
* **Flutter SDK:** Instalado y configurado en tus variables de entorno (PATH).
* **Para correr en Android:** 
  * Tener instalado el SDK de Android.
  * Dispositivo conectado por USB con Depuración USB e Instalación vía USB activados.
* **Para compilar en Windows Desktop:** 
  * Tener instalado **Visual Studio 2022** con la carga de trabajo de "Desarrollo para el escritorio con C++".
  * **IMPORTANTE:** Debes activar el Modo de Desarrollador de Windows (Configuración > Privacidad y Seguridad > Para programadores) para permitir que Flutter cree enlaces simbólicos (symlinks).

### 2. Pasos de Ejecución en Terminal

Abre tu terminal favorita, navega a la carpeta donde deseas guardar el proyecto y ejecuta:

```bash
# 1. Clona este repositorio
git clone [https://github.com/TU_USUARIO/TU_REPOSITORIO.git](https://github.com/TU_USUARIO/TU_REPOSITORIO.git)

# 2. Entra a la carpeta del proyecto
cd nombre_del_repositorio

# 3. Descarga y vincula todas las dependencias
flutter pub get

# 4. Verifica los dispositivos conectados disponibles
flutter devices

```
**Para ejecutar en un celular físico Android o Emulador:**
```bash
# Nota: Si el emulador choca visualmente, puedes forzar el motor clásico:
flutter run -d android --no-enable-impeller

```
**Para compilar como aplicación nativa de Windows (.exe):**
```bash
flutter run -d windows

```
## Arquitectura y Diagramas
[UI: Flutter/Dart] <---> [Servicios Asíncronos]
|                          |
v                          v
[Local: SQLite (Cache)]    [Nube: REST API (CRUD)]
|
v
[Sistema de Notificaciones Android / Archivos TXT]
```

```

