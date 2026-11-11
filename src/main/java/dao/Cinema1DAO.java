package dao;

import model.Cinema1;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class Cinema1DAO extends DAO {

    public Cinema1DAO() {
        super();
    }

    public Cinema1 getCinemaOfShow(int showTimeId) {
        String sql = "SELECT c.* FROM tblCinema1 c " +
                     "JOIN tblScreenRoom1 sr ON c.id = sr.tblCinema1id " +
                     "JOIN tblShowTime1 st ON sr.id = st.tblScreenRoom1id " +
                     "WHERE st.id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, showTimeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Cinema1 c = new Cinema1();
                    c.setId(rs.getInt("id"));
                    c.setNameCine(rs.getString("nameCine"));
                    c.setAddress(rs.getString("address"));
                    c.setDescription(rs.getString("description"));
                    c.setColumn(rs.getInt("Column"));
                    return c;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Cinema1 getCinemaById(int id) {
        String sql = "SELECT * FROM tblCinema1 WHERE id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Cinema1 c = new Cinema1();
                    c.setId(rs.getInt("id"));
                    c.setNameCine(rs.getString("nameCine"));
                    c.setAddress(rs.getString("address"));
                    c.setDescription(rs.getString("description"));
                    c.setColumn(rs.getInt("Column"));
                    return c;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}

