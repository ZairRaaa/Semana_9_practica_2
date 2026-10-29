# Práctica Grupal Semana 09: Tecnologías Backend (PHP & JSP)

**Universidad Nacional del Centro del Perú**  
**Facultad de Ingeniería de Sistemas**  
**Asignatura:** Desarrollo de Aplicaciones Web (IS093A)  
**Semestre:** 2026-II  
**Docente:** Ing. Responsable  
**Integrantes:**
- **Rojas Cerrón** (Desarrollador PHP & Arquitecto XAMPP)
- **Tocas Anglas** (Desarrollador JSP & Arquitecto Tomcat)

---

## 1. Diagrama de Flujo del Ciclo HTTP Completo

El siguiente flujo describe el viaje de una petición web desde la interacción del usuario en el navegador hasta el renderizado de la respuesta en pantalla:

```text
+-----------+       1. Consulta DNS       +---------------+
|           | --------------------------> |   Servidor    |
|  CLIENTE  |                             |      DNS      |
| (Browser) | <-------------------------- +---------------+
|           |        Resuelve IP (ej. 127.0.0.1)
+-----------+
      |
      | 2. Handshake TCP/IP (SYN -> SYN-ACK -> ACK) [Puerto 80 / 8080]
      v
+---------------------------------------------------------+
|                  SERVIDOR WEB (Apache)                  |
|                                                         |
| 3. HTTP Request: POST /php-app/procesar.php HTTP/1.1    |
|    Headers: Host, Content-Type, Cookie (PHPSESSID)      |
|    Body: nombre=Juan+Perez&correo=juan%40uncp.edu.pe   |
+---------------------------------------------------------+
      |
      | 4. Despacho al Intérprete PHP (módulo o FastCGI)
      v
+---------------------------------------------------------+
|                   MOTOR BACKEND (PHP)                   |
| - session_start() busca/crea PHPSESSID en disco/memoria |
| - Valida método POST (si no -> HTTP 405)                |
| - Sanitiza inputs (filter_input + htmlspecialchars)     |
| - Añade contacto a $_SESSION['registros']               |
| - Genera HTML estructurado con tabla de datos           |
+---------------------------------------------------------+
      |
      | 5. HTTP Response: HTTP/1.1 200 OK
      |    Headers: Content-Type: text/html, Set-Cookie...
      |    Body: <!DOCTYPE html><html>...tabla...</html>
      v
+-----------+
|  CLIENTE  | 6. Procesamiento y Renderizado en el DOM (Motor Blink/Gecko)
| (Browser) |    Pintado de la tabla de contactos y confirmación visual.
+-----------+
```

---

## 2. Implementación del Módulo PHP (`php-app/`)

### 2.1. Arquitectura de Archivos
* **[`php-app/index.html`](./php-app/index.html)**: Formulario de entrada con validación en cliente (HTML5 `required`, `type="email"`), apuntando por método `POST` al backend.
* **[`php-app/procesar.php`](./php-app/procesar.php)**: Controlador y vista backend que procesa, valida, almacena y renderiza los datos.
* **[`php-app/style.css`](./php-app/style.css)**: Hoja de estilos compartida moderna y responsive.

### 2.2. Medidas de Seguridad y Robustez Implementadas
1. **Validación de Método HTTP**:
   Si se intenta acceder directamente por `GET` a `procesar.php` sin registros previos, el servidor responde con el código de estado `405 Method Not Allowed`:
   ```php
   if ($_SERVER['REQUEST_METHOD'] !== 'POST' && !isset($_SESSION['registros'])) {
       http_response_code(405);
       exit('Método de solicitud no permitido...');
   }
   ```
2. **Sanitización y Prevención XSS (Cross-Site Scripting)**:
   Se utiliza `filter_input()` combinado con `htmlspecialchars()` con flags `ENT_QUOTES` y codificación `UTF-8` tanto en el procesamiento como en la salida de la tabla:
   ```php
   $nombre_raw = filter_input(INPUT_POST, 'nombre', FILTER_DEFAULT);
   $correo_raw = filter_input(INPUT_POST, 'correo', FILTER_VALIDATE_EMAIL);
   $nombre = htmlspecialchars(trim($nombre_raw), ENT_QUOTES, 'UTF-8');
   ```
3. **Manejo de Errores 400 (Bad Request)**:
   Si los campos son enviados vacíos o con formato de correo inválido, se interrumpe la ejecución devolviendo código `400`:
   ```php
   if (empty($nombre) || empty($correo)) {
       http_response_code(400);
       exit('Datos inválidos...');
   }
   ```
4. **Gestión de Estado y Sesión**:
   Uso de `session_start()` y la superglobal `$_SESSION['registros']` para acumular múltiples registros en memoria persistente entre peticiones.

---

## 3. Guía de Despliegue en Servidor Apache / XAMPP

1. **Ubicación en Servidor**:
   Copiar la carpeta `php-app/` dentro del directorio raíz de documentos de Apache:
   - En Windows: `C:\xampp\htdocs\php-app`
2. **Iniciar Servicios**:
   - Abrir el panel de control de XAMPP e iniciar el módulo **Apache** (Puertos predeterminados: 80 y 443).
3. **Acceso Web**:
   - Abrir en el navegador: `http://localhost/php-app/index.html`
4. **Ubicación de Logs para Auditoría**:
   - Logs de acceso: `C:\xampp\apache\logs\access.log`
   - Logs de error: `C:\xampp\apache\logs\error.log`

---

## 4. Matriz Comparativa Técnica: PHP vs JSP

| Criterio Técnico | PHP (Hypertext Preprocessor) | JSP (JavaServer Pages) |
| :--- | :--- | :--- |
| **Modelo de Ejecución / Ciclo de Vida** | Script interpretado por petición (Shared-Nothing). El script se ejecuta, genera HTML y libera memoria al finalizar. | Compilación Just-In-Time a un Servlet Java (`.class`). Se carga en memoria una vez y atiende peticiones concurrentes mediante hilos (*threads*). |
| **Rendimiento & Concurrencia** | Bajo consumo de memoria inicial; alto rendimiento con PHP-FPM y OPcache. Concurrencia por procesos independientes. | Alto rendimiento en cálculos complejos gracias al JIT de la JVM. Concurrencia multi-hilo eficiente en el mismo proceso del servidor. |
| **Servidores Web / Contenedores** | Apache HTTP Server con `mod_php` o Nginx con PHP-FPM. | Servidores de aplicaciones / Servlet Containers como Apache Tomcat, Jetty, WildFly. |
| **Gestión de Estado (Sesiones)** | `session_start()` almacena el estado en archivos serializados en disco (o Redis/Memcached) identificado por la cookie `PHPSESSID`. | `HttpSession` almacena referencias a objetos Java reales en la memoria Heap de la JVM, identificado por la cookie `JSESSIONID`. |
| **Seguridad por Defecto** | Requiere sanitización manual con funciones como `htmlspecialchars()`, `filter_input()` y consultas preparadas con PDO. | La sintaxis JSTL con `<c:out>` escapa automáticamente caracteres especiales XML/HTML, reduciendo el riesgo de XSS accidental. |
| **Curva de Aprendizaje y Despliegue** | Muy baja y rápida; despliegue directo copiando archivos al directorio web (`htdocs`). | Media-alta; requiere estructura estándar de carpetas Java EE (`WEB-INF/web.xml`, `.war`, dependencias JSTL y JDK). |

---

## 5. Módulo JSP (`jsp-app/`)
*(Sección asignada a Tocas para integración de código y capturas en Tomcat)*
- Formulario: `jsp-app/index.jsp`
- Procesamiento: `jsp-app/procesar.jsp`
- Despliegue: Apache Tomcat (puerto 8080 / `webapps/`)

---

## 6. Evidencias y Capturas de Pantalla (Módulo PHP - Rojas)

A continuación se presentan las capturas requeridas para la sustentación y evaluación de la práctica:

### 📸 Captura 1: Formulario de Contacto (`index.html`)
* **Descripción breve:** Interfaz del formulario web estilizado, listo para capturar nombre y correo del usuario mediante método POST.
* **Ubicación:** `docs/capturas/01_formulario_contacto.png`
* *(Insertar imagen: `![Formulario de Contacto](docs/capturas/01_formulario_contacto.png)`)*

### 📸 Captura 2: Tabla de Registros en Sesión (`procesar.php`)
* **Descripción breve:** Pantalla de confirmación con la tabla acumulativa de contactos almacenados en `$_SESSION` tras procesar la petición en el backend.
* **Ubicación:** `docs/capturas/02_registros_sesion.png`
* *(Insertar imagen: `![Registros en Sesión](docs/capturas/02_registros_sesion.png)`)*

### 📸 Captura 3: Prevención de Ataques XSS
* **Descripción breve:** Registro con carga maliciosa `<script>alert('xss')</script>` neutralizado como texto seguro en la tabla mediante `htmlspecialchars()`.
* **Ubicación:** `docs/capturas/03_prueba_xss.png`
* *(Insertar imagen: `![Prueba XSS](docs/capturas/03_prueba_xss.png)`)*

### 📸 Captura 4: Validación de Método HTTP 405 (Seguridad)
* **Descripción breve:** Respuesta del backend rechazando una petición directa por método GET con el código de estado `405 Method Not Allowed`.
* **Ubicación:** `docs/capturas/04_error_405.png`
* *(Insertar imagen: `![Error 405](docs/capturas/04_error_405.png)`)*

### 📸 Captura 5: Logs de Acceso del Servidor Apache
* **Descripción breve:** Archivo `access.log` de Apache evidenciando las peticiones GET (200), POST (200) y el rechazo por método no permitido (405).
* **Ubicación:** `docs/capturas/05_apache_logs.png`
* *(Insertar imagen: `![Logs de Apache](docs/capturas/05_apache_logs.png)`)*

### 📸 Captura 6: Servidor Apache Activo en XAMPP
* **Descripción breve:** Panel de control de XAMPP mostrando el servicio Apache en ejecución en el puerto 8080.
* **Ubicación:** `docs/capturas/06_xampp_apache.png`
* *(Insertar imagen: `![XAMPP Apache](docs/capturas/06_xampp_apache.png)`)*

