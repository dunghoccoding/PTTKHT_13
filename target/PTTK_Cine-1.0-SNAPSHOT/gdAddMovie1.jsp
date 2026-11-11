<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CineMan - Thêm phim mới</title>
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
            <!-- Header matching image15.png -->
            <div class="mockup-header">
                Thêm phim mới
            </div>

            <div class="mockup-body">
                <% if ("empty".equals(error)) { %>
                    <div class="alert-message alert-danger">
                        Vui lòng nhập đầy đủ tên phim và thời lượng hợp lệ! (Lỗi xác thực dữ liệu)
                    </div>
                <% } else if ("duplicate".equals(error)) { %>
                    <div class="alert-message alert-danger">
                        Trùng lặp dữ liệu: Tên phim này đã tồn tại trong hệ thống!
                    </div>
                <% } %>

                <h4 style="margin-bottom: 20px; font-weight: 600; color: #1e293b;">
                    Nhập thông tin phim mới
                </h4>

                <!-- Form matching image15.png -->
                <form action="DoAddMovie.jsp" method="post">
                    <div class="form-row">
                        <label class="form-label" for="txnameMovie">Tên phim(*)</label>
                        <input type="text" id="txnameMovie" name="txnameMovie" class="form-control" placeholder="Ví dụ: Út Lan" required>
                    </div>

                    <div class="form-row">
                        <label class="form-label" for="txtDuration">Thời lượng(phút)</label>
                        <input type="number" id="txtDuration" name="txtDuration" class="form-control" placeholder="Ví dụ: 120" required min="1">
                    </div>

                    <div class="form-row">
                        <label class="form-label" for="selType">Thể loại</label>
                        <input type="text" id="selType" name="selType" class="form-control" placeholder="Ví dụ: Tâm lý , tình cảm" list="genreOptions" required>
                        <datalist id="genreOptions">
                            <option value="Tâm lý , tình cảm">
                            <option value="Kinh dị">
                            <option value="Hành động">
                            <option value="Drama">
                            <option value="Giật gân">
                            <option value="Hoạt hình">
                            <option value="Hài hước">
                        </datalist>
                    </div>

                    <div class="form-row">
                        <label class="form-label" for="txtDirector">Đạo diễn</label>
                        <input type="text" id="txtDirector" name="txtDirector" class="form-control" placeholder="Ví dụ: Phan Tiến Dũng">
                    </div>

                    <div class="form-row">
                        <label class="form-label" for="txtCast">Diễn viên</label>
                        <input type="text" id="txtCast" name="txtCast" class="form-control" placeholder="Ví dụ: Trần Văn Chú, ...">
                    </div>

                    <div class="form-row" style="align-items: flex-start;">
                        <label class="form-label" for="txtDescription" style="padding-top: 8px;">Mô tả</label>
                        <textarea id="txtDescription" name="txtDescription" class="form-control" rows="3" placeholder="Ví dụ: Là một bộ phim tâm lý tình cảm sâu sắc..."></textarea>
                    </div>

                    <!-- Prompt and buttons matching image15.png -->
                    <div style="margin-top: 28px; display: flex; justify-content: space-between; align-items: center;">
                        <span style="font-weight: 600; font-size: 15px;">Xác nhận thêm phim ?</span>
                        <div style="display: flex; gap: 16px;">
                            <a href="gdMoviesManager1.jsp" class="btn btn-danger" style="min-width: 90px;">
                                Hủy
                            </a>
                            <button type="submit" id="btnSave" class="btn btn-success" style="min-width: 110px; font-style: italic;">
                                Xác nhận
                            </button>
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

