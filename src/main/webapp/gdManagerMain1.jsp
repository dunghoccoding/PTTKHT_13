<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="model.User1, model.Manager1" %>
<%
    User1 currentUser = (User1) session.getAttribute("currentUser");
    String managerName = (currentUser != null && currentUser.getFullName() != null)
            ? currentUser.getFullName() : "Manager Nguyễn Văn A";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CineMan - Trang chủ Quản lý</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

    <header class="cineman-navbar">
        <a href="gdHome1.jsp" class="cineman-logo">🎬 CineMan</a>
        <div class="cineman-nav-links">
            <a href="gdHome1.jsp">Xem trang người dùng</a>
            <span class="cineman-nav-user"><%= managerName %></span>
            <a href="logout.jsp">Đăng xuất</a>
        </div>
    </header>

    <main class="page-container" style="max-width: 550px;">
        <div class="mockup-card">
            <!-- Header matching image13.png -->
            <div class="mockup-header">
                Trang chủ Quản lý
            </div>

            <div class="mockup-body" style="text-align: center; padding: 40px 30px;">
                <p style="font-size: 17px; font-style: italic; margin-bottom: 24px; color: #1e293b;">
                    Xin chào, <%= managerName %> !
                </p>

                <h4 style="font-weight: 700; margin-bottom: 24px; color: #0f172a;">
                    Chọn chức năng quản lý:
                </h4>

                <div style="display: flex; flex-direction: column; gap: 16px; align-items: center;">
                    <!-- Button matching image13.png -->
                    <a href="gdMoviesManager1.jsp" id="managerMovies1" class="btn btn-primary" 
                       style="width: 80%; padding: 14px; font-size: 17px; font-style: italic; text-decoration: underline;">
                        Quản lý thông tin phim
                    </a>

                    <!-- Button matching image13.png: Tô xám và vô hiệu hóa theo yêu cầu phạm vi bài tập -->
                    <div style="width: 80%; padding: 14px; font-size: 16px; font-weight: 700; background: #e2e8f0; color: #94a3b8; border: 1px solid #cbd5e1; border-radius: 6px; cursor: not-allowed; user-select: none;">
                        Xem thông tin báo cáo
                    </div>
                </div>

                <div style="margin-top: 36px;">
                    <a href="gdHome1.jsp" style="color: #64748b; font-size: 14px; text-decoration: none;">
                        ← Về trang chủ rạp
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

