<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="dao.Movie1DAO, model.Movie1, model.User1, java.util.List" %>
<%
    Movie1DAO movieDAO = new Movie1DAO();
    String keyword = request.getParameter("search");
    List<Movie1> listMovies;
    if (keyword != null && !keyword.trim().isEmpty()) {
        listMovies = movieDAO.searchMovies(keyword);
    } else {
        listMovies = movieDAO.getMoviesList();
    }
    User1 currentUser = (User1) session.getAttribute("currentUser");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CineMan - Trang chủ</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <% if ("payment_failed".equals(request.getParameter("error"))) { %>
        <p role="alert">Thanh toán chưa hoàn tất: ghế đã hết hạn giữ, phiên giữ ghế không hợp lệ hoặc có lỗi xử lý. Vui lòng chọn ghế và thử lại.</p>
    <% } %>

    <!-- Header Navigation -->
    <header class="cineman-navbar">
        <a href="gdHome1.jsp" class="cineman-logo">🎬 CineMan</a>
        <div class="cineman-nav-links">
            <a href="gdHome1.jsp">Trang chủ</a>
            <% if (currentUser != null) { %>
                <span class="cineman-nav-user">Xin chào, <%= currentUser.getFullName() %></span>
                <% if (session.getAttribute("manager") != null) { %>
                    <a href="gdManagerMain1.jsp">Quản lý</a>
                <% } else if (session.getAttribute("saleperson") != null) { %>
                    <a href="gdSaleMain1.jsp">Bán vé quầy</a>
                <% } %>
                <a href="logout.jsp">Đăng xuất</a>
            <% } else { %>
                <a href="gdLogin1.jsp">Đăng nhập</a>
                <a href="gdRegister1.jsp">Đăng kí thành viên</a>
                <a href="gdManagerMain1.jsp" style="font-size:12px;opacity:0.8;">[Quản lý]</a>
            <% } %>
        </div>
    </header>

    <main class="page-container">
        <!-- Search Bar -->
        <div style="margin-bottom: 20px; display: flex; justify-content: flex-end;">
            <form action="gdHome1.jsp" method="get" style="display: flex; gap: 8px;">
                <input type="text" name="search" class="form-control" placeholder="Tìm tên phim hoặc thể loại..." value="<%= keyword != null ? keyword : "" %>" style="width: 280px;">
                <button type="submit" class="btn btn-outline">Tìm kiếm</button>
                <% if (keyword != null && !keyword.isEmpty()) { %>
                    <a href="gdHome1.jsp" class="btn btn-outline" style="text-decoration:none;">Xóa lọc</a>
                <% } %>
            </form>
        </div>

        <div class="mockup-card">
            <!-- Header matching image17.png -->
            <div class="mockup-header">
                Trang chủ
            </div>

            <div class="mockup-body">
                <h3 style="color: #0369a1; text-align: center; margin-bottom: 24px; font-weight: 700;">
                    CineMan - Danh sách phim đang chiếu
                </h3>

                <!-- Table matching image17.png -->
                <table class="wireframe-table" id="tblMovieList">
                    <thead>
                        <tr>
                            <th style="width: 35%;">Tên phim</th>
                            <th style="width: 25%;">Thể loại</th>
                            <th style="width: 20%;">Thời lượng</th>
                            <th style="width: 20%; text-align: center;">Đặt vé</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (listMovies.isEmpty()) { %>
                            <tr>
                                <td colspan="4" style="text-align: center; color: #64748b; padding: 24px;">
                                    Không tìm thấy phim phù hợp.
                                </td>
                            </tr>
                        <% } else {
                            for (Movie1 m : listMovies) { %>
                                <tr>
                                    <td>
                                        <strong style="color: #0f172a; font-size: 16px;"><%= m.getNameMovies() %></strong>
                                        <div style="font-size: 13px; color: #64748b; margin-top: 4px;">
                                            Đạo diễn: <%= m.getDirector() != null ? m.getDirector() : "N/A" %> | 
                                            Diễn viên: <%= m.getCast() != null ? m.getCast() : "N/A" %>
                                        </div>
                                    </td>
                                    <td><em><%= m.getType() %></em></td>
                                    <td><em><%= m.getDuration() %>p</em></td>
                                    <td style="text-align: center;">
                                        <a href="gdShowTime1.jsp?movieId=<%= m.getId() %>" class="btn btn-primary" id="bookTicket" style="padding: 6px 16px; font-size: 14px;">
                                            Đặt ngay
                                        </a>
                                    </td>
                                </tr>
                        <%  }
                        } %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <footer>
        <p>© 2026 CineMan - Hệ thống Quản lý Rạp chiếu phim. Nhóm Đề tài 13 - PTTKHT.</p>
    </footer>

</body>
</html>

