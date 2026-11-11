package dao;

import model.Customer1;
import model.Customers1;
import model.Manager1;
import model.SalePerson1;
import model.Staff1;
import model.User1;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class User1DAO extends DAO {

    public User1DAO() {
        super();
    }

    public boolean checkLogin(User1 user) {
        if (user == null || user.getUsername() == null || user.getPassword() == null) {
            return false;
        }
        String sql = "SELECT id, fullname, email, phoneNumbers FROM tblUser1 WHERE username = ? AND password = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, user.getUsername().trim());
            ps.setString(2, user.getPassword().trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    user.setId(rs.getInt("id"));
                    user.setFullName(rs.getString("fullname"));
                    user.setEmail(rs.getString("email"));
                    user.setPhoneNumbers(rs.getString("phoneNumbers"));
                    return true;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public User1 login(String username, String password) {
        String sql = "SELECT u.*, s.viTri, c.memberCode, c.points " +
                     "FROM tblUser1 u " +
                     "LEFT JOIN tblStaff1 s ON u.id = s.tblUser1id " +
                     "LEFT JOIN tblCustomers1 c ON u.id = c.tblUser1id " +
                     "WHERE u.username = ? AND u.password = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, username.trim());
            ps.setString(2, password.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int id = rs.getInt("id");
                    String fullName = rs.getString("fullname");
                    String email = rs.getString("email");
                    String phone = rs.getString("phoneNumbers");
                    String viTri = rs.getString("viTri");
                    String memberCode = rs.getString("memberCode");
                    int points = rs.getInt("points");

                    if ("Manager".equalsIgnoreCase(viTri)) {
                        Manager1 mgr = new Manager1(id, username, password, fullName, email, phone);
                        return mgr;
                    } else if ("Salesperson".equalsIgnoreCase(viTri)) {
                        SalePerson1 sp = new SalePerson1(id, username, password, fullName, email, phone);
                        return sp;
                    } else if (memberCode != null || viTri == null) {
                        Customer1 cust = new Customer1(id, username, password, fullName, email, phone, memberCode != null ? memberCode : "TV000", points);
                        return cust;
                    } else {
                        Staff1 staff = new Staff1(id, username, password, fullName, email, phone, viTri);
                        return staff;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Customers1 getCustomerInfo(int userId) {
        String sql = "SELECT u.*, c.memberCode, c.points FROM tblUser1 u " +
                     "JOIN tblCustomers1 c ON u.id = c.tblUser1id " +
                     "WHERE u.id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Customer1 c = new Customer1();
                    c.setId(rs.getInt("id"));
                    c.setUsername(rs.getString("username"));
                    c.setFullName(rs.getString("fullname"));
                    c.setEmail(rs.getString("email"));
                    c.setPhoneNumbers(rs.getString("phoneNumbers"));
                    c.setMemberCode(rs.getString("memberCode"));
                    c.setPoints(rs.getInt("points"));
                    return c;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Staff1 getStaffInfo(int userId) {
        String sql = "SELECT u.*, s.viTri FROM tblUser1 u " +
                     "JOIN tblStaff1 s ON u.id = s.tblUser1id " +
                     "WHERE u.id = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String viTri = rs.getString("viTri");
                    if ("Manager".equalsIgnoreCase(viTri)) {
                        return new Manager1(rs.getInt("id"), rs.getString("username"), rs.getString("password"),
                                rs.getString("fullname"), rs.getString("email"), rs.getString("phoneNumbers"));
                    } else {
                        return new SalePerson1(rs.getInt("id"), rs.getString("username"), rs.getString("password"),
                                rs.getString("fullname"), rs.getString("email"), rs.getString("phoneNumbers"));
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean registerCustomer(Customers1 customer) {
        String insertUser = "INSERT INTO tblUser1 (username, password, fullname, email, phoneNumbers) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = getConnection().prepareStatement(insertUser, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, customer.getUsername());
            ps.setString(2, customer.getPassword());
            ps.setString(3, customer.getFullName());
            ps.setString(4, customer.getEmail());
            ps.setString(5, customer.getPhoneNumbers());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    int userId = rs.getInt(1);
                    customer.setId(userId);
                    String insertCust = "INSERT INTO tblCustomers1 (tblUserId, memberCode, points, tblUser1id) VALUES (?, ?, ?, ?)";
                    try (PreparedStatement psCust = getConnection().prepareStatement(insertCust)) {
                        psCust.setInt(1, userId);
                        psCust.setString(2, customer.getMemberCode() != null ? customer.getMemberCode() : "TV" + userId);
                        psCust.setInt(3, customer.getPoints());
                        psCust.setInt(4, userId);
                        return psCust.executeUpdate() > 0;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}

