package dao;

import model.*;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class Ticket1DAO extends DAO {

    public Ticket1DAO() {
        super();
    }

    public synchronized List<Ticket1> getSeatMap(int showTimeId) {
        releaseExpiredHolds();
        ensureTicketsForShowtime(showTimeId);
        List<Ticket1> list = new ArrayList<>();
        String sql = "SELECT t.*, s.seatCode, s.typeSeat, s.numSeats, s.tblScreenRoom1id " +
                     "FROM tblTicket1 t " +
                     "JOIN tblSeat1 s ON t.tblSeat1id = s.id " +
                     "WHERE t.tblShowTime1id = ? " +
                     "ORDER BY s.id ASC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, showTimeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Ticket1 t = new Ticket1();
                    t.setId(rs.getInt("id"));
                    t.setPriceTicket(rs.getFloat("priceTicket"));
                    t.setStatus(rs.getString("status"));

                    Seat1 s = new Seat1();
                    s.setId(rs.getInt("tblSeat1id"));
                    s.setSeatCode(rs.getString("seatCode"));
                    s.setTypeSeat(rs.getString("typeSeat"));
                    s.setNumSeats(rs.getInt("numSeats"));
                    t.setSeat(s);

                    ShowTime1 st = new ShowTime1();
                    st.setId(showTimeId);
                    t.setShowtime(st);

                    list.add(t);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Ticket1[] getSeatMapArray(int showTimeId) {
        List<Ticket1> list = getSeatMap(showTimeId);
        return list.toArray(new Ticket1[0]);
    }

    private void ensureTicketsForShowtime(int showTimeId) {
        // Check if tickets already generated
        String checkSql = "SELECT COUNT(*) FROM tblTicket1 WHERE tblShowTime1id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(checkSql)) {
            ps.setInt(1, showTimeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    return; // already has tickets
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return;
        }

        // Get showtime details (room and base price)
        String stSql = "SELECT tblScreenRoom1id, priceTicket FROM tblShowTime1 WHERE id = ?";
        int roomId = 0;
        float basePrice = 45000;
        try (PreparedStatement ps = getConnection().prepareStatement(stSql)) {
            ps.setInt(1, showTimeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    roomId = rs.getInt("tblScreenRoom1id");
                    basePrice = rs.getFloat("priceTicket");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return;
        }

        // Insert tickets for all seats in this room
        String getSeats = "SELECT id, typeSeat FROM tblSeat1 WHERE tblScreenRoom1id = ?";
        String insertTicket = "INSERT INTO tblTicket1 (priceTicket, status, tblShowTime1id, tblSeat1id) VALUES (?, 'Trống', ?, ?)";
        try (PreparedStatement psSeats = getConnection().prepareStatement(getSeats);
             PreparedStatement psIns = getConnection().prepareStatement(insertTicket)) {
            psSeats.setInt(1, roomId);
            try (ResultSet rs = psSeats.executeQuery()) {
                while (rs.next()) {
                    int seatId = rs.getInt("id");
                    String type = rs.getString("typeSeat");
                    float price = basePrice;
                    if (type != null && type.toLowerCase().contains("vip")) {
                        price = basePrice * 1.333333f; // e.g. 60000 if 45000
                    } else if (type != null && (type.toLowerCase().contains("đôi") || type.toLowerCase().contains("doi"))) {
                        price = basePrice * 2.0f; // e.g. 90000 if 45000
                    }
                    psIns.setFloat(1, price);
                    psIns.setInt(2, showTimeId);
                    psIns.setInt(3, seatId);
                    psIns.addBatch();
                }
                psIns.executeBatch();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public synchronized boolean checkSeat(int showTimeId, int seatId) {
        String sql = "SELECT status FROM tblTicket1 WHERE tblShowTime1id = ? AND tblSeat1id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, showTimeId);
            ps.setInt(2, seatId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String status = rs.getString("status");
                    return "Trống".equalsIgnoreCase(status);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Atomically claim a seat, or retain this session's unexpired hold without extending it. */
    public boolean holdTicket(int ticketId, int showTimeId, String owner) {
        String sql = "UPDATE tblTicket1 SET holdExpiresAt = CASE WHEN status = 'Đang giữ' AND holdOwner = ? AND holdExpiresAt > NOW() THEN holdExpiresAt ELSE DATE_ADD(NOW(), INTERVAL 5 MINUTE) END, holdOwner = ?, status = 'Đang giữ' WHERE id = ? AND tblShowTime1id = ? AND (status = 'Trống' OR (status = 'Đang giữ' AND (holdExpiresAt <= NOW() OR holdOwner = ?)))";
        try (Connection c = DAO.openConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, owner); ps.setString(2, owner);
            ps.setInt(3, ticketId); ps.setInt(4, showTimeId); ps.setString(5, owner);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public void releaseExpiredHolds() {
        try (Connection c = DAO.openConnection(); PreparedStatement ps = c.prepareStatement(
                "UPDATE tblTicket1 SET status = 'Trống', holdOwner = NULL, holdExpiresAt = NULL WHERE status = 'Đang giữ' AND holdExpiresAt <= NOW()")) {
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    public synchronized boolean holdSeat(int showTimeId, int seatId) {
        if (!checkSeat(showTimeId, seatId)) {
            return false;
        }
        String sql = "UPDATE tblTicket1 SET status = 'Đang giữ' WHERE tblShowTime1id = ? AND tblSeat1id = ? AND status = 'Trống'";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, showTimeId);
            ps.setInt(2, seatId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public synchronized boolean releaseHold(int showTimeId, int seatId) {
        String sql = "UPDATE tblTicket1 SET status = 'Trống' WHERE tblShowTime1id = ? AND tblSeat1id = ? AND status = 'Đang giữ'";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, showTimeId);
            ps.setInt(2, seatId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public synchronized boolean markSold(List<Ticket1> tickets) {
        if (tickets == null || tickets.isEmpty()) {
            return false;
        }
        String sql = "UPDATE tblTicket1 SET status = 'Đã bán', tblBill1id = ? WHERE id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            for (Ticket1 t : tickets) {
                ps.setInt(1, t.getBill() != null ? t.getBill().getId() : 0);
                ps.setInt(2, t.getId());
                ps.addBatch();
            }
            int[] res = ps.executeBatch();
            return res.length == tickets.size();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean markSold(Ticket1[] tickets) {
        if (tickets == null) return false;
        List<Ticket1> list = new ArrayList<>();
        for (Ticket1 t : tickets) list.add(t);
        return markSold(list);
    }

    public List<Ticket1> getTicketOfBills(int billId) {
        List<Ticket1> list = new ArrayList<>();
        String sql = "SELECT t.*, s.seatCode, s.typeSeat, st.dateShow, st.hoursShow, m.nameMovies, sr.nameScreen " +
                     "FROM tblTicket1 t " +
                     "JOIN tblSeat1 s ON t.tblSeat1id = s.id " +
                     "JOIN tblShowTime1 st ON t.tblShowTime1id = st.id " +
                     "JOIN tblMovie1 m ON st.tblMovieid = m.id " +
                     "JOIN tblScreenRoom1 sr ON st.tblScreenRoom1id = sr.id " +
                     "WHERE t.tblBill1id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, billId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Ticket1 t = new Ticket1();
                    t.setId(rs.getInt("id"));
                    t.setPriceTicket(rs.getFloat("priceTicket"));
                    t.setStatus(rs.getString("status"));

                    Seat1 s = new Seat1();
                    s.setId(rs.getInt("tblSeat1id"));
                    s.setSeatCode(rs.getString("seatCode"));
                    s.setTypeSeat(rs.getString("typeSeat"));
                    t.setSeat(s);

                    ShowTime1 st = new ShowTime1();
                    st.setId(rs.getInt("tblShowTime1id"));
                    st.setDateShow(rs.getDate("dateShow"));
                    st.setHoursShow(rs.getString("hoursShow"));

                    Movie1 m = new Movie1();
                    m.setNameMovies(rs.getString("nameMovies"));
                    st.setMovie(m);

                    ScreenRoom1 sr = new ScreenRoom1();
                    sr.setNameScreen(rs.getString("nameScreen"));
                    st.setRoom(sr);

                    t.setShowtime(st);

                    Bill1 b = new Bill1();
                    b.setId(billId);
                    t.setBill(b);

                    list.add(t);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Ticket1[] getTicketOfBillsArray(int billId) {
        List<Ticket1> list = getTicketOfBills(billId);
        return list.toArray(new Ticket1[0]);
    }

    public Ticket1 getTicketById(int ticketId) {
        String sql = "SELECT t.*, s.seatCode, s.typeSeat, s.numSeats FROM tblTicket1 t " +
                     "JOIN tblSeat1 s ON t.tblSeat1id = s.id WHERE t.id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Ticket1 t = new Ticket1();
                    t.setId(rs.getInt("id"));
                    t.setPriceTicket(rs.getFloat("priceTicket"));
                    t.setStatus(rs.getString("status"));

                    Seat1 s = new Seat1();
                    s.setId(rs.getInt("tblSeat1id"));
                    s.setSeatCode(rs.getString("seatCode"));
                    s.setTypeSeat(rs.getString("typeSeat"));
                    s.setNumSeats(rs.getInt("numSeats"));
                    t.setSeat(s);
                    return t;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}

