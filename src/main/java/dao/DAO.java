package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DAO {
    public static Connection con;

    public DAO() {
        if (con == null) {
            String dbUrl = System.getProperty("db.url", System.getenv().getOrDefault("DB_URL", "jdbc:mysql://localhost:3306/Cine?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Bangkok&useUnicode=true&characterEncoding=UTF-8"));
            String dbUser = System.getProperty("db.user", System.getenv().getOrDefault("DB_USER", "root"));
            String dbPassword = System.getProperty("db.password", System.getenv().getOrDefault("DB_PASSWORD", "root"));
            String dbClass = "com.mysql.cj.jdbc.Driver";

            try {
                Class.forName(dbClass);
                con = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
            } catch (ClassNotFoundException e) {
                System.err.println("MySQL Driver not found: " + e.getMessage());
            } catch (SQLException e) {
                System.err.println("Database connection failed: " + e.getMessage());
            }
        }
    }

    // Checkout uses a dedicated connection so rollback cannot affect other requests.
    public static Connection openConnection() throws SQLException {
        return DriverManager.getConnection(
            System.getProperty("db.url", System.getenv().getOrDefault("DB_URL", "jdbc:mysql://localhost:3306/Cine?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Bangkok&useUnicode=true&characterEncoding=UTF-8")),
            System.getProperty("db.user", System.getenv().getOrDefault("DB_USER", "root")),
            System.getProperty("db.password", System.getenv().getOrDefault("DB_PASSWORD", "root")));
    }

    public Connection getConnection() {
        try {
            if (con == null || con.isClosed()) {
                con = null;
                new DAO();
            }
        } catch (SQLException e) {
            con = null;
            new DAO();
        }
        return con;
    }
}

