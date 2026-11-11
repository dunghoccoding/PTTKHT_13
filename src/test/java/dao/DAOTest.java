package dao;

import model.Bill1;
import model.Customer1;
import model.Movie1;
import model.ShowTime1;
import model.Ticket1;
import model.User1;
import org.junit.jupiter.api.*;

import java.sql.Date;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class DAOTest {

    private static Movie1DAO movieDAO;
    private static ShowTime1DAO showTimeDAO;
    private static User1DAO userDAO;
    private static Ticket1DAO ticketDAO;
    private static Bill1DAO billDAO;

    @BeforeAll
    public static void setUp() {
        movieDAO = new Movie1DAO();
        showTimeDAO = new ShowTime1DAO();
        userDAO = new User1DAO();
        ticketDAO = new Ticket1DAO();
        billDAO = new Bill1DAO();
    }

    @Test
    @Order(1)
    public void testDatabaseConnection() {
        assertNotNull(movieDAO.getConnection(), "Database connection must not be null");
    }

    @Test
    @Order(2)
    public void testGetMoviesList() {
        List<Movie1> list = movieDAO.getMoviesList();
        assertNotNull(list);
        assertFalse(list.isEmpty(), "Movies list should not be empty");
    }

    @Test
    @Order(3)
    public void testAddMovieAndDuplicateCheck() {
        String testTitle = "Phim Test " + System.currentTimeMillis();
        Movie1 m = new Movie1();
        m.setNameMovies(testTitle);
        m.setType("Hành động");
        m.setDuration(110);
        m.setDirector("Đạo diễn Test");
        m.setCast("Diễn viên Test");
        m.setDescriptions("Mô tả test");

        boolean added = movieDAO.addMovies(m);
        assertTrue(added, "Movie should be added successfully");
        assertTrue(m.getId() > 0, "Generated ID should be greater than 0");

        // Duplicate test (Exception 5a)
        boolean duplicateAdded = movieDAO.addMovies(m);
        assertFalse(duplicateAdded, "Duplicate movie title should be rejected");

        // Cleanup
        movieDAO.deleteMovie(m.getId());
    }

    @Test
    @Order(4)
    public void testUserLogin() {
        User1 user = userDAO.login("khachhang", "123456");
        assertNotNull(user, "User login should succeed for khachhang / 123456");
        assertTrue(user instanceof Customer1 || user instanceof model.Customers1);

        User1 wrongUser = userDAO.login("khachhang", "wrong_password");
        assertNull(wrongUser, "Wrong password should return null");
    }

    @Test
    @Order(5)
    public void testShowTimeAndSeats() {
        List<Movie1> movies = movieDAO.getMoviesList();
        assertTrue(movies.size() > 0);
        int movieId = movies.get(0).getId();

        List<Date> dates = showTimeDAO.getShowDates(movieId);
        assertNotNull(dates);

        if (!dates.isEmpty()) {
            List<ShowTime1> showTimes = showTimeDAO.getShowTime(movieId, dates.get(0));
            assertNotNull(showTimes);
            if (!showTimes.isEmpty()) {
                int stId = showTimes.get(0).getId();
                List<Ticket1> seats = ticketDAO.getSeatMap(stId);
                assertNotNull(seats);
                assertFalse(seats.isEmpty(), "Seat map should have tickets");
            }
        }
    }

    @Test
    @Order(6)
    public void testBillCreationAndCalculation() {
        Ticket1 t = new Ticket1();
        t.setId(1);
        t.setPriceTicket(45000f);

        float total = billDAO.calcTotal(Collections.singletonList(t));
        assertEquals(45000f, total, 0.01f);

        Customer1 cust = (Customer1) userDAO.login("khachhang", "123456");
        Bill1 bill = billDAO.createBills(cust, Collections.singletonList(t));
        assertNotNull(bill);
        assertTrue(bill.getId() > 0);

        boolean paid = billDAO.pay(bill, "Ví VNPay");
        assertTrue(paid);
    }
}

