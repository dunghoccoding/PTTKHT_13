<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="dao.BookingDAO, java.util.List, java.util.ArrayList, dao.Ticket1DAO, dao.ShowTime1DAO, dao.User1DAO, model.Ticket1, model.ShowTime1, model.User1, model.Customers1, java.text.SimpleDateFormat" %>
<%
    int showTimeId;
    List<Integer> ticketIds;
    try {
        showTimeId = Integer.parseInt(request.getParameter("showTimeId"));
        String rawIds = request.getParameter("ticketIds");
        if (rawIds == null) rawIds = request.getParameter("ticketId");
        ticketIds = BookingDAO.parseIds(rawIds);
    } catch (IllegalArgumentException e) { response.sendRedirect("gdHome1.jsp"); return; }
    Ticket1DAO ticketDAO = new Ticket1DAO();
    ShowTime1DAO showTimeDAO = new ShowTime1DAO();
    User1DAO userDAO = new User1DAO();
    ShowTime1 showTime = showTimeDAO.getShowTimeInfo(showTimeId);
    if (showTime == null) { response.sendRedirect("gdHome1.jsp"); return; }
    long holdDeadline;
    try {
        holdDeadline = new BookingDAO().hold(ticketIds, showTimeId, session.getId());
    } catch (java.sql.SQLException e) {
        application.log("Seat hold failed", e);
        response.sendRedirect("gdSeatSelect1.jsp?showTimeId=" + showTimeId + "&error=system"); return;
    }
    if (holdDeadline == 0) {
        response.sendRedirect("gdSeatSelect1.jsp?showTimeId=" + showTimeId + "&error=occupied"); return;
    }
    List<Ticket1> selectedTickets = new ArrayList<>();
    for (int id : ticketIds) {
        Ticket1 t = ticketDAO.getTicketById(id);
        if (t == null) { response.sendError(503); return; }
        selectedTickets.add(t);
    }
    String idsValue = BookingDAO.joinIds(ticketIds);
    User1 currentUser = (User1) session.getAttribute("currentUser");
    Customers1 customer = null;
    if (currentUser != null) {
        customer = userDAO.getCustomerInfo(currentUser.getId());
    }

    // Default sample customer if guest
    String customerName = (customer != null && customer.getFullName() != null) ? customer.getFullName() : "Phan Tiến Dũng";
    String customerPhone = (customer != null && customer.getPhoneNumbers() != null) ? customer.getPhoneNumbers() : "0963895JQK";
    String customerEmail = (customer != null && customer.getEmail() != null) ? customer.getEmail() : "ptit@gmail.com";

    float totalAmount = 0;
    StringBuilder seatCodes = new StringBuilder();
    for (Ticket1 t : selectedTickets) {
        totalAmount += t.getPriceTicket();
        if (seatCodes.length() > 0) seatCodes.append(", ");
        seatCodes.append(t.getSeat().getSeatCode());
    }

    SimpleDateFormat dayFmt = new SimpleDateFormat("dd/MM");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CineMan - Thanh Toán</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

    <header class="cineman-navbar">
        <a href="gdHome1.jsp" class="cineman-logo">🎬 CineMan</a>
        <div class="cineman-nav-links">
            <span class="cineman-nav-user"><%= customerName %></span>
            <a href="gdSeatSelect1.jsp?showTimeId=<%= showTimeId %>&change=1">← Chọn lại ghế</a>
        </div>
    </header>

    <main class="page-container" style="max-width: 600px;">
        <div class="mockup-card">
            <!-- Header matching image21.png -->
            <div class="mockup-header">
                Thanh Toán
            </div>

            <div class="mockup-body">
                <h4 style="margin-bottom: 20px; font-weight: 700; color: #1e293b;">
                    Thông tin thanh toán
                </h4>

                <p>Thanh toán mô phỏng. Có thể chọn nhiều ghế, chưa áp dụng ưu đãi thành viên. Thời gian giữ còn lại: <strong id="holdTimer"></strong>.</p>
                <form action="doPayMent.jsp" method="post">
                    <input type="hidden" name="ticketIds" value="<%= idsValue %>">
                    <input type="hidden" name="showTimeId" value="<%= showTimeId %>">
                    <input type="hidden" name="totalAmount" id="hiddenTotalAmount" value="<%= totalAmount %>">

                    <table class="wireframe-table">
                        <tbody>
                            <tr>
                                <td style="width: 35%; font-weight: 700; background: #f8fafc;">Họ Tên</td>
                                <td><%= customerName %></td>
                            </tr>
                            <tr>
                                <td style="font-weight: 700; background: #f8fafc;">Số ĐT</td>
                                <td><%= customerPhone %></td>
                            </tr>
                            <tr>
                                <td style="font-weight: 700; background: #f8fafc;">Email</td>
                                <td><a href="mailto:<%= customerEmail %>" style="color: #0284c7;"><%= customerEmail %></a></td>
                            </tr>
                            <tr>
                                <td style="font-weight: 700; background: #f8fafc;">Suất chiếu</td>
                                <td>
                                    <strong><%= showTime.getMovie().getNameMovies() %></strong> - 
                                    <%= showTime.getHoursShow() %> - 
                                    <%= dayFmt.format(showTime.getDateShow()) %>
                                </td>
                            </tr>
                            <tr>
                                <td style="font-weight: 700; background: #f8fafc;">Ghế ngồi</td>
                                <td>
                                    <strong><%= seatCodes %></strong>
                                </td>
                            </tr>
                            <tr>
                                <td style="font-weight: 700; background: #f8fafc;">Đơn giá</td>
                                <td><%= selectedTickets.size() %> vé · Tổng <%= String.format("%,.0f", totalAmount) %> VND</td>
                            </tr>
                            <tr>
                                <td style="font-weight: 700; background: #f8fafc; font-size: 16px;">Tổng tiền</td>
                                <td>
                                    <span style="color: #dc2626; font-size: 22px; font-weight: 800;" id="lblTotalAmount">
                                        <%= String.format("%,.0f", totalAmount) %>
                                    </span> 
                                    <span style="color: #dc2626; font-weight: 700;">VND</span>
                                </td>
                            </tr>
                            <tr>
                                <td style="font-weight: 700; background: #f8fafc;">Hình thức TT</td>
                                <td>
                                    <select name="selPaymentMethod" class="form-control" style="font-weight: 600; color: #0284c7;">
                                        <option value="Ví VNPay" selected>Ví VNPay</option>
                                        <option value="Ví MoMo">Ví MoMo</option>
                                        <option value="Thẻ ATM / Thẻ tín dụng">Thẻ ATM / Thẻ tín dụng</option>
                                        <option value="Tiền mặt tại quầy">Tiền mặt tại quầy</option>
                                    </select>
                                </td>
                            </tr>
                        </tbody>
                    </table>

                    <!-- Buttons: Hủy (đỏ) & Thanh Toán (xanh) -->
                    <div class="btn-group">
                        <a href="gdSeatSelect1.jsp?showTimeId=<%= showTimeId %>&change=1" class="btn btn-danger" style="min-width: 130px;">
                            Hủy
                        </a>
                        <button type="submit" id="btnPay" class="btn btn-success" style="min-width: 160px; font-size: 16px;">
                            Thanh Toán
                        </button>
                    </div>
                </form>

            </div>
        </div>
    </main>

    <footer>
        <p>© 2026 CineMan - Hệ thống Quản lý Rạp chiếu phim</p>
    </footer>

<script>
    const deadline = <%= holdDeadline %>;
    function updateHoldTimer() {
        const seconds = Math.max(0, Math.ceil((deadline - Date.now()) / 1000));
        document.getElementById("holdTimer").textContent = Math.floor(seconds / 60) + ":" + String(seconds % 60).padStart(2, "0");
        if (!seconds) {
            document.getElementById("btnPay").disabled = true;
            window.location.replace("gdSeatSelect1.jsp?showTimeId=<%= showTimeId %>&error=expired");
        }
    }
    updateHoldTimer();
    setInterval(updateHoldTimer, 1000);
</script>
</body>
</html>
