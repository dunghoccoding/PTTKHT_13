package dao;

import model.Movie1;
import model.ScreenRoom1;
import model.ShowTime1;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ShowTime1DAO extends DAO {

    public ShowTime1DAO() {
        super();
    }

    public List<Date> getShowDates(int movieId) {
        List<Date> dates = new ArrayList<>();
        String sql = "SELECT DISTINCT dateShow FROM tblShowTime1 WHERE tblMovieid = ? ORDER BY dateShow ASC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, movieId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    dates.add(rs.getDate("dateShow"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return dates;
    }

    public Date[] getShowDatesArray(int movieId) {
        List<Date> dates = getShowDates(movieId);
        return dates.toArray(new Date[0]);
    }

    public List<ShowTime1> getShowTime(int movieId, Date date) {
        List<ShowTime1> list = new ArrayList<>();
        String sql = "SELECT st.*, m.nameMovies, m.type, m.duration, sr.nameScreen, sr.seatNums " +
                     "FROM tblShowTime1 st " +
                     "JOIN tblMovie1 m ON st.tblMovieid = m.id " +
                     "JOIN tblScreenRoom1 sr ON st.tblScreenRoom1id = sr.id " +
                     "WHERE st.tblMovieid = ? AND st.dateShow = ? " +
                     "ORDER BY st.hoursShow ASC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, movieId);
            ps.setDate(2, date);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ShowTime1 st = extractShowTime(rs);
                    list.add(st);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public ShowTime1[] getShowTimeArray(int movieId, Date date) {
        List<ShowTime1> list = getShowTime(movieId, date);
        return list.toArray(new ShowTime1[0]);
    }

    public boolean checkAvailable(int showTimeId) {
        // Checks if there is any available (Trống) seat for this showtime
        String sql = "SELECT COUNT(*) FROM tblTicket1 WHERE tblShowTime1id = ? AND status = 'Trống'";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, showTimeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return true;
    }

    public ShowTime1 getShowTimeInfo(int showTimeId) {
        String sql = "SELECT st.*, m.nameMovies, m.type, m.duration, sr.nameScreen, sr.seatNums, sr.description as roomDesc, sr.tblCinema1id " +
                     "FROM tblShowTime1 st " +
                     "JOIN tblMovie1 m ON st.tblMovieid = m.id " +
                     "JOIN tblScreenRoom1 sr ON st.tblScreenRoom1id = sr.id " +
                     "WHERE st.id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, showTimeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractShowTime(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private ShowTime1 extractShowTime(ResultSet rs) throws SQLException {
        ShowTime1 st = new ShowTime1();
        st.setId(rs.getInt("id"));
        st.setDateShow(rs.getDate("dateShow"));
        st.setHoursShow(rs.getString("hoursShow"));
        st.setPriceTicket(rs.getFloat("priceTicket"));

        Movie1 m = new Movie1();
        m.setId(rs.getInt("tblMovieid"));
        m.setNameMovies(rs.getString("nameMovies"));
        m.setType(rs.getString("type"));
        m.setDuration(rs.getInt("duration"));
        st.setMovie(m);

        ScreenRoom1 sr = new ScreenRoom1();
        sr.setId(rs.getInt("tblScreenRoom1id"));
        sr.setNameScreen(rs.getString("nameScreen"));
        sr.setSeatNums(rs.getInt("seatNums"));
        st.setRoom(sr);

        return st;
    }
}

