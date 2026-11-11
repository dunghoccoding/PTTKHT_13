# CineMan - Hệ Thống Quản Lý Rạp Chiếu Phim
**Môn học:** Phân tích và Thiết kế Hệ thống Thông tin (PTTKHT)  
**Đề tài số 13 - B23DCCN211**

Dự án triển khai hai luồng chính theo báo cáo; chưa xác nhận khớp toàn bộ đặc tả.
- **Kiến trúc:** Mô hình MVC / JSP - Servlet - DAO - Model, Database MySQL (theo Deployment Diagram).
- **Máy chủ Web:** Tích hợp sẵn Apache Tomcat (chạy cổng `8080`).
- **Cơ sở dữ liệu:** MySQL 8.0, Database `Cine`.

---

## 1. Cấu trúc thư mục & Gói (Package Diagram)

```
PTTK_Cine/
│
├── schema.sql                       # Toàn bộ script tạo bảng và dữ liệu mẫu chuẩn theo sơ đồ CSDL
├── pom.xml                          # Cấu hình Maven, Java 21, Tomcat 10, MySQL Connector, JUnit 5
├── run.bat                          # File khởi chạy nhanh hệ thống
│
├── src/main/java/
│   ├── model/                      # Gói Model (Lớp thực thể theo Entity Class Diagram)
│   │   ├── User1.java               # Người dùng hệ thống
│   │   ├── Staff1.java              # Kế thừa User1
│   │   ├── Manager1.java            # Kế thừa Staff1 (Quản lý)
│   │   ├── SalePerson1.java         # Kế thừa Staff1 (Nhân viên bán vé)
│   │   ├── Customers1.java          # Kế thừa User1 (Khách hàng)
│   │   ├── Customer1.java           # Kế thừa Customers1
│   │   ├── Cinema1.java             # Rạp chiếu
│   │   ├── ScreenRoom1.java         # Phòng chiếu
│   │   ├── Seat1.java               # Ghế ngồi (Thường, VIP, Đôi)
│   │   ├── Movie1.java              # Phim
│   │   ├── Movies1.java             # Phim (alias)
│   │   ├── ShowTime1.java           # Lịch chiếu / Suất chiếu
│   │   ├── Ticket1.java             # Vé xem phim
│   │   ├── Bill1.java               # Hóa đơn thanh toán
│   │   ├── StatsMovies1.java        # Thống kê phim
│   │   ├── StatsCustomers.java      # Thống kê khách hàng
│   │   └── StatsRevenue.java        # Thống kê doanh thu
│   │
│   ├── dao/                        # Gói DAO (Tương tác CSDL theo Detailed Class Diagram)
│   │   ├── DAO.java                 # Lớp cơ sở kết nối JDBC MySQL
│   │   ├── Movie1DAO.java           # getMoviesList(), addMovies(), getMovieById(), deleteMovie()...
│   │   ├── ShowTime1DAO.java        # getShowDates(), getShowTime(), checkAvailable(), getShowTimeInfo()
│   │   ├── Cinema1DAO.java          # getCinemaOfShow(), getCinemaById()
│   │   ├── ScreenRoom1DAO.java      # getRoomOfShowTime(), getRoomById()
│   │   ├── User1DAO.java            # checkLogin(), login(), getCustomerInfo(), registerCustomer()
│   │   ├── Ticket1DAO.java          # getSeatMap(), checkSeat(), holdSeat(), markSold(), getTicketOfBills()
│   │   └── Bill1DAO.java            # calcTotal(), createBills(), pay(), getBillInfo(), getAllBills()
│   │
│   └── com/cineman/
│       └── Main.java                # Điểm khởi chạy nhúng Apache Tomcat Server (Port 8080)
│
├── src/main/webapp/                 # Giao diện JSP (Tuân thủ Wireframe & Kịch bản Scenario v3.0)
│   ├── index.jsp                    # Điều hướng về gdHome1.jsp
│   ├── gdHome1.jsp                  # Trang chủ khách hàng: Danh sách phim đang chiếu + Đặt vé + Tìm kiếm
│   ├── gdShowTime1.jsp              # Chọn ngày chiếu & Suất chiếu theo phim
│   ├── gdConfirmShow1.jsp           # Xác nhận thông tin suất chiếu
│   ├── gdLogin1.jsp                 # Màn hình đăng nhập
│   ├── doLogin1.jsp                 # Xử lý xác thực đăng nhập
│   ├── gdSeatSelect1.jsp            # Chọn ghế: Sơ đồ ghế 5 màu chuẩn, đếm ngược giữ ghế 05:00
│   ├── gdPayMent1.jsp               # Thanh toán nhiều ghế, tổng tiền, thời hạn giữ ghế; chưa áp dụng ưu đãi thành viên
│   ├── doPayMent.jsp                # Xử lý tạo hóa đơn, chốt vé, thanh toán
│   ├── gdTicketBill.jsp             # Hiển thị Hóa đơn & Vé xem phim, nút In vé
│   ├── gdManagerMain1.jsp           # Trang chủ Quản lý: Quản lý phim & Báo cáo
│   ├── gdMoviesManager1.jsp         # Danh sách phim hiện có, Sửa, Xóa, Thêm phim
│   ├── gdAddMovie1.jsp              # Form Thêm phim mới
│   ├── DoAddMovie.jsp               # Xử lý thêm phim, kiểm tra dữ liệu và trùng lặp
│   ├── gdEditMovie1.jsp             # Form Sửa thông tin phim
│   ├── DoEditMovie.jsp              # Xử lý cập nhật thông tin phim
│   ├── DoDeleteMovie.jsp            # Xử lý xóa phim
│   ├── gdRegister1.jsp              # Đăng kí thành viên online
│   ├── doRegister1.jsp              # Xử lý đăng kí thành viên
│   ├── gdSaleMain1.jsp              # Giao diện Bán vé tại quầy (dành cho Salesperson)
│   ├── gdIssueCard1.jsp             # Giao diện Xuất thẻ thành viên tại quầy
│   ├── gdReport1.jsp                # Báo cáo thống kê (Doanh thu, Phim, Khách hàng)
│   ├── logout.jsp                   # Đăng xuất
│   └── css/
│       └── style.css                # Bộ định dạng chuẩn theo wireframe giao diện tài liệu
│
└── src/test/java/dao/
    └── DAOTest.java                 # Bộ kiểm thử JUnit 5 (6 test cases tự động: requires test database)
```

---

## 2. Hướng dẫn khởi chạy

### Bước 1: Khởi động cơ sở dữ liệu
Cơ sở dữ liệu MySQL đã được nạp tự động qua file [schema.sql](file:///e:/MealsGo/PTTKHT/PTTK_Cine/schema.sql). Nếu cần nạp lại:
```bash
mysql -u root -proot < schema.sql
```

### Bước 2: Chạy ứng dụng
Mở terminal tại thư mục dự án và chạy:
```bash
mvn exec:java
```
hoặc nhấp đúp chuột vào file `run.bat`.

### Bước 3: Truy cập hệ thống
Mở trình duyệt web truy cập:
👉 **http://localhost:8080/**

---

## 3. Danh sách tài khoản thử nghiệm

| Vai trò (Actor) | Tên đăng nhập | Mật khẩu | Chức năng chính |
| :--- | :--- | :--- | :--- |
| **Khách hàng** (Customer) | `khachhang` | `123456` | Tìm kiếm, xem phim, mua nhiều ghế mỗi lượt; chưa áp dụng ưu đãi thẻ TV |
| **Quản lý** (Manager) | `manager` | `123456` | Quản lý phim (Thêm/Sửa/Xóa), xem báo cáo doanh thu & thống kê |
| **Nhân viên quầy** (Salesperson) | `saleperson` | `123456` | Bán vé trực tiếp tại quầy, xuất thẻ thành viên cho khách |


## Phạm vi demo và kiểm thử

- Có thể chọn/bỏ chọn nhiều ghế trong cùng suất, xem tổng tiền và mua chung một hóa đơn. Chưa nhập mã thành viên hoặc áp dụng chiết khấu.
- Thanh toán mô phỏng: lưu phương thức, không gọi nhà cung cấp hoặc thu tiền thật.
- Toàn bộ ghế được giữ cùng giao dịch trong 5 phút sau khi xác nhận. Hạn giữ theo DB và gắn với phiên trình duyệt; tải lại không gia hạn. Nếu một ghế bị chiếm, không giữ thêm ghế nào trong lượt đó.
- Nút Hủy/Chọn lại ghế giải phóng lượt giữ của phiên hiện tại. Ghế hết hạn được thu hồi khi xem sơ đồ hoặc đặt lại; thanh toán quá hạn bị từ chối.
- Tạo hóa đơn và bán toàn bộ vé trong cùng giao dịch, lỗi sẽ rollback; gửi thanh toán lặp không tạo hóa đơn mới.
- DB mới dùng `schema.sql`. DB cũ được `BookingDAO` kiểm tra và bổ sung hai cột giữ ghế khi truy cập luồng đặt vé lần đầu. Tài khoản DB cần quyền `ALTER`; thiếu quyền sẽ báo lỗi hệ thống thay vì báo nhầm ghế bị giữ. Có thể chạy `migration_seat_holds.sql` trước bằng tài khoản quản trị.
- Word chưa được chỉnh sửa; phần mã thành viên vẫn cần thống nhất với phạm vi demo.
- Kiểm thử trên dữ liệu riêng, tự dọn sau khi chạy:

```powershell
mvn test-compile org.apache.maven.plugins:maven-surefire-plugin:3.5.2:test '-Dtest=BookingDAOTest'
# Bật thêm kiểm thử HTTP qua các JSP khi server đang chạy ở localhost:8080:
mvn test-compile org.apache.maven.plugins:maven-surefire-plugin:3.5.2:test '-Dtest=BookingDAOTest' '-Dbooking.http=true'
```

Sáu kiểm thử đã qua, gồm HTTP hai vé → một hóa đơn, phiên cạnh tranh, hết hạn và thanh toán lặp. Chưa xác nhận thao tác trực quan trên trình duyệt.
