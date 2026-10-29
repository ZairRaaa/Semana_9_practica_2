<?php
// Iniciar la sesión PHP para almacenar los contactos de forma persistente
session_start();

// Acción opcional para reiniciar la lista de registros
if (isset($_GET['action']) && $_GET['action'] === 'clear') {
    $_SESSION['registros'] = [];
    header('Location: procesar.php');
    exit();
}

// 1. Validación estricta del método HTTP (debe ser POST para procesar registros)
if ($_SERVER['REQUEST_METHOD'] !== 'POST' && !isset($_SESSION['registros'])) {
    http_response_code(405);
    header('Content-Type: text/html; charset=UTF-8');
    ?>
    <!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Error 405 - Método no permitido</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <div class="container">
            <div class="alert alert-danger">
                <strong>Error 405:</strong> Método de solicitud no permitido. El formulario debe enviarse exclusivamente mediante POST.
            </div>
            <a href="index.html" class="btn">Volver al Formulario</a>
        </div>
    </body>
    </html>
    <?php
    exit();
}

$registro_agregado = false;

// 2. Si es una petición POST, procesar y sanitizar las entradas
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Obtener y sanitizar inputs para prevenir ataques de Cross-Site Scripting (XSS)
    $nombre_raw = filter_input(INPUT_POST, 'nombre', FILTER_DEFAULT);
    $correo_raw = filter_input(INPUT_POST, 'correo', FILTER_VALIDATE_EMAIL);

    // Sanitización con htmlspecialchars para asegurar caracteres HTML seguros
    $nombre = $nombre_raw ? htmlspecialchars(trim($nombre_raw), ENT_QUOTES, 'UTF-8') : null;
    $correo = $correo_raw ? htmlspecialchars(trim($correo_raw), ENT_QUOTES, 'UTF-8') : null;

    // Validación de obligatoriedad y formato de correo
    if (empty($nombre) || empty($correo)) {
        http_response_code(400);
        ?>
        <!DOCTYPE html>
        <html lang="es">
        <head>
            <meta charset="UTF-8">
            <title>Error 400 - Datos Inválidos</title>
            <link rel="stylesheet" href="style.css">
        </head>
        <body>
            <div class="container">
                <div class="alert alert-danger">
                    <strong>Error 400:</strong> Datos inválidos o correo electrónico con formato incorrecto.
                </div>
                <a href="index.html" class="btn">Volver a Intentar</a>
            </div>
        </body>
        </html>
        <?php
        exit();
    }

    // 3. Almacenamiento en $_SESSION
    if (!isset($_SESSION['registros']) || !is_array($_SESSION['registros'])) {
        $_SESSION['registros'] = [];
    }

    $_SESSION['registros'][] = [
        'nombre' => $nombre,
        'correo' => $correo,
        'fecha'  => date('d/m/Y H:i:s')
    ];

    $registro_agregado = true;
}

$registros = $_SESSION['registros'] ?? [];
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lab 09 | Registros PHP Almacenados</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container wide">
        <span class="badge">Backend PHP • Sesión Activa</span>
        <h2>Lista de Contactos Registrados</h2>
        <p class="subtitle">Datos procesados en el servidor y almacenados en <code>$_SESSION</code>.</p>

        <?php if ($registro_agregado): ?>
            <div class="alert alert-success">
                <span>✓</span>
                <div>
                    <strong>¡Registro guardado con éxito!</strong> El contacto ha sido validado y añadido a la sesión.
                </div>
            </div>
        <?php endif; ?>

        <!-- 4. Renderizar tabla de registros estructurada -->
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th style="width: 50px;">#</th>
                        <th>Nombre</th>
                        <th>Correo Electrónico</th>
                        <th>Fecha y Hora</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($registros)): ?>
                        <tr>
                            <td colspan="4" style="text-align: center; color: var(--text-muted); padding: 24px;">
                                No hay contactos registrados en la sesión actual.
                            </td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($registros as $indice => $contacto): ?>
                            <tr>
                                <td><strong><?= $indice + 1; ?></strong></td>
                                <td><?= htmlspecialchars($contacto['nombre'], ENT_QUOTES, 'UTF-8'); ?></td>
                                <td><?= htmlspecialchars($contacto['correo'], ENT_QUOTES, 'UTF-8'); ?></td>
                                <td><?= htmlspecialchars($contacto['fecha'], ENT_QUOTES, 'UTF-8'); ?></td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>

        <div style="display: flex; gap: 12px; flex-wrap: wrap;">
            <a href="index.html" class="btn" style="flex: 1;">Registrar Otro Contacto</a>
            <?php if (!empty($registros)): ?>
                <a href="procesar.php?action=clear" class="btn btn-secondary" style="flex: 0.5;" onclick="return confirm('¿Desea limpiar todos los registros de la sesión?');">Limpiar Sesión</a>
            <?php endif; ?>
        </div>

        <div class="footer-info">
            <span>Servidor PHP (Zend Engine) • Sesión ID: <?= substr(session_id(), 0, 8); ?>...</span>
            <span>Desarrollado por Rojas</span>
        </div>
    </div>
</body>
</html>
