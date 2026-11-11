<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    String error = request.getParameter("error");
    String showTimeId = request.getParameter("showTimeId");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CineMan - Đăng nhập</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

    <header class="cineman-navbar">
        <a href="gdHome1.jsp" class="cineman-logo">🎬 CineMan</a>
        <div class="cineman-nav-links">
            <a href="gdHome1.jsp">Trang chủ</a>
        </div>
    </header>

    <main class="page-container" style="max-width: 500px;">
        <div class="mockup-card">
            <!-- Header matching image19.png -->
            <div class="mockup-header">
                Đăng nhập
            </div>

            <div class="mockup-body">
                <% if ("invalid".equals(error)) { %>
                    <div class="alert-message alert-danger">
                        Tài khoản hoặc mật khẩu không chính xác. Vui lòng thử lại!
                    </div>
                <% } %>

                <form action="doLogin1.jsp" method="post">
                    <% if (showTimeId != null && !showTimeId.isEmpty()) { %>
                        <input type="hidden" name="showTimeId" value="<%= showTimeId %>">
                    <% } %>

                    <div class="form-row">
                        <label class="form-label" for="txtUserName">Tài khoản:</label>
                        <input type="text" id="txtUserName" name="txtUserName" class="form-control" placeholder="Nhập tên đăng nhập..." required>
                    </div>

                    <div class="form-row">
                        <label class="form-label" for="txtPassword">Mật khẩu:</label>
                        <input type="password" id="txtPassword" name="txtPassword" class="form-control" placeholder="Nhập mật khẩu..." required>
                    </div>

                    <div style="margin-top: 24px; text-align: center;">
                        <button type="submit" id="btnLogin" class="btn btn-primary" style="width: 100%; padding: 12px; font-size: 16px;">
                            Đăng nhập
                        </button>
                    </div>
                </form>

                <div style="margin-top: 20px; text-align: center; font-size: 14px;">
                    <a href="gdRegister1.jsp" style="color: #0369a1; text-decoration: underline;">
                        <em>Đăng kí ngay</em>
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

