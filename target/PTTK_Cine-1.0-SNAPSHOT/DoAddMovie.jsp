<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="dao.Movie1DAO, model.Movie1" %>
<%
    request.setCharacterEncoding("UTF-8");
    if (!"POST".equals(request.getMethod())) { response.sendError(405); return; }

    String nameMovies = request.getParameter("txnameMovie");
    String type = request.getParameter("selType");
    String durationStr = request.getParameter("txtDuration");
    String director = request.getParameter("txtDirector");
    String cast = request.getParameter("txtCast");
    String description = request.getParameter("txtDescription");

    java.util.Map<String,String> errors = new java.util.HashMap<>();
    if (nameMovies == null || nameMovies.trim().isEmpty()) errors.put("txnameMovie", "Vui lòng nhập tên phim.");
    if (type == null || type.trim().isEmpty()) errors.put("selType", "Vui lòng nhập thể loại.");
    int duration = 0;
    try {
        duration = Integer.parseInt(durationStr == null ? "" : durationStr.trim());
        if (duration <= 0) throw new NumberFormatException();
    } catch (NumberFormatException e) { errors.put("txtDuration", "Thời lượng phải là số nguyên lớn hơn 0."); }
    String[] fields = {"txnameMovie", "selType", "txtDirector", "txtCast", "txtDescription"};
    for (String field : fields) {
        String value = request.getParameter(field);
        if (value != null && value.trim().length() > 255) errors.put(field, "Tối đa 255 ký tự.");
    }
    if (!errors.isEmpty()) {
        request.setAttribute("fieldErrors", errors);
        request.getRequestDispatcher("gdAddMovie1.jsp").forward(request, response); return;
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
    try {
        if (movieDAO.addMoviesChecked(movie)) {
            response.sendRedirect("gdMoviesManager1.jsp?msg=added");
        } else {
            errors.put("txnameMovie", "Tên phim này đã tồn tại.");
            request.setAttribute("fieldErrors", errors);
            request.getRequestDispatcher("gdAddMovie1.jsp").forward(request, response);
        }
    } catch (java.sql.SQLException e) {
        application.log("Could not add movie", e);
        request.setAttribute("saveError", "Không thể lưu phim do lỗi hệ thống. Vui lòng thử lại.");
        request.getRequestDispatcher("gdAddMovie1.jsp").forward(request, response);
    }
%>
