<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<% response.setHeader("Cache-Control", "no-store"); %>
<!doctype html>
<html lang="es">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Registro de contacto | Semana 09</title><link rel="stylesheet" href="css/styles.css"></head>
<body><main>
<header><span class="badge">UNCP · DESARROLLO DE APLICACIONES WEB</span><h1>Registro de contacto</h1><p>Una conversación empieza con tus datos.</p></header>
<div class="layout"><section class="card">
<h2>Nuevo contacto</h2><p class="muted">Completa los tres campos para agregar un registro.</p>
<form action="procesar.jsp" method="post" accept-charset="UTF-8">
<label for="nombre">Nombre completo</label><input id="nombre" name="nombre" required maxlength="100" autocomplete="name" placeholder="Ej. María Tocas">
<label for="correo">Correo electrónico</label><input id="correo" name="correo" type="email" required maxlength="254" autocomplete="email" placeholder="nombre@ejemplo.com">
<label for="mensaje">Mensaje</label><textarea id="mensaje" name="mensaje" required maxlength="1000" rows="5" placeholder="Escribe tu mensaje"></textarea>
<button type="submit">Registrar contacto →</button>
</form></section>
<aside class="card accent"><span class="badge">MÓDULO JSP</span><h2>Del formulario al servidor</h2><ol><li>El navegador envía una solicitud POST.</li><li>Tomcat ejecuta la validación en JSP.</li><li>La sesión conserva tus registros.</li><li>JSTL muestra la respuesta con escape HTML.</li></ol><p>Los datos pertenecen a esta sesión del navegador. No se guardan en una base de datos.</p><a href="registros.jsp">Ver registros de mi sesión →</a></aside></div>
<footer>Semana 09 · Rojas &amp; Tocas · Java / JSP / Tomcat</footer>
</main></body></html>
