<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="dao.Bill1DAO, dao.Ticket1DAO, model.Bill1, model.Ticket1, java.util.List, java.text.SimpleDateFormat" %>
<%
    String billIdStr = request.getParameter("billId");
    if (billIdStr == null || billIdStr.isEmpty()) {
        response.sendRedirect("gdHome1.jsp");
        return;
    }
    int billId = Integer.parseInt(billIdStr);

    Bill1DAO billDAO = new Bill1DAO();
    Ticket1DAO ticketDAO = new Ticket1DAO();

    Bill1 bill = billDAO.getBillInfo(billId);
    if (bill == null) {
        response.sendRedirect("gdHome1.jsp");
        return;
    }

    model.User1 viewer = (model.User1) session.getAttribute("currentUser");
    if (!(viewer instanceof model.Manager1) && (bill.getCustomer() == null
            || bill.getCustomer().getId() != viewer.getId())) {
        response.sendError(403); return;
    }

    List<Ticket1> tickets = ticketDAO.getTicketOfBills(billId);
    Ticket1 firstTicket = (!tickets.isEmpty()) ? tickets.get(0) : null;

    String movieName = (firstTicket != null && firstTicket.getShowtime() != null && firstTicket.getShowtime().getMovie() != null)
            ? firstTicket.getShowtime().getMovie().getNameMovies() : "Út Lan";
    String roomName = (firstTicket != null && firstTicket.getShowtime() != null && firstTicket.getShowtime().getRoom() != null)
            ? firstTicket.getShowtime().getRoom().getNameScreen() : "Phòng chiếu 01";
    String hoursShow = (firstTicket != null && firstTicket.getShowtime() != null)
            ? firstTicket.getShowtime().getHoursShow() : "21:30";
    String dateShow = (firstTicket != null && firstTicket.getShowtime() != null && firstTicket.getShowtime().getDateShow() != null)
            ? new SimpleDateFormat("dd/MM/yyyy").format(firstTicket.getShowtime().getDateShow()) : "13/10/2026";
    StringBuilder seatInfo = new StringBuilder();
    float seatPrice = 0;
    for (Ticket1 t : tickets) {
        if (seatInfo.length() > 0) seatInfo.append(", ");
        seatInfo.append(t.getSeat().getSeatCode());
        seatPrice += t.getPriceTicket();
    }

    String customerName = (bill.getCustomer() != null && bill.getCustomer().getFullName() != null) ? bill.getCustomer().getFullName() : "Phan Tiến Dũng";
    String customerPhone = (bill.getCustomer() != null && bill.getCustomer().getPhoneNumbers() != null) ? bill.getCustomer().getPhoneNumbers() : "0963895JQK";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CineMan - Hóa đơn và Vé</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .ticket-receipt-table td {
            padding: 10px 16px;
        }
    </style>
</head>
<body>

    <header class="cineman-navbar no-print">
        <a href="gdHome1.jsp" class="cineman-logo">🎬 CineMan</a>
        <div class="cineman-nav-links">
            <a href="gdHome1.jsp">Trang chủ</a>
            <span class="cineman-nav-user"><%= customerName %></span>
        </div>
    </header>

    <main class="page-container" style="max-width: 650px;">
        <div class="mockup-card">
            <!-- Header matching image22.png -->
            <div class="mockup-header">
                Hóa đơn
            </div>

            <div class="mockup-body">
                <h4 style="margin-bottom: 16px; font-style: italic; color: #1e3a8a; font-weight: 700;">
                    Hóa đơn và Vé
                </h4>

                <table class="wireframe-table ticket-receipt-table" id="tblTicketInfo">
                    <tbody>
                        <tr>
                            <td style="width: 32%; font-weight: 700; background: #f8fafc;">Mã HD</td>
                            <td><strong style="color: #0369a1;">HD2026-0<%= bill.getId() %></strong></td>
                        </tr>
                        <tr>
                            <td style="font-weight: 700; background: #f8fafc;">Ngày tạo</td>
                            <td><%= bill.getDateTime() %></td>
                        </tr>
                        <tr>
                            <td style="font-weight: 700; background: #f8fafc;">RẠP</td>
                            <td><strong>RẠP CineMan</strong> (<%= roomName %>)</td>
                        </tr>
                        <tr>
                            <td style="font-weight: 700; background: #f8fafc;">Phim</td>
                            <td><strong style="font-size: 16px;"><%= movieName %></strong></td>
                        </tr>
                        <tr>
                            <td style="font-weight: 700; background: #f8fafc;">Suất</td>
                            <td><%= hoursShow %> - <%= dateShow %></td>
                        </tr>
                        <tr>
                            <td style="font-weight: 700; background: #f8fafc;">Ghế</td>
                            <td><strong><%= seatInfo %></strong></td>
                        </tr>
                        <tr>
                            <td style="font-weight: 700; background: #f8fafc;">Giá vé (<%= tickets.size() %> vé)</td>
                            <td><%= String.format("%,.0f", seatPrice) %> VND</td>
                        </tr>

                        <tr>
                            <td style="font-weight: 700; background: #f8fafc;">Tổng thanh toán</td>
                            <td>
                                <strong style="font-size: 18px; color: #0f172a;"><%= String.format("%,.0f", bill.getTotalAmount()) %> vnd</strong>
                                &nbsp;&nbsp;&nbsp;&nbsp;
                                <span style="color: #dc2626; font-weight: 700;">Trạng thái : Đã Thanh Toán</span>
                            </td>
                        </tr>
                        <tr>
                            <td style="font-weight: 700; background: #f8fafc;">Khách</td>
                            <td>
                                <em><%= customerName %></em> &nbsp;|&nbsp; <em><%= customerPhone %></em>
                            </td>
                        </tr>
                        <tr>
                            <td style="font-weight: 700; background: #f8fafc;">Hình thức TT</td>
                            <td><%= bill.getPaymentMethod() %></td>
                        </tr>
                    </tbody>
                </table>

                <!-- Buttons matching image22.png -->
                <div class="btn-group no-print" style="justify-content: center; gap: 24px; margin-top: 30px;">
                    <a href="gdHome1.jsp" class="btn btn-outline" id="backHome" style="min-width: 150px;">
                        Về trang chủ
                    </a>
                    <button type="button" class="btn btn-success" id="btnPrint" onclick="window.print()" style="min-width: 180px;">
                        In Vé / Hóa Đơn
                    </button>
                </div>

            </div>
        </div>
    </main>

    <footer class="no-print">
        <p>© 2026 CineMan - Hệ thống Quản lý Rạp chiếu phim</p>
    </footer>

</body>
</html>

