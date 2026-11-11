<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="dao.ShowTime1DAO, dao.Cinema1DAO, dao.ScreenRoom1DAO, model.ShowTime1, model.Cinema1, model.ScreenRoom1, model.User1, java.text.SimpleDateFormat" %>
<%
    String showTimeIdStr = request.getParameter("showTimeId");
    if (showTimeIdStr == null || showTimeIdStr.isEmpty()) {
        response.sendRedirect("gdHome1.jsp");
        return;
    }
    int showTimeId = Integer.parseInt(showTimeIdStr);

    ShowTime1DAO showTimeDAO = new ShowTime1DAO();
    Cinema1DAO cinemaDAO = new Cinema1DAO();
    ScreenRoom1DAO roomDAO = new ScreenRoom1DAO();

    ShowTime1 showTime = showTimeDAO.getShowTimeInfo(showTimeId);
    if (showTime == null) {
        response.sendRedirect("gdHome1.jsp");
        return;
    }

    Cinema1 cinema = cinemaDAO.getCinemaOfShow(showTimeId);
    ScreenRoom1 room = roomDAO.getRoomOfShowTime(showTimeId);
    User1 currentUser = (User1) session.getAttribute("currentUser");

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CineMan - Xác nhận suất chiếu</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

    <header class="cineman-navbar">
        <a href="gdHome1.jsp" class="cineman-logo">🎬 CineMan</a>
        <div class="cineman-nav-links">
            <a href="gdShowTime1.jsp?movieId=<%= showTime.getMovie().getId() %>">← Đổi suất khác</a>
        </div>
    </header>

    <main class="page-container" style="max-width: 600px;">
        <div class="mockup-card">
            <!-- Header matching step 6 wireframe (lines 386-395) -->
            <div class="mockup-header">
                <%= showTime.getMovie().getNameMovies() %>
            </div>

            <div class="mockup-body">
                <table class="wireframe-table" style="margin-top: 0;">
                    <tbody>
                        <tr>
                            <td style="font-weight: 700; width: 40%; background: #f8fafc;">Rạp chiếu</td>
                            <td><strong><%= cinema != null ? cinema.getNameCine() : "Rạp CineMan" %></strong></td>
                        </tr>
                        <tr>
                            <td style="font-weight: 700; background: #f8fafc;">Phòng chiếu</td>
                            <td><%= room != null ? room.getNameScreen() : "Phòng chiếu 01" %></td>
                        </tr>
                        <tr>
                            <td style="font-weight: 700; background: #f8fafc;">Ngày chiếu</td>
                            <td><%= sdf.format(showTime.getDateShow()) %></td>
                        </tr>
                        <tr>
                            <td style="font-weight: 700; background: #f8fafc;">Giờ chiếu</td>
                            <td><span style="font-size: 18px; font-weight: 700; color: #0284c7;"><%= showTime.getHoursShow() %></span></td>
                        </tr>
                        <tr>
                            <td style="font-weight: 700; background: #f8fafc;">Giá vé cơ bản</td>
                            <td><%= String.format("%,.0f", showTime.getPriceTicket()) %> VND</td>
                        </tr>
                    </tbody>
                </table>

                <div class="btn-group" style="justify-content: flex-end; gap: 12px;">
                    <a href="gdShowTime1.jsp?movieId=<%= showTime.getMovie().getId() %>" class="btn btn-outline">Quay lại</a>
                    <% if (currentUser != null) { %>
                        <a href="gdSeatSelect1.jsp?showTimeId=<%= showTimeId %>" class="btn btn-success" id="btnAgree" style="min-width: 140px;">
                            Đồng ý
                        </a>
                    <% } else { %>
                        <!-- Step 8: System asks customer to login -->
                        <a href="gdLogin1.jsp?showTimeId=<%= showTimeId %>" class="btn btn-success" id="btnAgree" style="min-width: 140px;">
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

