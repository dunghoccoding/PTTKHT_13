<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="dao.User1DAO, model.User1, model.Manager1, model.SalePerson1, model.Customers1, model.Customer1" %>
<%
    request.setCharacterEncoding("UTF-8");
    String username = request.getParameter("txtUserName");
    String password = request.getParameter("txtPassword");
    String showTimeId = request.getParameter("showTimeId");

    User1DAO userDAO = new User1DAO();
    User1 user = userDAO.login(username, password);

    if (user != null) {
        session.setAttribute("currentUser", user);

        if (user instanceof Manager1) {
            session.setAttribute("manager", user);
            if (showTimeId != null && !showTimeId.isEmpty()) {
                response.sendRedirect("gdSeatSelect1.jsp?showTimeId=" + showTimeId);
            } else {
                response.sendRedirect("gdManagerMain1.jsp");
            }
        } else if (user instanceof SalePerson1) {
            session.setAttribute("saleperson", user);
            if (showTimeId != null && !showTimeId.isEmpty()) {
                response.sendRedirect("gdSeatSelect1.jsp?showTimeId=" + showTimeId);
            } else {
                response.sendRedirect("gdSaleMain1.jsp");
            }
        } else if (user instanceof Customers1) {
            session.setAttribute("customer", user);
            if (showTimeId != null && !showTimeId.isEmpty()) {
                response.sendRedirect("gdSeatSelect1.jsp?showTimeId=" + showTimeId);
            } else {
                response.sendRedirect("gdHome1.jsp");
            }
        } else {
            if (showTimeId != null && !showTimeId.isEmpty()) {
                response.sendRedirect("gdSeatSelect1.jsp?showTimeId=" + showTimeId);
            } else {
                response.sendRedirect("gdHome1.jsp");
            }
        }
    } else {
        String redirectUrl = "gdLogin1.jsp?error=invalid";
        if (showTimeId != null && !showTimeId.isEmpty()) {
            redirectUrl += "&showTimeId=" + showTimeId;
        }
        response.sendRedirect(redirectUrl);
    }
%>

