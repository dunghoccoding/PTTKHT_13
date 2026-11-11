<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="dao.Movie1DAO, model.Movie1, model.User1, java.util.List" %>
<%
    Movie1DAO movieDAO = new Movie1DAO();
    List<Movie1> movies = movieDAO.getMoviesList();
    User1 currentUser = (User1) session.getAttribute("currentUser");
    String staffName = (currentUser != null && currentUser.getFullName() != null)
            ? currentUser.getFullName() : "Nhân viên Bán Vé 01";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CineMan - Bán vé tại quầy</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

    <header class="cineman-navbar">
        <a href="gdHome1.jsp" class="cineman-logo">🎬 CineMan - Quầy Vé</a>
        <div class="cineman-nav-links">
            <span class="cineman-nav-user"><%= staffName %> (Salesperson)</span>
            <a href="gdIssueCard1.jsp">Xuất thẻ thành viên</a>
            <a href="logout.jsp">Đăng xuất</a>
        </div>
    </header>

    <main class="page-container" style="max-width: 800px;">
        <div class="mockup-card">
            <div class="mockup-header">
                Giao Dịch Bán Vé Tại Quầy (Counter Sales)
            </div>

            <div class="mockup-body">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                    <div>
                        <h4 style="color: #0f172a; font-weight: 700;">Chọn phim phục vụ khách tại quầy:</h4>
                        <p style="font-size: 13px; color: #64748b;">Nhân viên bán hàng chọn phim, suất chiếu và vị trí ghế theo yêu cầu của khách hàng.</p>
                    </div>
                    <a href="gdIssueCard1.jsp" class="btn btn-primary" style="font-size: 14px;">
                        + Xuất thẻ thành viên mới
                    </a>
                </div>

                <table class="wireframe-table">
                    <thead>
                        <tr>
                            <th>Tên phim</th>
                            <th>Thể loại</th>
                            <th>Thời lượng</th>
                            <th style="text-align: center;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Movie1 m : movies) { %>
                            <tr>
                                <td><strong><%= m.getNameMovies() %></strong></td>
                                <td><%= m.getType() %></td>
                                <td><%= m.getDuration() %> phút</td>
                                <td style="text-align: center;">
                                    <a href="gdShowTime1.jsp?movieId=<%= m.getId() %>" class="btn btn-success" style="padding: 6px 14px; font-size: 14px;">
                                        Bán vé ngay
                                    </a>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <footer>
        <p>© 2026 CineMan - Hệ thống Quản lý Rạp chiếu phim</p>
    </footer>

</body>
</html>

