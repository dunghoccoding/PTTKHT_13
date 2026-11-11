<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="dao.User1DAO, model.Customer1" %>
<%
    String msg = null;
    String newCardCode = null;
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        request.setCharacterEncoding("UTF-8");
        String hoTen = request.getParameter("hoTen");
        String sdt = request.getParameter("sdt");
        String email = request.getParameter("email");

        if (hoTen != null && sdt != null && !hoTen.trim().isEmpty() && !sdt.trim().isEmpty()) {
            newCardCode = "TV" + (int)(Math.random() * 90000 + 10000);
            Customer1 cust = new Customer1();
            cust.setUsername("user_" + sdt.trim());
            cust.setPassword("123456");
            cust.setFullName(hoTen.trim());
            cust.setPhoneNumbers(sdt.trim());
            cust.setEmail(email != null ? email.trim() : "");
            cust.setMemberCode(newCardCode);
            cust.setPoints(50);

            User1DAO dao = new User1DAO();
            dao.registerCustomer(cust);
            msg = "success";
        }
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CineMan - Xuất thẻ thành viên</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

    <header class="cineman-navbar">
        <a href="gdHome1.jsp" class="cineman-logo">🎬 CineMan - Quầy Vé</a>
        <div class="cineman-nav-links">
            <a href="gdSaleMain1.jsp">Quay lại Bán vé</a>
            <span class="cineman-nav-user">Nhân viên Bán Vé</span>
        </div>
    </header>

    <main class="page-container" style="max-width: 550px;">
        <div class="mockup-card">
            <div class="mockup-header">
                Xuất thẻ thành viên tại quầy
            </div>

            <div class="mockup-body">
                <% if ("success".equals(msg)) { %>
                    <div class="alert-message alert-success">
                        <strong>Xuất thẻ thành công!</strong><br>
                        Mã thẻ thành viên mới cấp: <span style="font-size: 18px; font-weight: 800; color: #166534;"><%= newCardCode %></span><br>
                        (Điểm tích lũy khởi tạo: 50 điểm)
                    </div>
                <% } %>

                <form method="post">
                    <div class="form-row">
                        <label class="form-label" for="hoTen">Họ tên khách(*):</label>
                        <input type="text" id="hoTen" name="hoTen" class="form-control" required placeholder="Họ và tên khách hàng">
                    </div>

                    <div class="form-row">
                        <label class="form-label" for="sdt">Số điện thoại(*):</label>
                        <input type="text" id="sdt" name="sdt" class="form-control" required placeholder="Số điện thoại khách hàng">
                    </div>

                    <div class="form-row">
                        <label class="form-label" for="email">Email:</label>
                        <input type="email" id="email" name="email" class="form-control" placeholder="Email nhận thông tin khuyến mãi">
                    </div>

                    <div class="btn-group">
                        <a href="gdSaleMain1.jsp" class="btn btn-outline">Quay lại</a>
                        <button type="submit" class="btn btn-success" style="min-width: 140px;">
                            Xác nhận xuất thẻ
                        </button>
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

