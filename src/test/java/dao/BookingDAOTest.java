package dao;

import org.junit.jupiter.api.*;
import java.sql.*;
import java.util.*;
import java.util.concurrent.*;
import static org.junit.jupiter.api.Assertions.*;
import java.net.*;
import java.net.http.*;
import java.nio.charset.StandardCharsets;

/** Creates its own showtime and deletes only its fixtures. Requires a local test DB. */
public class BookingDAOTest {
    private BookingDAO booking;
    private int show;
    private List<Integer> ids;
    private final List<Integer> bills = new ArrayList<>();

    @BeforeEach void setup() throws Exception {
        booking = new BookingDAO();
        try (Connection c = DAO.openConnection(); Statement st = c.createStatement()) {
            st.executeUpdate("INSERT INTO tblShowTime1 (tblMovieid,dateShow,hoursShow,priceTicket,tblScreenRoom1id) SELECT tblMovieid,dateShow,hoursShow,priceTicket,tblScreenRoom1id FROM tblShowTime1 ORDER BY id LIMIT 1", Statement.RETURN_GENERATED_KEYS);
            try (ResultSet rs = st.getGeneratedKeys()) { assertTrue(rs.next()); show = rs.getInt(1); }
            st.executeUpdate("INSERT INTO tblTicket1 (priceTicket,status,tblShowTime1id,tblSeat1id) SELECT 45000,'Trống'," + show + ",s.id FROM tblSeat1 s JOIN tblShowTime1 t ON t.tblScreenRoom1id=s.tblScreenRoom1id WHERE t.id=" + show + " ORDER BY s.id LIMIT 3");
            ids = new ArrayList<>();
            try (ResultSet rs = st.executeQuery("SELECT id FROM tblTicket1 WHERE tblShowTime1id=" + show + " ORDER BY id")) { while (rs.next()) ids.add(rs.getInt(1)); }
            assertEquals(3, ids.size());
        }
    }

    @AfterEach void cleanup() throws Exception {
        try (Connection c = DAO.openConnection(); Statement st = c.createStatement()) {
            // Include bills committed by HTTP checks as well.
            try (ResultSet rs = st.executeQuery("SELECT DISTINCT tblBill1id FROM tblTicket1 WHERE tblShowTime1id=" + show + " AND tblBill1id IS NOT NULL")) {
                while (rs.next()) bills.add(rs.getInt(1));
            }
            st.executeUpdate("DELETE FROM tblShowTime1 WHERE id=" + show);
            for (int id : bills) st.executeUpdate("DELETE FROM tblBill1 WHERE id=" + id);
        }
    }

    @Test void twoSeatsOneBillAndNoDuplicatePayment() throws Exception {
        List<Integer> pair = ids.subList(0, 2);
        long deadline = booking.hold(pair, show, "owner");
        assertTrue(deadline > System.currentTimeMillis());
        assertEquals(deadline, booking.hold(pair, show, "owner"));
        assertEquals(0, booking.checkout(pair, show, 3, "stranger", "Ví VNPay"));
        int bill = booking.checkout(pair, show, 3, "owner", "Ví VNPay");
        assertTrue(bill > 0); bills.add(bill);
        assertEquals(0, booking.checkout(pair, show, 3, "owner", "Ví VNPay"));
        try (Connection c = DAO.openConnection(); Statement st = c.createStatement(); ResultSet rs = st.executeQuery("SELECT b.totalAmount,COUNT(t.id) FROM tblBill1 b JOIN tblTicket1 t ON t.tblBill1id=b.id WHERE b.id=" + bill + " GROUP BY b.id")) {
            assertTrue(rs.next()); assertEquals(90000f, rs.getFloat(1)); assertEquals(2, rs.getInt(2));
        }
    }

    @Test void conflictDoesNotPartiallyHoldBasket() throws Exception {
        assertTrue(booking.hold(Collections.singletonList(ids.get(1)), show, "other") > 0);
        assertEquals(0, booking.hold(ids.subList(0, 2), show, "owner"));
        assertTrue(booking.hold(Collections.singletonList(ids.get(0)), show, "third") > 0);
    }

    @Test void expiryRejectsEntirePaymentAndAllowsReclaim() throws Exception {
        List<Integer> pair = ids.subList(0, 2);
        booking.hold(pair, show, "owner");
        try (Connection c = DAO.openConnection(); Statement st = c.createStatement()) {
            st.executeUpdate("UPDATE tblTicket1 SET holdExpiresAt=DATE_SUB(NOW(),INTERVAL 1 SECOND) WHERE id=" + ids.get(1));
        }
        assertEquals(0, booking.checkout(pair, show, 3, "owner", "Ví VNPay"));
        assertTrue(booking.hold(Collections.singletonList(ids.get(1)), show, "other") > 0);
        booking.release(show, "owner");
        assertTrue(booking.hold(Collections.singletonList(ids.get(0)), show, "third") > 0);
        assertEquals(0, booking.hold(Collections.singletonList(ids.get(1)), show, "third"));
    }

    @Test void concurrentSessionsCannotBothHoldSamePair() throws Exception {
        ExecutorService pool = Executors.newFixedThreadPool(2);
        try {
            CountDownLatch start = new CountDownLatch(1);
            Future<Long> a = pool.submit(() -> { start.await(); return booking.hold(ids.subList(0, 2), show, "a"); });
            Future<Long> b = pool.submit(() -> { start.await(); return booking.hold(ids.subList(0, 2), show, "b"); });
            start.countDown();
            assertEquals(1, (a.get() > 0 ? 1 : 0) + (b.get() > 0 ? 1 : 0));
        } finally { pool.shutdownNow(); }
    }

    @Test void invalidIdsAreRejected() {
        for (String raw : Arrays.asList("", "1,1", "-1", "1,", "abc"))
            assertThrows(IllegalArgumentException.class, () -> BookingDAO.parseIds(raw));
    }

    @Test
    @org.junit.jupiter.api.condition.EnabledIfSystemProperty(named="booking.http", matches="true")
    void httpTwoSeatsThroughPaymentAndReceipt() throws Exception {
        String base = "http://localhost:8080/";
        HttpClient client = HttpClient.newBuilder().cookieHandler(new CookieManager(null, CookiePolicy.ACCEPT_ALL)).build();
        HttpClient stranger = HttpClient.newBuilder().cookieHandler(new CookieManager(null, CookiePolicy.ACCEPT_ALL)).build();
        for (HttpClient browser : Arrays.asList(client, stranger)) {
            HttpResponse<String> login = browser.send(HttpRequest.newBuilder(URI.create(base + "doLogin1.jsp"))
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString("txtUserName=khachhang&txtPassword=123456")).build(), HttpResponse.BodyHandlers.ofString());
            assertEquals(302, login.statusCode(), login.body());
        }
        String query = "showTimeId=" + show + "&ticketIds=" + BookingDAO.joinIds(ids.subList(0, 2));
        HttpResponse<String> seats = client.send(HttpRequest.newBuilder(URI.create(base + "gdSeatSelect1.jsp?showTimeId=" + show)).build(), HttpResponse.BodyHandlers.ofString());
        assertEquals(200, seats.statusCode(), seats.body());
        assertTrue(seats.body().contains("selectedSeats = new Map()"));
        HttpResponse<String> payment = client.send(HttpRequest.newBuilder(URI.create(base + "gdPayMent1.jsp?" + query)).build(), HttpResponse.BodyHandlers.ofString());
        assertEquals(200, payment.statusCode(), payment.body());
        assertTrue(payment.body().contains("2 vé"), payment.body());
        assertTrue(payment.body().contains("A1, A2"), payment.body());
        HttpResponse<String> reload = client.send(HttpRequest.newBuilder(URI.create(base + "gdPayMent1.jsp?" + query)).build(), HttpResponse.BodyHandlers.ofString());
        assertEquals(200, reload.statusCode(), reload.body());
        HttpResponse<String> conflict = stranger.send(HttpRequest.newBuilder(URI.create(base + "gdPayMent1.jsp?" + query)).build(), HttpResponse.BodyHandlers.ofString());
        assertEquals(302, conflict.statusCode());
        assertTrue(conflict.headers().firstValue("location").orElse("").contains("error=occupied"));
        String form = query + "&selPaymentMethod=" + URLEncoder.encode("Ví VNPay", StandardCharsets.UTF_8);
        HttpRequest payRequest = HttpRequest.newBuilder(URI.create(base + "doPayMent.jsp"))
            .header("Content-Type", "application/x-www-form-urlencoded").POST(HttpRequest.BodyPublishers.ofString(form)).build();
        HttpResponse<String> failed = client.send(HttpRequest.newBuilder(URI.create(base + "doPayMent.jsp"))
            .header("Content-Type", "application/x-www-form-urlencoded")
            .POST(HttpRequest.BodyPublishers.ofString(form + "&simulationResult=failure")).build(), HttpResponse.BodyHandlers.ofString());
        String retryUrl = failed.headers().firstValue("location").orElseThrow();
        assertTrue(retryUrl.contains("error=payment_failed"), retryUrl);
        HttpResponse<String> retry = client.send(HttpRequest.newBuilder(URI.create(base).resolve(retryUrl)).build(), HttpResponse.BodyHandlers.ofString());
        assertEquals(200, retry.statusCode(), retry.body());
        assertTrue(retry.body().contains("Thanh toán lại"), retry.body());
        try (Connection c = DAO.openConnection(); Statement st = c.createStatement(); ResultSet rs = st.executeQuery(
                "SELECT COUNT(*) FROM tblTicket1 WHERE tblShowTime1id=" + show + " AND status='Đang giữ' AND tblBill1id IS NULL")) {
            assertTrue(rs.next()); assertEquals(2, rs.getInt(1));
        }
        HttpResponse<String> paid = client.send(payRequest, HttpResponse.BodyHandlers.ofString());
        assertEquals(302, paid.statusCode(), paid.body());
        String location = paid.headers().firstValue("location").orElseThrow();
        assertTrue(location.contains("gdTicketBill.jsp?billId="), location);
        HttpResponse<String> receipt = client.send(HttpRequest.newBuilder(URI.create(base).resolve(location)).build(), HttpResponse.BodyHandlers.ofString());
        assertEquals(200, receipt.statusCode(), receipt.body());
        assertTrue(receipt.body().contains("A1, A2"), receipt.body());
        assertTrue(receipt.body().contains("2 vé"), receipt.body());
        HttpResponse<String> repeat = client.send(payRequest, HttpResponse.BodyHandlers.ofString());
        assertTrue(repeat.headers().firstValue("location").orElse("").contains("error=expired"));
        int bill = Integer.parseInt(location.substring(location.indexOf("billId=") + 7));
        try (Connection c = DAO.openConnection(); Statement st = c.createStatement(); ResultSet rs = st.executeQuery("SELECT b.totalAmount,COUNT(t.id) FROM tblBill1 b JOIN tblTicket1 t ON t.tblBill1id=b.id WHERE b.id=" + bill + " GROUP BY b.id")) {
            assertTrue(rs.next()); assertEquals(90000f, rs.getFloat(1)); assertEquals(2, rs.getInt(2));
        }
    }

    @Test
    @org.junit.jupiter.api.condition.EnabledIfSystemProperty(named="booking.http", matches="true")
    void httpAuthorizationAndMovieValidation() throws Exception {
        HttpClient browser = HttpClient.newBuilder().cookieHandler(new CookieManager(null, CookiePolicy.ACCEPT_ALL)).build();
        String base = "http://localhost:8080/";
        HttpResponse<String> blocked = browser.send(HttpRequest.newBuilder(URI.create(base + "gdSeatSelect1.jsp?showTimeId=" + show)).build(), HttpResponse.BodyHandlers.ofString());
        assertEquals(302, blocked.statusCode());
        assertTrue(blocked.headers().firstValue("location").orElse("").contains("gdLogin1.jsp"));
        browser.send(HttpRequest.newBuilder(URI.create(base + "doLogin1.jsp"))
            .header("Content-Type", "application/x-www-form-urlencoded")
            .POST(HttpRequest.BodyPublishers.ofString("txtUserName=khachhang&txtPassword=123456")).build(), HttpResponse.BodyHandlers.ofString());
        assertEquals(403, browser.send(HttpRequest.newBuilder(URI.create(base + "gdAddMovie1.jsp")).build(), HttpResponse.BodyHandlers.ofString()).statusCode());
        browser.send(HttpRequest.newBuilder(URI.create(base + "doLogin1.jsp"))
            .header("Content-Type", "application/x-www-form-urlencoded")
            .POST(HttpRequest.BodyPublishers.ofString("txtUserName=manager&txtPassword=123456")).build(), HttpResponse.BodyHandlers.ofString());
        String title = "Preserve <movie>";
        HttpResponse<String> invalid = browser.send(HttpRequest.newBuilder(URI.create(base + "DoAddMovie.jsp"))
            .header("Content-Type", "application/x-www-form-urlencoded")
            .POST(HttpRequest.BodyPublishers.ofString("txnameMovie=" + URLEncoder.encode(title, StandardCharsets.UTF_8) + "&selType=Drama&txtDuration=0")).build(), HttpResponse.BodyHandlers.ofString());
        assertEquals(200, invalid.statusCode(), invalid.body());
        assertTrue(invalid.body().contains("Preserve &lt;movie&gt;"), invalid.body());
        assertTrue(invalid.body().contains("invalid-field"));
        assertTrue(invalid.body().contains("Thời lượng phải là số nguyên lớn hơn 0."));
    }

    @Test void retryAndExpiryDoNotRenewOrSellSeats() throws Exception {
        long deadline = booking.hold(ids, show, "owner");
        assertEquals(deadline, booking.getHoldDeadline(ids, show, "owner"));
        assertEquals(0, booking.getHoldDeadline(ids, show, "stranger"));
        try (Connection c = DAO.openConnection(); Statement st = c.createStatement()) {
            st.executeUpdate("UPDATE tblTicket1 SET holdExpiresAt=DATE_SUB(NOW(), INTERVAL 1 SECOND) WHERE tblShowTime1id=" + show);
        }
        assertEquals(0, booking.getHoldDeadline(ids, show, "owner"));
        booking.releaseExpired();
        assertTrue(booking.hold(ids, show, "other") > 0);
    }
}
