<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="dao.Movie1DAO, model.Movie1" %>
<%
    String idStr = request.getParameter("id");
    if (idStr == null || idStr.isEmpty()) {
        response.sendRedirect("gdMoviesManager1.jsp");
        return;
    }
    int id = Integer.parseInt(idStr);
    Movie1DAO movieDAO = new Movie1DAO();
    Movie1 movie = movieDAO.getMovieById(id);
    if (movie == null) {
        response.sendRedirect("gdMoviesManager1.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CineMan - Sửa thông tin phim</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

    <header class="cineman-navbar">
        <a href="gdHome1.jsp" class="cineman-logo">🎬 CineMan</a>
        <div class="cineman-nav-links">
            <a href="gdMoviesManager1.jsp">Quản lý Phim</a>
            <span class="cineman-nav-user">Manager</span>
        </div>
    </header>

    <main class="page-container" style="max-width: 650px;">
        <div class="mockup-card">
            <div class="mockup-header">
                Sửa thông tin phim
            </div>

            <div class="mockup-body">
                <form action="DoEditMovie.jsp" method="post">
                    <input type="hidden" name="id" value="<%= movie.getId() %>">

                    <div class="form-row">
                        <label class="form-label" for="txnameMovie">Tên phim(*)</label>
                        <input type="text" id="txnameMovie" name="txnameMovie" class="form-control" value="<%= movie.getNameMovies() %>" required>
                    </div>

                    <div class="form-row">
                        <label class="form-label" for="txtDuration">Thời lượng(phút)</label>
                        <input type="number" id="txtDuration" name="txtDuration" class="form-control" value="<%= movie.getDuration() %>" required min="1">
                    </div>

                    <div class="form-row">
                        <label class="form-label" for="selType">Thể loại</label>
                        <input type="text" id="selType" name="selType" class="form-control" value="<%= movie.getType() %>" required>
                    </div>

                    <div class="form-row">
                        <label class="form-label" for="txtDirector">Đạo diễn</label>
                        <input type="text" id="txtDirector" name="txtDirector" class="form-control" value="<%= movie.getDirector() != null ? movie.getDirector() : "" %>">
                    </div>

                    <div class="form-row">
                        <label class="form-label" for="txtCast">Diễn viên</label>
                        <input type="text" id="txtCast" name="txtCast" class="form-control" value="<%= movie.getCast() != null ? movie.getCast() : "" %>">
                    </div>

                    <div class="form-row" style="align-items: flex-start;">
                        <label class="form-label" for="txtDescription" style="padding-top: 8px;">Mô tả</label>
                        <textarea id="txtDescription" name="txtDescription" class="form-control" rows="3"><%= movie.getDescriptions() != null ? movie.getDescriptions() : "" %></textarea>
                    </div>

                    <div style="margin-top: 28px; display: flex; justify-content: space-between; align-items: center;">
                        <span style="font-weight: 600;">Lưu thay đổi ?</span>
                        <div style="display: flex; gap: 16px;">
                            <a href="gdMoviesManager1.jsp" class="btn btn-outline" style="min-width: 90px;">Hủy</a>
                            <button type="submit" class="btn btn-primary" style="min-width: 110px;">Lưu cập nhật</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </main>

    <footer>
        <p>© 2026 CineMan - Hệ thống Quản lý Rạp chiếu phim</p>
    </footer>

</body>
</html>

