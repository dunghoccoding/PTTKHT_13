<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="dao.BookingDAO, dao.Ticket1DAO, dao.ShowTime1DAO, model.Ticket1, model.ShowTime1, model.Seat1, model.User1, model.Customers1, java.util.List, java.util.ArrayList" %>
<%
    String showTimeIdStr = request.getParameter("showTimeId");
    if (showTimeIdStr == null || showTimeIdStr.isEmpty()) {
        response.sendRedirect("gdHome1.jsp");
        return;
    }
    int showTimeId;
    try { showTimeId = Integer.parseInt(showTimeIdStr); }
    catch (NumberFormatException e) { response.sendRedirect("gdHome1.jsp"); return; }
    try {
        BookingDAO booking = new BookingDAO();
        if ("1".equals(request.getParameter("change")) || "expired".equals(request.getParameter("error"))) booking.release(showTimeId, session.getId());
    } catch (java.sql.SQLException e) {
        application.log("Booking database unavailable", e);
        response.sendError(503, "Không thể xử lý giữ ghế. Vui lòng thử lại sau."); return;
    }

    ShowTime1DAO showTimeDAO = new ShowTime1DAO();
    Ticket1DAO ticketDAO = new Ticket1DAO();

    ShowTime1 showTime = showTimeDAO.getShowTimeInfo(showTimeId);
    if (showTime == null) {
        response.sendRedirect("gdHome1.jsp");
        return;
    }

    List<Ticket1> seatMap = ticketDAO.getSeatMap(showTimeId);
    User1 currentUser = (User1) session.getAttribute("currentUser");

    // Optional error message
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CineMan - Chọn ghế</title>
    <link rel="stylesheet" href="css/style.css">
    <script>
        const selectedSeats = new Map();
        function selectSeat(ticketId, seatCode, typeSeat, price, status) {
            if (status !== 'Trống') {
                alert("Ghế này đã được bán, đặt trước hoặc đang được giữ. Vui lòng chọn ghế khác.");
                return;
            }
            const button = document.getElementById("seat-" + ticketId);
            if (selectedSeats.has(ticketId)) {
                selectedSeats.delete(ticketId);
                button.classList.remove("seat-selected");
                button.classList.add("seat-empty");
                button.setAttribute("aria-pressed", "false");
            } else {
                selectedSeats.set(ticketId, {code: seatCode, price: price});
                button.classList.remove("seat-empty");
                button.classList.add("seat-selected");
                button.setAttribute("aria-pressed", "true");
            }
            const seats = [...selectedSeats.values()];
            document.getElementById("selectedTicketIdInput").value = [...selectedSeats.keys()].join(",");
            document.getElementById("lblSelectedSeat").innerText = seats.length ? seats.map(s => s.code).join(", ") : "Chưa chọn ghế";
            document.getElementById("lblSelectedPrice").innerText = seats.reduce((sum, s) => sum + s.price, 0).toLocaleString('vi-VN') + " VND";
            document.getElementById("btnConfirmSeat").disabled = seats.length === 0;
        }
    </script>
</head>
<body>

    <header class="cineman-navbar">
        <a href="gdHome1.jsp" class="cineman-logo">🎬 CineMan</a>
        <div class="cineman-nav-links">
            <span class="cineman-nav-user">
                <%= currentUser != null ? currentUser.getFullName() : "Khách hàng" %>
            </span>
            <div class="timer-badge">
                Chọn nhiều ghế · Giữ 5 phút sau khi xác nhận
            </div>
            <a href="gdShowTime1.jsp?movieId=<%= showTime.getMovie().getId() %>">← Đổi suất chiếu</a>
        </div>
    </header>

    <main class="page-container" style="max-width: 850px;">
        <div class="mockup-card">
            <!-- Header matching image20.png -->
            <div class="mockup-header">
                Chọn ghế
            </div>

            <div class="mockup-body">
                <% if ("occupied".equals(error)) { %>
                    <div class="alert-message alert-danger">
                        Ghế bạn vừa chọn đã bị người khác đặt hoặc đang giữ, vui lòng chọn ghế khác.
                    </div>
                <% } else if ("expired".equals(error)) { %>
                    <div class="alert-message alert-danger">Phiên giữ ghế đã hết hạn hoặc không hợp lệ. Vui lòng chọn lại ghế.</div>
                <% } else if ("system".equals(error)) { %>
                    <div class="alert-message alert-danger">Không thể xử lý thanh toán do lỗi hệ thống. Vui lòng thử lại.</div>
                <% } %>

                <p style="text-align: center; font-size: 16px; font-style: italic; margin-bottom: 20px;">
                    <%= showTime.getRoom() != null ? showTime.getRoom().getNameScreen() : "Phòng chiếu 01" %> - 
                    Suất chiếu <%= showTime.getHoursShow() %> (<%= showTime.getMovie().getNameMovies() %>)
                </p>

                <!-- Color Legend matching image20.png -->
                <div class="seat-legend">
                    <div class="legend-item">
                        <span class="legend-box seat-empty"></span> Trống
                    </div>
                    <div class="legend-item">
                        <span class="legend-box seat-hold"></span> Đang giữ
                    </div>
                    <div class="legend-item">
                        <span class="legend-box seat-sold"></span> Đã bán
                    </div>
                    <div class="legend-item">
                        <span class="legend-box seat-booked"></span> Đặt trước
                    </div>
                    <div class="legend-item">
                        <span class="legend-box seat-selected"></span> Đang chọn
                    </div>
                </div>

                <!-- Screen Bar -->
                <div class="screen-bar">Màn hình chiếu</div>

                <!-- Sơ đồ ghế matching image20.png -->
                <form action="gdPayMent1.jsp" method="get" id="seatForm">
                    <input type="hidden" name="showTimeId" value="<%= showTimeId %>">
                    <input type="hidden" name="ticketIds" id="selectedTicketIdInput" value="">

                    <div class="seat-grid">
                        <!-- Row A: A1 - A5 (Ghế thường) -->
                        <div class="seat-row">
                            <% for (Ticket1 t : seatMap) {
                                if (t.getSeat().getSeatCode().startsWith("A")) {
                                    String cssClass = "seat-empty";
                                    if ("Đã bán".equals(t.getStatus())) cssClass = "seat-sold";
                                    else if ("Đang giữ".equals(t.getStatus())) cssClass = "seat-hold";
                                    else if ("Đặt trước".equals(t.getStatus())) cssClass = "seat-booked";
                            %>
                                <button type="button" id="seat-<%= t.getId() %>" class="seat-btn <%= cssClass %>"
                                        data-code="<%= t.getSeat().getSeatCode() %>"
                                        data-status="<%= t.getStatus() %>"
                                        onclick="selectSeat(<%= t.getId() %>, '<%= t.getSeat().getSeatCode() %>', '<%= t.getSeat().getTypeSeat() %>', <%= (long)t.getPriceTicket() %>, '<%= t.getStatus() %>')">
                                    <%= t.getSeat().getSeatCode() %>
                                </button>
                            <%  }
                            } %>
                        </div>

                        <!-- Row B: B1(V) - B5(V) (VIP) -->
                        <div class="seat-row">
                            <% for (Ticket1 t : seatMap) {
                                if (t.getSeat().getSeatCode().startsWith("B")) {
                                    String cssClass = "seat-empty";
                                    if ("Đã bán".equals(t.getStatus())) cssClass = "seat-sold";
                                    else if ("Đang giữ".equals(t.getStatus())) cssClass = "seat-hold";
                                    else if ("Đặt trước".equals(t.getStatus())) cssClass = "seat-booked";
                            %>
                                <button type="button" id="seat-<%= t.getId() %>" class="seat-btn <%= cssClass %>"
                                        data-code="<%= t.getSeat().getSeatCode() %>"
                                        data-status="<%= t.getStatus() %>"
                                        onclick="selectSeat(<%= t.getId() %>, '<%= t.getSeat().getSeatCode() %>', '<%= t.getSeat().getTypeSeat() %>', <%= (long)t.getPriceTicket() %>, '<%= t.getStatus() %>')">
                                    <%= t.getSeat().getSeatCode() %>
                                </button>
                            <%  }
                            } %>
                        </div>

                        <!-- Row C: C1 - C5 (Ghế thường) -->
                        <div class="seat-row">
                            <% for (Ticket1 t : seatMap) {
                                if (t.getSeat().getSeatCode().startsWith("C")) {
                                    String cssClass = "seat-empty";
                                    if ("Đã bán".equals(t.getStatus())) cssClass = "seat-sold";
                                    else if ("Đang giữ".equals(t.getStatus())) cssClass = "seat-hold";
                                    else if ("Đặt trước".equals(t.getStatus())) cssClass = "seat-booked";
                            %>
                                <button type="button" id="seat-<%= t.getId() %>" class="seat-btn <%= cssClass %>"
                                        data-code="<%= t.getSeat().getSeatCode() %>"
                                        data-status="<%= t.getStatus() %>"
                                        onclick="selectSeat(<%= t.getId() %>, '<%= t.getSeat().getSeatCode() %>', '<%= t.getSeat().getTypeSeat() %>', <%= (long)t.getPriceTicket() %>, '<%= t.getStatus() %>')">
                                    <%= t.getSeat().getSeatCode() %>
                                </button>
                            <%  }
                            } %>
                        </div>

                        <!-- Row D: D1(Đ) - D3(Đ) (Ghế đôi) -->
                        <div class="seat-row">
                            <% for (Ticket1 t : seatMap) {
                                if (t.getSeat().getSeatCode().startsWith("D")) {
                                    String cssClass = "seat-empty";
                                    if ("Đã bán".equals(t.getStatus())) cssClass = "seat-sold";
                                    else if ("Đang giữ".equals(t.getStatus())) cssClass = "seat-hold";
                                    else if ("Đặt trước".equals(t.getStatus())) cssClass = "seat-booked";
                            %>
                                <button type="button" id="seat-<%= t.getId() %>" class="seat-btn seat-double <%= cssClass %>"
                                        data-code="<%= t.getSeat().getSeatCode() %>"
                                        data-status="<%= t.getStatus() %>"
                                        onclick="selectSeat(<%= t.getId() %>, '<%= t.getSeat().getSeatCode() %>', '<%= t.getSeat().getTypeSeat() %>', <%= (long)t.getPriceTicket() %>, '<%= t.getStatus() %>')">
                                    <%= t.getSeat().getSeatCode() %>
                                </button>
                            <%  }
                            } %>
                        </div>
                    </div>

                    <!-- Seat Type Labels matching image20.png -->
                    <div style="text-align: center; font-size: 14px; color: #475569; margin-bottom: 24px;">
                        <em>Ghế thường &nbsp;|&nbsp; Ghế vip(V) &nbsp;|&nbsp; Ghế đôi(Đ)</em>
                    </div>

                    <!-- Selected Seat Info matching image20.png -->
                    <div style="border-top: 1px solid #cbd5e1; padding-top: 18px; display: flex; justify-content: space-between; align-items: flex-end;">
                        <div>
                            <div style="font-size: 15px; margin-bottom: 6px;">
                                <strong style="color: #15803d;">Đang chọn:</strong> 
                                <span id="lblSelectedSeat" style="font-weight: 700; color: #15803d;">Chưa chọn ghế</span>
                            </div>
                            <div style="font-size: 15px;">
                                <strong>Tổng tiền:</strong> 
                                <span id="lblSelectedPrice" style="font-weight: 700; color: #0f172a;">0 VND</span>
                            </div>
                        </div>

                        <div style="display: flex; gap: 12px;">
                            <a href="gdShowTime1.jsp?movieId=<%= showTime.getMovie().getId() %>" class="btn btn-outline">
                                Quay lại
                            </a>
                            <button type="submit" id="btnConfirmSeat" class="btn btn-success" disabled style="min-width: 140px;">
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

