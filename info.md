# Plan de Trabajo y Asignación de Roles - Práctica Grupal Semana 09

**Asignatura:** Desarrollo de Aplicaciones Web (IS093A)  
**Tema:** Tecnología Web Backend, Arquitectura Cliente-Servidor, Servidores Web, PHP & JSP, Ciclo de Vida y Despliegue  
**Integrantes:** Rojas & Tocas  
**Duración estimada:** 60 minutos  

---

## 1. Resumen de la Práctica y Entregables

Implementar un **Sistema de Registro de Contacto** con dos variantes tecnológicas completas:
1. **Módulo PHP (`php-app/`)**: Formulario HTML + `procesar.php` con validación, sanitización (`htmlspecialchars`), manejo de sesiones (`$_SESSION`), método POST exclusivo y renderizado de tabla de registros.
2. **Módulo JSP (`jsp-app/`)**: Formulario JSP + `procesar.jsp` con captura de parámetros (`request.getParameter`), manejo de sesión (`HttpSession`), JSTL (`<c:forEach>`, `<c:out>`), validación POST y renderizado.
3. **Documentación (`README.md`)**:
   - Diagrama de flujo del Ciclo HTTP (Cliente → DNS → TCP/IP → HTTP Request → Server → Backend → Response → Render).
   - Matriz Comparativa Técnica (PHP vs JSP).
   - Evidencias: Capturas de logs del servidor (Apache y Tomcat), respuestas HTTP (Postman/cURL/DevTools) y sistema funcionando.

---

## 2. División de Trabajo Equitativa (50% - 50%)

De acuerdo con los **Roles Técnicos** y la **Rúbrica de Evaluación** de la guía:

| Criterio de la Rúbrica | Peso | Asignado Principal |
| :--- | :---: | :---: |
| **Lógica Backend PHP** (validación, sesiones, sanitización, XSS) | 25% | **Rojas** |
| **Despliegue & Servidor Apache/XAMPP** (puertos, htdocs, logs) | 10% | **Rojas** |
| **Lógica Backend JSP** (request, session, JSTL, respuesta estructurada) | 25% | **Tocas** |
| **Despliegue & Servidor Tomcat** (webapps, puerto 8080, logs catalina) | 10% | **Tocas** |
| **Ciclo HTTP & Sección PHP de Matriz Comparativa** | 15% | **Rojas** |
| **Seguridad, QA & Consolidación final del README.md** | 15% | **Tocas** |
| **Total** | **100%** | **Equilibrado** |

---

## 3. Detalle de Responsabilidades por Integrante

### 👤 Integrante 1: ROJAS
**Roles:** Desarrollador PHP & Arquitecto de Despliegue XAMPP / Apache

1. **Desarrollo Backend PHP (`php-app/`)**:
   - Crear y estilizar `php-app/index.html` con formulario de contacto (Nombre, Correo, etc.) apuntando por `POST` a `procesar.php`.
   - Refactorizar e implementar `php-app/procesar.php`:
     - Validación de método `POST` (retornar código `405 Method Not Allowed` si es inválido).
     - Sanitización de entradas con `filter_input()` y prevención XSS con `htmlspecialchars()`.
     - Inicialización y almacenamiento en `$_SESSION['registros']`.
     - Renderizado de tabla estructurada con registros acumulados.
2. **Despliegue Apache / XAMPP**:
   - Montaje del proyecto en `htdocs/`.
   - Verificación de puertos (80 / 8080 / 443).
   - Extracción de logs de acceso y errores de Apache (`access.log`, `error.log`).
3. **Aporte a la Documentación**:
   - Diagrama detallado del Ciclo HTTP completo.
   - Apartados de PHP en la Matriz Comparativa (Ciclo de vida, tiempo de arranque, modelo de procesos/threads, facilidad de despliegue).

---

### 👤 Integrante 2: TOCAS
**Roles:** Desarrollador JSP & Arquitecto de Despliegue Tomcat / QA

1. **Desarrollo Backend JSP (`jsp-app/`)**:
   - Crear `jsp-app/index.jsp` con formulario que envíe por `POST` a `procesar.jsp`.
   - Refactorizar e implementar `jsp-app/procesar.jsp`:
     - Validación de método `POST` (respuesta `405` o redirección si no es POST).
     - Captura de parámetros con `request.getParameter()`.
     - Almacenamiento en `HttpSession` (`List<Map<String, String>>`).
     - Renderizado estructurado con JSTL (`<c:forEach>` y prevención XSS con `<c:out>`) o scriptlets debidamente escapados.
2. **Despliegue Apache Tomcat**:
   - Configuración en carpeta `webapps/` (o estructura de servlet container con `web.xml` si aplica).
   - Verificación de puerto Tomcat (ej. 8080).
   - Extracción de logs de Tomcat (`catalina.out`, `localhost.log`).
3. **Aporte a la Documentación & QA**:
   - Pruebas HTTP (validación de métodos inválidos GET arrojando 405, pruebas con inyecciones XSS como `<script>alert(1)</script>`).
   - Apartados de JSP en la Matriz Comparativa (Compilación a servlets, JVM, gestión de estado en memoria empresarial, escalabilidad).
   - Maquetación y consolidación final del archivo `README.md` con capturas de pantalla de ambas aplicaciones.

---

## 4. Estructura del Repositorio Recomendada

```text
Semana_9_practica_2/
├── php-app/
│   ├── index.html
│   ├── procesar.php
│   └── css/ (opcional para diseño profesional)
├── jsp-app/
│   ├── index.jsp
│   ├── procesar.jsp
│   └── WEB-INF/ (web.xml y librerías JSTL si se requieren)
├── docs/
│   └── assets/ (capturas de logs, pruebas y funcionamiento)
├── README.md (Documentación técnica completa)
├── info.md (Este plan de trabajo)
└── Guia_Practica_Semana_9_-_Grupal.pdf
```
