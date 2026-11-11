package dao;

import java.sql.*;
import java.util.*;

/** Session-owned, all-or-nothing holds and simulated checkout. */
public class BookingDAO {
    private static volatile boolean schemaReady;
    private static final String EMPTY = "Trống", HELD = "Đang giữ", SOLD = "Đã bán";

    public BookingDAO() throws SQLException { ensureSchema(); }

    private static synchronized void ensureSchema() throws SQLException {
        if (schemaReady) return;
        try (Connection c = DAO.openConnection()) {
            Set<String> columns = new HashSet<>();
            try (Statement st = c.createStatement(); ResultSet rs = st.executeQuery("SHOW COLUMNS FROM tblTicket1")) {
                while (rs.next()) columns.add(rs.getString("Field"));
            }
            try (Statement st = c.createStatement()) {
                if (!columns.contains("holdOwner")) st.executeUpdate("ALTER TABLE tblTicket1 ADD COLUMN holdOwner VARCHAR(128) NULL");
                if (!columns.contains("holdExpiresAt")) st.executeUpdate("ALTER TABLE tblTicket1 ADD COLUMN holdExpiresAt DATETIME NULL");
            }
            // Legacy holds have no owner/deadline and cannot be paid for safely.
            try (PreparedStatement ps = c.prepareStatement("UPDATE tblTicket1 SET status = ?, holdOwner = NULL, holdExpiresAt = NULL WHERE status = ? AND (holdOwner IS NULL OR holdExpiresAt IS NULL) AND tblBill1id IS NULL")) {
                ps.setString(1, EMPTY); ps.setString(2, HELD); ps.executeUpdate();
            }
        }
        schemaReady = true;
    }

    public static List<Integer> parseIds(String input) {
        if (input == null || input.trim().isEmpty()) throw new IllegalArgumentException("No seats");
        String[] parts = input.split(",", -1);
        if (parts.length > 100) throw new IllegalArgumentException("Too many seats");
        SortedSet<Integer> ids = new TreeSet<>();
        for (String part : parts) {
            int id = Integer.parseInt(part.trim());
            if (id <= 0 || !ids.add(id)) throw new IllegalArgumentException("Invalid seat IDs");
        }
        return new ArrayList<>(ids);
    }

    public static String joinIds(List<Integer> ids) {
        return ids.stream().map(String::valueOf).collect(java.util.stream.Collectors.joining(","));
    }

    public void release(int showTimeId, String owner) throws SQLException {
        try (Connection c = DAO.openConnection(); PreparedStatement ps = c.prepareStatement("UPDATE tblTicket1 SET status = ?, holdOwner = NULL, holdExpiresAt = NULL WHERE tblShowTime1id = ? AND holdOwner = ? AND status = ?")) {
            ps.setString(1, EMPTY); ps.setInt(2, showTimeId); ps.setString(3, owner); ps.setString(4, HELD); ps.executeUpdate();
        }
    }

    /** Returns the DB deadline in epoch milliseconds, or zero when any seat is unavailable. */
    public long hold(List<Integer> ids, int showTimeId, String owner) throws SQLException {
        if (ids.isEmpty()) return 0;
        try (Connection c = DAO.openConnection()) {
            c.setAutoCommit(false);
            try {
                long deadline;
                try (Statement st = c.createStatement(); ResultSet rs = st.executeQuery("SELECT DATE_ADD(NOW(), INTERVAL 5 MINUTE)")) {
                    rs.next(); deadline = rs.getTimestamp(1).getTime();
                }
                // Lock in ID order to avoid deadlocks between overlapping baskets.
                for (int id : new TreeSet<>(ids)) {
                    try (PreparedStatement ps = c.prepareStatement("SELECT status, holdOwner, holdExpiresAt, NOW() AS dbNow FROM tblTicket1 WHERE id = ? AND tblShowTime1id = ? FOR UPDATE")) {
                        ps.setInt(1, id); ps.setInt(2, showTimeId);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (!rs.next()) { c.rollback(); return 0; }
                            String status = rs.getString("status");
                            Timestamp expires = rs.getTimestamp("holdExpiresAt");
                            boolean active = expires != null && expires.after(rs.getTimestamp("dbNow"));
                            if (!EMPTY.equals(status) && !(HELD.equals(status) && (!active || owner.equals(rs.getString("holdOwner"))))) {
                                c.rollback(); return 0;
                            }
                            if (HELD.equals(status) && active) deadline = Math.min(deadline, expires.getTime());
                        }
                    }
                }
                try (PreparedStatement ps = c.prepareStatement("UPDATE tblTicket1 SET status = ?, holdOwner = ?, holdExpiresAt = ? WHERE id = ?")) {
                    for (int id : ids) {
                        ps.setString(1, HELD); ps.setString(2, owner); ps.setTimestamp(3, new Timestamp(deadline)); ps.setInt(4, id);
                        if (ps.executeUpdate() != 1) throw new SQLException("Seat hold failed");
                    }
                }
                c.commit(); return deadline;
            } catch (SQLException | RuntimeException e) { c.rollback(); throw e; }
        }
    }

    /** Returns one bill for all seats; a failed/expired/foreign hold sells none. */
    public int checkout(List<Integer> ids, int showTimeId, int userId, String owner, String method) throws SQLException {
        if (ids.isEmpty() || !Arrays.asList("Ví VNPay", "Ví MoMo", "Thẻ ATM / Thẻ tín dụng", "Tiền mặt tại quầy").contains(method)) return 0;
        try (Connection c = DAO.openConnection()) {
            c.setAutoCommit(false);
            try {
                float total = 0;
                for (int id : new TreeSet<>(ids)) {
                    try (PreparedStatement ps = c.prepareStatement("SELECT priceTicket FROM tblTicket1 WHERE id = ? AND tblShowTime1id = ? AND status = ? AND holdOwner = ? AND holdExpiresAt > NOW() FOR UPDATE")) {
                        ps.setInt(1, id); ps.setInt(2, showTimeId); ps.setString(3, HELD); ps.setString(4, owner);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (!rs.next()) { c.rollback(); return 0; }
                            total += rs.getFloat(1);
                        }
                    }
                }
                int customerId;
                try (PreparedStatement ps = c.prepareStatement("SELECT tblUserId FROM tblCustomers1 WHERE tblUser1id = ?")) {
                    ps.setInt(1, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) { c.rollback(); return 0; }
                        customerId = rs.getInt(1);
                    }
                }
                int billId;
                try (PreparedStatement ps = c.prepareStatement("INSERT INTO tblBill1 (dateTime,totalAmount,paymentMethod,discount,tblCustomers1id,tblStaffId) VALUES (NOW(),?,?,0,?,NULL)", Statement.RETURN_GENERATED_KEYS)) {
                    ps.setFloat(1, total); ps.setString(2, method); ps.setInt(3, customerId);
                    if (ps.executeUpdate() != 1) throw new SQLException("Bill insert failed");
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (!rs.next()) throw new SQLException("Missing bill ID");
                        billId = rs.getInt(1);
                    }
                }
                try (PreparedStatement ps = c.prepareStatement("UPDATE tblTicket1 SET status = ?, tblBill1id = ?, holdOwner = NULL, holdExpiresAt = NULL WHERE id = ? AND status = ? AND holdOwner = ? AND holdExpiresAt > NOW()")) {
                    for (int id : ids) {
                        ps.setString(1, SOLD); ps.setInt(2, billId); ps.setInt(3, id); ps.setString(4, HELD); ps.setString(5, owner);
                        if (ps.executeUpdate() != 1) throw new SQLException("Hold expired");
                    }
                }
                c.commit(); return billId;
            } catch (SQLException | RuntimeException e) { c.rollback(); throw e; }
        }
    }
}
