<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="dao.BookingDAO, model.User1, java.util.List" %>
<%
    request.setCharacterEncoding("UTF-8");
    if (!"POST".equals(request.getMethod())) { response.sendError(405); return; }
    List<Integer> ids;
    int showTimeId;
    try {
        ids = BookingDAO.parseIds(request.getParameter("ticketIds"));
        showTimeId = Integer.parseInt(request.getParameter("showTimeId"));
    } catch (IllegalArgumentException e) { response.sendRedirect("gdHome1.jsp"); return; }
    User1 currentUser = (User1) session.getAttribute("currentUser");
    try {
        int billId = new BookingDAO().checkout(ids, showTimeId, currentUser != null ? currentUser.getId() : 3, session.getId(), request.getParameter("selPaymentMethod"));
        if (billId > 0) response.sendRedirect("gdTicketBill.jsp?billId=" + billId);
        else response.sendRedirect("gdSeatSelect1.jsp?showTimeId=" + showTimeId + "&error=expired");
    } catch (java.sql.SQLException e) {
        application.log("Checkout failed", e);
        response.sendRedirect("gdSeatSelect1.jsp?showTimeId=" + showTimeId + "&error=system");
    }
%>
