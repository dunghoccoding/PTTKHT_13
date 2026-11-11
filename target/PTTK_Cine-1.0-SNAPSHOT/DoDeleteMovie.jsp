<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="dao.Movie1DAO" %>
<%
    String idStr = request.getParameter("id");
    if (idStr != null && !idStr.isEmpty()) {
        int id = Integer.parseInt(idStr);
        Movie1DAO dao = new Movie1DAO();
        dao.deleteMovie(id);
    }
    response.sendRedirect("gdMoviesManager1.jsp?msg=deleted");
%>

