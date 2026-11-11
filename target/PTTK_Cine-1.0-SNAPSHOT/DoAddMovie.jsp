<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="dao.Movie1DAO, model.Movie1" %>
<%
    request.setCharacterEncoding("UTF-8");

    String nameMovies = request.getParameter("txnameMovie");
    String type = request.getParameter("selType");
    String durationStr = request.getParameter("txtDuration");
    String director = request.getParameter("txtDirector");
    String cast = request.getParameter("txtCast");
    String description = request.getParameter("txtDescription");

    // Luồng ngoại lệ 4a: Validate Movie Data1
    if (nameMovies == null || nameMovies.trim().isEmpty() || durationStr == null || durationStr.trim().isEmpty()) {
        response.sendRedirect("gdAddMovie1.jsp?error=empty");
        return;
    }

    int duration = 0;
    try {
        duration = Integer.parseInt(durationStr.trim());
        if (duration <= 0) throw new NumberFormatException();
    } catch (NumberFormatException e) {
        response.sendRedirect("gdAddMovie1.jsp?error=empty");
        return;
    }

    // Step 586-587: Đóng gói đối tượng Movie1
    Movie1 movie = new Movie1();
    movie.setNameMovies(nameMovies.trim());
    movie.setType((type != null && !type.trim().isEmpty()) ? type.trim() : "Tâm lý");
    movie.setDuration(duration);
    movie.setDirector(director != null ? director.trim() : "");
    movie.setCast(cast != null ? cast.trim() : "");
    movie.setDescriptions(description != null ? description.trim() : "");

    // Step 588-589: Gọi hàm Movie1DAO.addMovies(m: Movie1)
    Movie1DAO movieDAO = new Movie1DAO();
    boolean success = movieDAO.addMovies(movie);

    if (success) {
        // Step 591-593: Thành công -> chuyển về gdMoviesManager1.jsp
        response.sendRedirect("gdMoviesManager1.jsp?msg=added");
    } else {
        // Luồng ngoại lệ 5a: Trùng lặp dữ liệu phim đã tồn tại
        response.sendRedirect("gdAddMovie1.jsp?error=duplicate");
    }
%>

