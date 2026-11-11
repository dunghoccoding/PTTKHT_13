<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="dao.Movie1DAO, model.Movie1" %>
<%
    request.setCharacterEncoding("UTF-8");

    int id = Integer.parseInt(request.getParameter("id"));
    String nameMovies = request.getParameter("txnameMovie");
    String type = request.getParameter("selType");
    int duration = Integer.parseInt(request.getParameter("txtDuration"));
    String director = request.getParameter("txtDirector");
    String cast = request.getParameter("txtCast");
    String description = request.getParameter("txtDescription");

    Movie1 m = new Movie1();
    m.setId(id);
    m.setNameMovies(nameMovies.trim());
    m.setType(type.trim());
    m.setDuration(duration);
    m.setDirector(director);
    m.setCast(cast);
    m.setDescriptions(description);

    Movie1DAO dao = new Movie1DAO();
    dao.editMovie(m);

    response.sendRedirect("gdMoviesManager1.jsp?msg=updated");
%>

