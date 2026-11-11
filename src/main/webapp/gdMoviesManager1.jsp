<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="dao.Movie1DAO, model.Movie1, java.util.List" %>
<%
    Movie1DAO movieDAO = new Movie1DAO();
    List<Movie1> listMovies = movieDAO.getMoviesList();

    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CineMan - Quản lý Phim</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

    <header class="cineman-navbar">
        <a href="gdHome1.jsp" class="cineman-logo">🎬 CineMan</a>
        <div class="cineman-nav-links">
            <a href="gdManagerMain1.jsp">Trang chủ Quản lý</a>
            <span class="cineman-nav-user">Manager</span>
        </div>
    </header>

    <main class="page-container" style="max-width: 650px;">
        <div class="mockup-card">
            <!-- Header matching image14.png & image16.png -->
            <div class="mockup-header">
                Quản lý Phim
            </div>

            <div class="mockup-body">
                <% if ("added".equals(msg)) { %>
                    <div class="alert-message alert-success">
                        Thêm thông tin phim thành công!
                    </div>
                <% } else if ("deleted".equals(msg)) { %>
                    <div class="alert-message alert-success">
                        Đã xóa phim khỏi hệ thống!
                    </div>
                <% } else if ("updated".equals(msg)) { %>
                    <div class="alert-message alert-success">
                        Đã cập nhật thông tin phim thành công!
                    </div>
                <% } %>

                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px;">
                    <h4 style="font-weight: 700; color: #0f172a;">
                        Danh Sách phim hiện có:
                    </h4>
                    <span style="font-style: italic; color: #475569; font-weight: 600;">Manager</span>
                </div>

                <!-- Table matching image14.png & image16.png -->
                <table class="wireframe-table" id="tblMovies">
                    <thead>
                        <tr>
                            <th style="width: 60%;">Tên Phim :</th>
                            <th style="width: 40%; text-align: center;">Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (listMovies.isEmpty()) { %>
                            <tr>
                                <td colspan="2" style="text-align: center; color: #64748b;">
                                    Chưa có phim nào trong cơ sở dữ liệu.
                                </td>
                            </tr>
                        <% } else {
                            for (Movie1 m : listMovies) { %>
                                <tr>
                                    <td>
                                        <span style="font-style: italic; font-weight: 600; font-size: 15px;">
                                            <%= m.getNameMovies() %>
                                        </span>
                                        <div style="font-size: 12px; color: #64748b;">
                                            <%= m.getType() %> | <%= m.getDuration() %>p
                                        </div>
                                    </td>
                                    <td style="text-align: center;">
                                        <a href="gdEditMovie1.jsp?id=<%= m.getId() %>" id="editMovies1" style="color: #2563eb; text-decoration: none; font-weight: 600; margin-right: 18px;">
                                            Sửa
                                        </a>
                                        <a href="DoDeleteMovie.jsp?id=<%= m.getId() %>" id="deleteMovie1" onclick="return confirm('Bạn có chắc chắn muốn xóa phim <%= m.getNameMovies() %> ?');" style="color: #dc2626; text-decoration: none; font-weight: 600;">
                                            Xóa
                                        </a>
                                    </td>
                                </tr>
                        <%  }
                        } %>
                    </tbody>
                </table>

                <!-- Buttons matching image14.png -->
                <div class="btn-group">
                    <a href="gdAddMovie1.jsp" id="addMovies1" class="btn btn-primary" style="padding: 12px 20px; font-weight: 700; font-style: italic;">
                        Thêm thông tin Phim
                    </a>
                    <a href="gdManagerMain1.jsp" class="btn btn-outline" style="min-width: 120px;">
                        Quay lại
                    </a>
                </div>

            </div>
        </div>
    </main>

    <footer>
        <p>© 2026 CineMan - Hệ thống Quản lý Rạp chiếu phim</p>
    </footer>

</body>
</html>

