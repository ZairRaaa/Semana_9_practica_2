<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
response.setHeader("Cache-Control", "no-store");
synchronized (session) {
    @SuppressWarnings("unchecked")
    List<Map<String, String>> registros = (List<Map<String, String>>) session.getAttribute("registros");
    request.setAttribute("contactos", registros == null ? Collections.emptyList() : new ArrayList<>(registros));
}
%>
<!doctype html><html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Mis contactos | Semana 09</title><link rel="stylesheet" href="css/styles.css"></head><body><main>
<header><span class="badge">JSP · SESIÓN ACTIVA</span><h1>Mis contactos</h1><p>Registros acumulados durante esta sesión.</p></header>
<section class="card"><c:choose><c:when test="${empty contactos}"><h2>Aún no hay contactos</h2><p>Registra tu primer contacto desde el formulario.</p></c:when><c:otherwise>
<div class="table-wrap"><table><caption>Contactos registrados</caption><thead><tr><th scope="col">N.º</th><th scope="col">Nombre</th><th scope="col">Correo</th><th scope="col">Mensaje</th></tr></thead><tbody>
<c:forEach var="registro" items="${contactos}" varStatus="fila"><tr><td><c:out value="${fila.count}"/></td><td><c:out value="${registro.nombre}"/></td><td><c:out value="${registro.correo}"/></td><td class="message"><c:out value="${registro.mensaje}"/></td></tr></c:forEach>
</tbody></table></div></c:otherwise></c:choose><a class="button" href="index.jsp">+ Registrar otro contacto</a></section><footer>Los registros se eliminan al caducar la sesión o reiniciar esta instancia de Tomcat.</footer>
</main></body></html>
