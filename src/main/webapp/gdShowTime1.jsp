<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="dao.Movie1DAO, dao.ShowTime1DAO, dao.Cinema1DAO, model.Movie1, model.ShowTime1, model.Cinema1, java.sql.Date, java.util.List, java.text.SimpleDateFormat" %>
<%
    String movieIdStr = request.getParameter("movieId");
    if (movieIdStr == null || movieIdStr.isEmpty()) {
        response.sendRedirect("gdHome1.jsp");
        return;
    }
    int movieId = Integer.parseInt(movieIdStr);

    Movie1DAO movieDAO = new Movie1DAO();
    ShowTime1DAO showTimeDAO = new ShowTime1DAO();
    Cinema1DAO cinemaDAO = new Cinema1DAO();

    Movie1 movie = movieDAO.getMovieById(movieId);
    if (movie == null) {
        response.sendRedirect("gdHome1.jsp");
        return;
    }

    List<Date> listDates = showTimeDAO.getShowDates(movieId);

    String selectedDateStr = request.getParameter("date");
    Date selectedDate = null;
    if (selectedDateStr != null && !selectedDateStr.isEmpty()) {
        try {
            selectedDate = Date.valueOf(selectedDateStr);
        } catch (Exception ignored) {}
    }
    if (selectedDate == null && !listDates.isEmpty()) {
        selectedDate = listDates.get(0);
    }

    List<ShowTime1> listShowTimes = (selectedDate != null) ? showTimeDAO.getShowTime(movieId, selectedDate) : null;

    String selectedShowTimeIdStr = request.getParameter("showTimeId");
    int selectedShowTimeId = 0;
    if (selectedShowTimeIdStr != null && !selectedShowTimeIdStr.isEmpty()) {
        try {
            selectedShowTimeId = Integer.parseInt(selectedShowTimeIdStr);
        } catch (Exception ignored) {}
    } else if (listShowTimes != null && !listShowTimes.isEmpty()) {
        selectedShowTimeId = listShowTimes.get(0).getId();
    }

    ShowTime1 selectedShowTime = (selectedShowTimeId > 0) ? showTimeDAO.getShowTimeInfo(selectedShowTimeId) : null;
    Cinema1 cinema = (selectedShowTimeId > 0) ? cinemaDAO.getCinemaOfShow(selectedShowTimeId) : null;

    SimpleDateFormat dayFormat = new SimpleDateFormat("dd/MM");
    SimpleDateFormat displayDateFormat = new SimpleDateFormat("dd/MM");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CineMan - Chọn suất chiếu</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

    <header class="cineman-navbar">
        <a href="gdHome1.jsp" class="cineman-logo">🎬 CineMan</a>
        <div class="cineman-nav-links">
            <a href="gdHome1.jsp">Trang chủ</a>
            <a href="gdHome1.jsp">← Chọn phim khác</a>
        </div>
    </header>

    <main class="page-container">
        <div class="mockup-card">
            <!-- Header matching image18.png -->
            <div class="mockup-header">
                Chọn suất chiếu
            </div>

            <div class="mockup-body">
                <!-- Movie Title Subtitle -->
                <p style="text-align: center; font-size: 16px; font-style: italic; margin-bottom: 24px;">
                    Phim: <strong><%= movie.getNameMovies() %></strong> (<%= movie.getDuration() %> phút)
                </p>

                <!-- Ngày chiếu -->
                <h4 style="margin-bottom: 10px; font-weight: 600;">Ngày chiếu</h4>
                <div class="badge-group">
                    <% if (listDates.isEmpty()) { %>
                        <p style="color: #64748b;">Hiện chưa có lịch chiếu cho phim này.</p>
                    <% } else {
                        for (Date d : listDates) {
                            boolean isActive = selectedDate != null && d.toString().equals(selectedDate.toString());
                    %>
                        <a href="gdShowTime1.jsp?movieId=<%= movieId %>&date=<%= d.toString() %>"
                           class="badge-btn <%= isActive ? "active" : "" %>">
                            <%= dayFormat.format(d) %>
                        </a>
                    <%  }
                    } %>
                </div>

                <!-- Suất chiếu trong ngày -->
                <% if (selectedDate != null) { %>
                    <h4 style="margin-bottom: 10px; font-weight: 600;">Suất chiếu trong ngày</h4>
                    <div class="badge-group">
                        <% if (listShowTimes == null || listShowTimes.isEmpty()) { %>
                            <p style="color: #64748b;">Không có suất chiếu vào ngày này.</p>
                        <% } else {
                            for (ShowTime1 st : listShowTimes) {
                                boolean isActive = (st.getId() == selectedShowTimeId);
                        %>
                            <a href="gdShowTime1.jsp?movieId=<%= movieId %>&date=<%= selectedDate.toString() %>&showTimeId=<%= st.getId() %>"
                               class="badge-btn <%= isActive ? "active" : "" %>"
                               id="selectShowtime">
                                <%= st.getHoursShow() %>
                            </a>
                        <%  }
                        } %>
                    </div>
                <% } %>

                <!-- Selected Information Line matching image18.png -->
                <% if (selectedShowTime != null) { %>
                    <div style="margin: 28px 0; font-size: 15px; color: #1e3a8a; font-style: italic; font-weight: 600;">
                        Đã chọn: <%= cinema != null ? cinema.getNameCine() : "Rạp CineMan" %> | 
                        Ngày <%= displayDateFormat.format(selectedShowTime.getDateShow()) %> | 
                        Suất <%= selectedShowTime.getHoursShow() %> 
                        (<%= selectedShowTime.getRoom() != null ? selectedShowTime.getRoom().getNameScreen() : "Phòng 01" %>)
                    </div>
                <% } %>

                <!-- Action Buttons matching image18.png -->
                <div class="btn-group">
                    <a href="gdHome1.jsp" class="btn btn-outline" style="min-width: 140px;">Quay lại</a>
                    <% if (selectedShowTime != null) { %>
                        <a href="gdConfirmShow1.jsp?showTimeId=<%= selectedShowTime.getId() %>" class="btn btn-success" id="btnAgree" style="min-width: 140px;">
                            Đồng ý
                        </a>
                    <% } %>
                </div>

            </div>
        </div>
    </main>

    <footer>
        <p>© 2026 CineMan - Hệ thống Quản lý Rạp chiếu phim</p>
    </footer>

</body>
</html>

