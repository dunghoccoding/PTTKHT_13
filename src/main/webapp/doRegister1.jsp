<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="dao.User1DAO, model.Customer1" %>
<%
    request.setCharacterEncoding("UTF-8");

    String u = request.getParameter("username");
    String p = request.getParameter("password");
    String fn = request.getParameter("fullname");
    String em = request.getParameter("email");
    String ph = request.getParameter("phone");

    if (u != null && p != null && fn != null) {
        Customer1 cust = new Customer1();
        cust.setUsername(u.trim());
        cust.setPassword(p.trim());
        cust.setFullName(fn.trim());
        cust.setEmail(em != null ? em.trim() : "");
        cust.setPhoneNumbers(ph != null ? ph.trim() : "");
        cust.setMemberCode("TV" + System.currentTimeMillis() % 100000);
        cust.setPoints(100);

        User1DAO dao = new User1DAO();
        boolean res = dao.registerCustomer(cust);
        if (res) {
            session.setAttribute("currentUser", cust);
            session.setAttribute("customer", cust);
            response.sendRedirect("gdHome1.jsp");
            return;
        }
    }
    response.sendRedirect("gdRegister1.jsp?error=1");
%>

