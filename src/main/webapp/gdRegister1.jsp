<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CineMan - Đăng kí thành viên</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

    <header class="cineman-navbar">
        <a href="gdHome1.jsp" class="cineman-logo">🎬 CineMan</a>
        <div class="cineman-nav-links">
            <a href="gdHome1.jsp">Trang chủ</a>
            <a href="gdLogin1.jsp">Đăng nhập</a>
        </div>
    </header>

    <main class="page-container" style="max-width: 550px;">
        <div class="mockup-card">
            <div class="mockup-header">
                Đăng kí thành viên
            </div>

            <div class="mockup-body">
                <form action="doRegister1.jsp" method="post">
                    <div class="form-row">
                        <label class="form-label" for="username">Tài khoản(*):</label>
                        <input type="text" id="username" name="username" class="form-control" required placeholder="Tên đăng nhập">
                    </div>

                    <div class="form-row">
                        <label class="form-label" for="password">Mật khẩu(*):</label>
                        <input type="password" id="password" name="password" class="form-control" required placeholder="Mật khẩu bảo mật">
                    </div>

                    <div class="form-row">
                        <label class="form-label" for="fullname">Họ tên(*):</label>
                        <input type="text" id="fullname" name="fullname" class="form-control" required placeholder="Họ và tên của bạn">
                    </div>

                    <div class="form-row">
                        <label class="form-label" for="email">Email:</label>
                        <input type="email" id="email" name="email" class="form-control" placeholder="example@email.com">
                    </div>

                    <div class="form-row">
                        <label class="form-label" for="phone">Số điện thoại:</label>
                        <input type="text" id="phone" name="phone" class="form-control" placeholder="09xxxxxxxx">
                    </div>

                    <div style="margin-top: 24px; text-align: center;">
                        <button type="submit" class="btn btn-primary" style="width: 100%; padding: 12px; font-size: 16px;">
                            Đăng kí thành viên
                        </button>
                    </div>
                </form>

                <div style="margin-top: 16px; text-align: center; font-size: 14px;">
                    Đã có tài khoản? <a href="gdLogin1.jsp" style="color: #0284c7; font-weight: 600;">Đăng nhập ngay</a>
                </div>
            </div>
        </div>
    </main>

    <footer>
        <p>© 2026 CineMan - Hệ thống Quản lý Rạp chiếu phim</p>
    </footer>

</body>
</html>

