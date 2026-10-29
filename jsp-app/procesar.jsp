<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" import="java.util.*,jakarta.servlet.http.HttpSession" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
request.setCharacterEncoding("UTF-8");
response.setHeader("Cache-Control", "no-store");
if (!"POST".equals(request.getMethod())) {
    response.setHeader("Allow", "POST");
    response.sendError(405);
    return;
}
String nombre = Optional.ofNullable(request.getParameter("nombre")).orElse("").trim();
String correo = Optional.ofNullable(request.getParameter("correo")).orElse("").trim();
String mensaje = Optional.ofNullable(request.getParameter("mensaje")).orElse("").trim();
List<String> errores = new ArrayList<>();
if (nombre.isEmpty() || nombre.length() > 100) errores.add("El nombre es obligatorio y admite hasta 100 caracteres.");
if (correo.length() > 254 || !correo.matches("^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?(?:\\.[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?)+$")) errores.add("Ingresa un correo válido de hasta 254 caracteres.");
if (mensaje.isEmpty() || mensaje.length() > 1000) errores.add("El mensaje es obligatorio y admite hasta 1000 caracteres.");
if (!errores.isEmpty()) {
    response.setStatus(400);
    request.setAttribute("errores", errores);
} else {
    HttpSession sesion = request.getSession();
    synchronized (sesion) {
        @SuppressWarnings("unchecked")
        List<Map<String, String>> registros = (List<Map<String, String>>) sesion.getAttribute("registros");
        if (registros == null) registros = new ArrayList<>();
        if (registros.size() >= 100) {
            response.setStatus(400);
            errores.add("La sesión admite hasta 100 contactos. Inicia una nueva sesión para continuar.");
            request.setAttribute("errores", errores);
        } else {
            Map<String, String> registro = new LinkedHashMap<>();
            registro.put("nombre", nombre);
            registro.put("correo", correo);
            registro.put("mensaje", mensaje);
            registros.add(registro);
            sesion.setAttribute("registros", registros);
        }
    }
    if (errores.isEmpty()) {
        // Post/Redirect/Get: actualizar la tabla no reenvía el formulario.
        response.setStatus(303);
        response.setHeader("Location", "registros.jsp");
        return;
    }
}
%>
<!doctype html><html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Revisa los datos</title><link rel="stylesheet" href="css/styles.css"></head><body><main><section class="card"><span class="badge">HTTP 400</span><h1>Revisa los datos</h1><ul><c:forEach var="error" items="${errores}"><li><c:out value="${error}"/></li></c:forEach></ul><a href="index.jsp">Volver al formulario</a></section></main></body></html>
