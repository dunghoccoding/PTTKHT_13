package dao;

import model.Bill1;
import model.Customer1;
import model.Customers1;
import model.Ticket1;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class Bill1DAO extends DAO {

    public Bill1DAO() {
        super();
    }

    public float calcTotal(List<Ticket1> tickets) {
        if (tickets == null) return 0f;
        float total = 0f;
        for (Ticket1 t : tickets) {
            total += t.getPriceTicket();
        }
        return total;
    }

    public float calcTotal(Ticket1[] tickets) {
        if (tickets == null) return 0f;
        float total = 0f;
        for (Ticket1 t : tickets) {
            total += t.getPriceTicket();
        }
        return total;
    }

    public Bill1 createBills(Customers1 customer, List<Ticket1> tickets) {
        float finalTotal = calcTotal(tickets);
        float discount = 0f;

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        String nowStr = sdf.format(new Date());

        String sql = "INSERT INTO tblBill1 (dateTime, totalAmount, paymentMethod, discount, tblCustomers1id, tblStaffId) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = getConnection().prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, nowStr);
            ps.setFloat(2, finalTotal);
            ps.setString(3, "Chưa thanh toán");
            ps.setFloat(4, discount);
            ps.setInt(5, customer != null ? customer.getId() : 3);
            ps.setNull(6, java.sql.Types.INTEGER);

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        Bill1 b = new Bill1();
                        b.setId(rs.getInt(1));
                        b.setDateTime(nowStr);
                        b.setTotalAmount(finalTotal);
                        b.setPaymentMethod("Chưa thanh toán");
                        b.setDiscount(discount);
                        b.setCustomer(customer);
                        b.setDsTicket(tickets);
                        return b;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Bill1 createBills(Customer1 customer, Ticket1[] tickets) {
        List<Ticket1> list = new ArrayList<>();
        if (tickets != null) {
            for (Ticket1 t : tickets) list.add(t);
        }
        return createBills((Customers1) customer, list);
    }

    /** Demo payment and ticket sale commit together; a stale/foreign hold creates no bill. */
    public int checkout(int ticketId, int customerId, String owner, String method) {
        if (!("Ví VNPay".equals(method) || "Ví MoMo".equals(method)
                || "Thẻ ATM / Thẻ tín dụng".equals(method) || "Tiền mặt tại quầy".equals(method))) return 0;
        try (java.sql.Connection c = DAO.openConnection()) {
            c.setAutoCommit(false);
            try {
                float price;
                try (PreparedStatement ps = c.prepareStatement("SELECT priceTicket FROM tblTicket1 WHERE id = ? AND status = 'Đang giữ' AND holdOwner = ? AND holdExpiresAt > NOW() FOR UPDATE")) {
                    ps.setInt(1, ticketId); ps.setString(2, owner);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) { c.rollback(); return 0; }
                        price = rs.getFloat(1);
                    }
                }
                int billId;
                try (PreparedStatement ps = c.prepareStatement("INSERT INTO tblBill1 (dateTime, totalAmount, paymentMethod, discount, tblCustomers1id, tblStaffId) VALUES (NOW(), ?, ?, 0, ?, NULL)", Statement.RETURN_GENERATED_KEYS)) {
                    ps.setFloat(1, price); ps.setString(2, method); ps.setInt(3, customerId);
                    if (ps.executeUpdate() != 1) throw new SQLException("Bill insert failed");
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (!rs.next()) throw new SQLException("Missing bill ID");
                        billId = rs.getInt(1);
                    }
                }
                try (PreparedStatement ps = c.prepareStatement("UPDATE tblTicket1 SET status = 'Đã bán', tblBill1id = ?, holdOwner = NULL, holdExpiresAt = NULL WHERE id = ? AND status = 'Đang giữ' AND holdOwner = ? AND holdExpiresAt > NOW()")) {
                    ps.setInt(1, billId); ps.setInt(2, ticketId); ps.setString(3, owner);
                    if (ps.executeUpdate() != 1) throw new SQLException("Hold expired");
                }
                c.commit();
                return billId;
            } catch (SQLException e) { c.rollback(); throw e; }
        } catch (SQLException e) { e.printStackTrace(); return 0; }
    }

    public boolean pay(Bill1 bill, String paymentMethod) {
        if (bill == null) return false;
        String sql = "UPDATE tblBill1 SET paymentMethod = ? WHERE id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, paymentMethod);
            ps.setInt(2, bill.getId());
            int affected = ps.executeUpdate();
            if (affected > 0) {
                bill.setPaymentMethod(paymentMethod);
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateStatus(int billId, String status) {
        String sql = "UPDATE tblBill1 SET paymentMethod = ? WHERE id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, billId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public Bill1 getBillInfo(int billId) {
        String sql = "SELECT b.*, u.id as uid, u.fullname, u.email, u.phoneNumbers, c.memberCode, c.points " +
                     "FROM tblBill1 b " +
                     "LEFT JOIN tblCustomers1 c ON b.tblCustomers1id = c.tblUserId " +
                     "LEFT JOIN tblUser1 u ON c.tblUser1id = u.id " +
                     "WHERE b.id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, billId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Bill1 b = new Bill1();
                    b.setId(rs.getInt("id"));
                    b.setDateTime(rs.getString("dateTime"));
                    b.setTotalAmount(rs.getFloat("totalAmount"));
                    b.setPaymentMethod(rs.getString("paymentMethod"));
                    b.setDiscount(rs.getFloat("discount"));

                    Customer1 cust = new Customer1();
                    cust.setId(rs.getInt("uid"));
                    cust.setFullName(rs.getString("fullname"));
                    cust.setEmail(rs.getString("email"));
                    cust.setPhoneNumbers(rs.getString("phoneNumbers"));
                    cust.setMemberCode(rs.getString("memberCode"));
                    cust.setPoints(rs.getInt("points"));
                    b.setCustomer(cust);

                    return b;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Bill1> getAllBills() {
        List<Bill1> list = new ArrayList<>();
        String sql = "SELECT b.*, u.fullname, u.phoneNumbers, c.memberCode " +
                     "FROM tblBill1 b " +
                     "LEFT JOIN tblCustomers1 c ON b.tblCustomers1id = c.tblUserId " +
                     "LEFT JOIN tblUser1 u ON c.tblUser1id = u.id " +
                     "ORDER BY b.id DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Bill1 b = new Bill1();
                b.setId(rs.getInt("id"));
                b.setDateTime(rs.getString("dateTime"));
                b.setTotalAmount(rs.getFloat("totalAmount"));
                b.setPaymentMethod(rs.getString("paymentMethod"));
                b.setDiscount(rs.getFloat("discount"));

                Customer1 cust = new Customer1();
                cust.setFullName(rs.getString("fullname"));
                cust.setPhoneNumbers(rs.getString("phoneNumbers"));
                cust.setMemberCode(rs.getString("memberCode"));
                b.setCustomer(cust);

                list.add(b);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}

