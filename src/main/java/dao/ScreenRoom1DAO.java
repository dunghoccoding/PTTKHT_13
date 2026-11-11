package dao;

import model.Cinema1;
import model.ScreenRoom1;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ScreenRoom1DAO extends DAO {

    public ScreenRoom1DAO() {
        super();
    }

    public ScreenRoom1 getRoomOfShowTime(int showTimeId) {
        String sql = "SELECT sr.*, c.nameCine, c.address FROM tblScreenRoom1 sr " +
                     "JOIN tblCinema1 c ON sr.tblCinema1id = c.id " +
                     "JOIN tblShowTime1 st ON sr.id = st.tblScreenRoom1id " +
                     "WHERE st.id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, showTimeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ScreenRoom1 sr = new ScreenRoom1();
                    sr.setId(rs.getInt("id"));
                    sr.setNameScreen(rs.getString("nameScreen"));
                    sr.setSeatNums(rs.getInt("seatNums"));
                    sr.setDescription(rs.getString("description"));

                    Cinema1 c = new Cinema1();
                    c.setId(rs.getInt("tblCinema1id"));
                    c.setNameCine(rs.getString("nameCine"));
                    c.setAddress(rs.getString("address"));
                    sr.setCinema(c);

                    return sr;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public ScreenRoom1 getRoomById(int id) {
        String sql = "SELECT * FROM tblScreenRoom1 WHERE id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ScreenRoom1 sr = new ScreenRoom1();
                    sr.setId(rs.getInt("id"));
                    sr.setNameScreen(rs.getString("nameScreen"));
                    sr.setSeatNums(rs.getInt("seatNums"));
                    sr.setDescription(rs.getString("description"));
                    return sr;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}

