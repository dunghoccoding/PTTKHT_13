package dao;

import model.Movie1;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class Movie1DAO extends DAO {

    public Movie1DAO() {
        super();
    }

    public List<Movie1> getMoviesList() {
        List<Movie1> list = new ArrayList<>();
        String sql = "SELECT * FROM tblMovie1 ORDER BY id DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Movie1 m = new Movie1();
                m.setId(rs.getInt("id"));
                m.setNameMovies(rs.getString("nameMovies"));
                m.setType(rs.getString("type"));
                m.setDuration(rs.getInt("duration"));
                m.setCast(rs.getString("cast"));
                m.setDirector(rs.getString("director"));
                m.setDescriptions(rs.getString("description"));
                list.add(m);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Movie1[] getMoviesListArray() {
        List<Movie1> list = getMoviesList();
        return list.toArray(new Movie1[0]);
    }

    public boolean addMovies(Movie1 m) {
        String checkSql = "SELECT id FROM tblMovie1 WHERE LOWER(nameMovies) = LOWER(?)";
        try (PreparedStatement psCheck = getConnection().prepareStatement(checkSql)) {
            psCheck.setString(1, m.getNameMovies().trim());
            try (ResultSet rsCheck = psCheck.executeQuery()) {
                if (rsCheck.next()) {
                    // Movie already exists (luong ngoai le 5a trong dac ta)
                    return false;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }

        String sql = "INSERT INTO tblMovie1 (nameMovies, type, duration, cast, director, description) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = getConnection().prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, m.getNameMovies());
            ps.setString(2, m.getType());
            ps.setInt(3, m.getDuration());
            ps.setString(4, m.getCast());
            ps.setString(5, m.getDirector());
            ps.setString(6, m.getDescriptions() != null ? m.getDescriptions() : m.getDescription());
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        m.setId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public Movie1 getMovieById(int id) {
        String sql = "SELECT * FROM tblMovie1 WHERE id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Movie1 m = new Movie1();
                    m.setId(rs.getInt("id"));
                    m.setNameMovies(rs.getString("nameMovies"));
                    m.setType(rs.getString("type"));
                    m.setDuration(rs.getInt("duration"));
                    m.setCast(rs.getString("cast"));
                    m.setDirector(rs.getString("director"));
                    m.setDescriptions(rs.getString("description"));
                    return m;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean editMovie(Movie1 m) {
        String sql = "UPDATE tblMovie1 SET nameMovies = ?, type = ?, duration = ?, cast = ?, director = ?, description = ? WHERE id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, m.getNameMovies());
            ps.setString(2, m.getType());
            ps.setInt(3, m.getDuration());
            ps.setString(4, m.getCast());
            ps.setString(5, m.getDirector());
            ps.setString(6, m.getDescriptions() != null ? m.getDescriptions() : m.getDescription());
            ps.setInt(7, m.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteMovie(int id) {
        String sql = "DELETE FROM tblMovie1 WHERE id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Movie1> searchMovies(String keyword) {
        List<Movie1> list = new ArrayList<>();
        String sql = "SELECT * FROM tblMovie1 WHERE LOWER(nameMovies) LIKE LOWER(?) OR LOWER(type) LIKE LOWER(?) ORDER BY id DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            String kw = "%" + keyword.trim() + "%";
            ps.setString(1, kw);
            ps.setString(2, kw);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Movie1 m = new Movie1();
                    m.setId(rs.getInt("id"));
                    m.setNameMovies(rs.getString("nameMovies"));
                    m.setType(rs.getString("type"));
                    m.setDuration(rs.getInt("duration"));
                    m.setCast(rs.getString("cast"));
                    m.setDirector(rs.getString("director"));
                    m.setDescriptions(rs.getString("description"));
                    list.add(m);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}

