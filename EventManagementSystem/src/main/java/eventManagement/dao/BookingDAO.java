
package eventManagement.dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.UUID;
import java.util.*;

import eventManagement.model.Booking;
import eventManagement.model.MyBooking;
import eventManagement.util.DBConnection;
import eventManagement.model.AdminBooking;

public class BookingDAO {

    public Booking createPendingBooking(
            int userId, int eventId, int quantity)
            throws SQLException {

        if (quantity < 1 || quantity > 10) {
            throw new IllegalArgumentException(
                    "Choose between 1 and 10 tickets.");
        }

        try (Connection con = DBConnection.getConnection()) {

            con.setAutoCommit(false);

            try {
                String eventSql =
                    "SELECT ticket_price, total_seats, event_date, " +
                    "registration_deadline, status " +
                    "FROM events WHERE event_id = ? FOR UPDATE";

                BigDecimal price;
                int totalSeats;

                try (PreparedStatement ps =
                        con.prepareStatement(eventSql)) {

                    ps.setInt(1, eventId);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            throw new IllegalArgumentException(
                                    "Event not found.");
                        }

                        if (!"PUBLISHED".equals(
                                rs.getString("status"))) {
                            throw new IllegalArgumentException(
                                    "This event is not available.");
                        }

                        LocalDateTime eventDate =
                            rs.getDate("event_date").toLocalDate()
                                .atStartOfDay();

                        Timestamp deadline =
                            rs.getTimestamp("registration_deadline");

                        if (!eventDate.isAfter(
                                LocalDateTime.now().minusDays(1))) {
                            throw new IllegalArgumentException(
                                    "This event has already started.");
                        }

                        if (deadline == null ||
                                !deadline.toLocalDateTime()
                                    .isAfter(LocalDateTime.now())) {
                            throw new IllegalArgumentException(
                                    "Registration is closed.");
                        }

                        price = rs.getBigDecimal("ticket_price");
                        totalSeats = rs.getInt("total_seats");
                    }
                }

                // Expire previous pending bookings whose hold time ended.
                String expireSql =
                    "UPDATE bookings SET booking_status = 'EXPIRED' " +
                    "WHERE event_id = ? " +
                    "AND booking_status = 'PENDING_PAYMENT' " +
                    "AND reservation_expires_at <= NOW()";

                try (PreparedStatement ps =
                        con.prepareStatement(expireSql)) {
                    ps.setInt(1, eventId);
                    ps.executeUpdate();
                }

                // Count confirmed bookings and active pending holds.
                String seatsSql =
                    "SELECT COALESCE(SUM(ticket_quantity), 0) " +
                    "FROM bookings WHERE event_id = ? " +
                    "AND (booking_status = 'CONFIRMED' " +
                    "OR (booking_status = 'PENDING_PAYMENT' " +
                    "AND reservation_expires_at > NOW()))";

                int bookedSeats;

                try (PreparedStatement ps =
                        con.prepareStatement(seatsSql)) {
                    ps.setInt(1, eventId);

                    try (ResultSet rs = ps.executeQuery()) {
                        rs.next();
                        bookedSeats = rs.getInt(1);
                    }
                }

                int availableSeats = totalSeats - bookedSeats;

                if (availableSeats < quantity) {
                    throw new IllegalArgumentException(
                            "Not enough seats available. Remaining seats: "
                                    + Math.max(availableSeats, 0));
                }

                BigDecimal totalAmount =
                        price.multiply(BigDecimal.valueOf(quantity));

                String reference =
                        "EVT-" + UUID.randomUUID()
                                  .toString()
                                  .replace("-", "")
                                  .substring(0, 12)
                                  .toUpperCase();

                String insertSql =
                    "INSERT INTO bookings " +
                    "(booking_reference, user_id, event_id, " +
                    "ticket_quantity, unit_price, total_amount, " +
                    "booking_status, reservation_expires_at) " +
                    "VALUES (?, ?, ?, ?, ?, ?, 'PENDING_PAYMENT', ?)";

                long bookingId;

                try (PreparedStatement ps = con.prepareStatement(
                        insertSql, Statement.RETURN_GENERATED_KEYS)) {

                    ps.setString(1, reference);
                    ps.setInt(2, userId);
                    ps.setInt(3, eventId);
                    ps.setInt(4, quantity);
                    ps.setBigDecimal(5, price);
                    ps.setBigDecimal(6, totalAmount);
                    ps.setTimestamp(7, Timestamp.valueOf(
                            LocalDateTime.now().plusMinutes(10)));

                    ps.executeUpdate();

                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (!keys.next()) {
                            throw new SQLException(
                                    "Could not create booking.");
                        }
                        bookingId = keys.getLong(1);
                    }
                }

                // Create a pending payment record.
                String paymentSql =
                    "INSERT INTO payments " +
                    "(booking_id, amount, payment_method, payment_status) " +
                    "VALUES (?, ?, 'SIMULATED', 'PENDING')";

                try (PreparedStatement ps =
                        con.prepareStatement(paymentSql)) {
                    ps.setLong(1, bookingId);
                    ps.setBigDecimal(2, totalAmount);
                    ps.executeUpdate();
                }

                con.commit();

                Booking booking = new Booking();
                booking.setBookingId(bookingId);
                booking.setBookingReference(reference);
                booking.setUserId(userId);
                booking.setEventId(eventId);
                booking.setTicketQuantity(quantity);
                booking.setUnitPrice(price);
                booking.setTotalAmount(totalAmount);
                booking.setBookingStatus("PENDING_PAYMENT");

                return booking;

            } catch (SQLException | RuntimeException ex) {
                con.rollback();
                throw ex;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }
    
    public List<MyBooking> findBookingsByUserId(int userId)
            throws SQLException {

        List<MyBooking> bookings = new ArrayList<>();

        String sql =
            "SELECT b.booking_reference, e.title, e.event_date, " +
            "e.start_time, b.ticket_quantity, b.total_amount, " +
            "b.booking_status, " +
            "(SELECT p.payment_status FROM payments p " +
            " WHERE p.booking_id = b.booking_id " +
            " ORDER BY p.payment_id DESC LIMIT 1) AS payment_status, " +
            "b.booked_at " +
            "FROM bookings b " +
            "JOIN events e ON b.event_id = e.event_id " +
            "WHERE b.user_id = ? " +
            "ORDER BY b.booked_at DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MyBooking booking = new MyBooking();

                    booking.setBookingReference(
                        rs.getString("booking_reference"));
                    booking.setEventTitle(rs.getString("title"));
                    booking.setEventDate(
                        rs.getString("event_date"));
                    booking.setStartTime(
                        rs.getString("start_time"));
                    booking.setTicketQuantity(
                        rs.getInt("ticket_quantity"));
                    booking.setTotalAmount(
                        rs.getBigDecimal("total_amount"));
                    booking.setBookingStatus(
                        rs.getString("booking_status"));
                    booking.setPaymentStatus(
                        rs.getString("payment_status"));
                    booking.setBookedAt(
                        rs.getString("booked_at"));

                    bookings.add(booking);
                }
            }
        }

        return bookings;
    }



public boolean cancelBooking(int userId, String bookingReference)
        throws SQLException {

    String findEventSql =
            "SELECT event_id FROM bookings " +
            "WHERE booking_reference = ? AND user_id = ?";

    String lockEventSql =
            "SELECT event_id, " +
            "CASE WHEN TIMESTAMP(event_date, start_time) > NOW() " +
            "THEN 1 ELSE 0 END AS event_not_started " +
            "FROM events WHERE event_id = ? FOR UPDATE";

    String lockBookingSql =
            "SELECT booking_id, event_id, booking_status, " +
            "CASE WHEN reservation_expires_at > NOW() " +
            "THEN 1 ELSE 0 END AS reservation_active " +
            "FROM bookings " +
            "WHERE booking_reference = ? AND user_id = ? FOR UPDATE";

    String usedTicketSql =
            "SELECT COUNT(*) FROM tickets " +
            "WHERE booking_id = ? AND ticket_status = 'USED'";

    String updateBookingSql =
            "UPDATE bookings SET booking_status = 'CANCELLED', " +
            "cancelled_at = NOW(), reservation_expires_at = NOW() " +
            "WHERE booking_id = ?";

    String updateTicketsSql =
            "UPDATE tickets SET ticket_status = 'CANCELLED' " +
            "WHERE booking_id = ? AND ticket_status = 'VALID'";

    String updatePaymentSql =
            "UPDATE payments SET payment_status = " +
            "CASE " +
            "WHEN payment_status = 'SUCCESS' THEN 'REFUNDED' " +
            "WHEN payment_status = 'PENDING' THEN 'FAILED' " +
            "ELSE payment_status END " +
            "WHERE booking_id = ? " +
            "AND payment_status IN ('SUCCESS', 'PENDING')";

    try (Connection con = DBConnection.getConnection()) {

        con.setAutoCommit(false);

        try {

            long eventId;

            // Step 1: Find the event associated with this booking.
            try (PreparedStatement ps =
                    con.prepareStatement(findEventSql)) {

                ps.setString(1, bookingReference);
                ps.setInt(2, userId);

                try (ResultSet rs = ps.executeQuery()) {

                    if (!rs.next()) {
                        con.rollback();
                        return false;
                    }

                    eventId = rs.getLong("event_id");
                }
            }

            // Step 2: Lock the event row first.
            boolean eventNotStarted;

            try (PreparedStatement ps =
                    con.prepareStatement(lockEventSql)) {

                ps.setLong(1, eventId);

                try (ResultSet rs = ps.executeQuery()) {

                    if (!rs.next()) {
                        con.rollback();
                        return false;
                    }

                    eventNotStarted =
                            rs.getInt("event_not_started") == 1;
                }
            }

            // Step 3: Lock the booking row.
            long bookingId;
            long bookingEventId;
            String bookingStatus;
            boolean reservationActive;

            try (PreparedStatement ps =
                    con.prepareStatement(lockBookingSql)) {

                ps.setString(1, bookingReference);
                ps.setInt(2, userId);

                try (ResultSet rs = ps.executeQuery()) {

                    if (!rs.next()) {
                        con.rollback();
                        return false;
                    }

                    bookingId = rs.getLong("booking_id");
                    bookingEventId = rs.getLong("event_id");
                    bookingStatus = rs.getString("booking_status");

                    reservationActive =
                            rs.getInt("reservation_active") == 1;
                }
            }

            // Step 4: Verify the booking still belongs to this event.
            if (bookingEventId != eventId) {
                con.rollback();
                return false;
            }

            // Step 5: Check cancellation eligibility.
            if ("PENDING_PAYMENT".equals(bookingStatus)) {

                if (!reservationActive) {
                    con.rollback();
                    return false;
                }

            } else if ("CONFIRMED".equals(bookingStatus)) {

                if (!eventNotStarted) {
                    con.rollback();
                    return false;
                }

            } else {

                // CANCELLED and EXPIRED bookings cannot be cancelled.
                con.rollback();
                return false;
            }

            // Step 6: Check whether any ticket is already USED.
            try (PreparedStatement ps =
                    con.prepareStatement(usedTicketSql)) {

                ps.setLong(1, bookingId);

                try (ResultSet rs = ps.executeQuery()) {

                    if (rs.next() && rs.getInt(1) > 0) {
                        con.rollback();
                        return false;
                    }
                }
            }

            // Step 7: Cancel the booking.
            try (PreparedStatement ps =
                    con.prepareStatement(updateBookingSql)) {

                ps.setLong(1, bookingId);
                ps.executeUpdate();
            }

            // Step 8: Cancel all VALID tickets.
            try (PreparedStatement ps =
                    con.prepareStatement(updateTicketsSql)) {

                ps.setLong(1, bookingId);
                ps.executeUpdate();
            }

            // Step 9: Refund successful payments or fail pending payments.
            try (PreparedStatement ps =
                    con.prepareStatement(updatePaymentSql)) {

                ps.setLong(1, bookingId);
                ps.executeUpdate();
            }

            // Step 10: Save all changes together.
            con.commit();

            return true;

        } catch (SQLException e) {

            con.rollback();
            throw e;

        } finally {

            con.setAutoCommit(true);
        }
    }
    
    
}

public List<AdminBooking> findAllBookings() throws SQLException {

    List<AdminBooking> bookings = new ArrayList<>();

    String sql =
        "SELECT b.booking_reference, " +
        "u.full_name, u.email, " +
        "e.title, " +
        "b.ticket_quantity, b.total_amount, " +
        "b.booking_status, " +
        "(SELECT p.payment_status FROM payments p " +
        " WHERE p.booking_id = b.booking_id " +
        " ORDER BY p.payment_id DESC LIMIT 1) AS payment_status, " +
        "b.booked_at " +
        "FROM bookings b " +
        "JOIN users u ON b.user_id = u.user_id " +
        "JOIN events e ON b.event_id = e.event_id " +
        "ORDER BY b.booked_at DESC";

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {

            AdminBooking booking = new AdminBooking();

            booking.setBookingReference(
                rs.getString("booking_reference"));

            booking.setFullName(
                rs.getString("full_name"));

            booking.setEmail(
                rs.getString("email"));

            booking.setEventTitle(
                rs.getString("title"));

            booking.setTicketQuantity(
                rs.getInt("ticket_quantity"));

            booking.setTotalAmount(
                rs.getBigDecimal("total_amount"));

            booking.setBookingStatus(
                rs.getString("booking_status"));

            booking.setPaymentStatus(
                rs.getString("payment_status"));

            booking.setBookedAt(
                rs.getString("booked_at"));

            bookings.add(booking);
        }
    }

    return bookings;
}


public List<AdminBooking> findBookingsByEventId(int eventId)
        throws SQLException {

    List<AdminBooking> bookings = new ArrayList<>();

    String sql =
        "SELECT b.booking_reference, " +
        "u.full_name, u.email, e.title AS event_title, " +
        "b.ticket_quantity, b.total_amount, " +
        "b.booking_status, " +
        "(SELECT p.payment_status " +
        " FROM payments p " +
        " WHERE p.booking_id = b.booking_id " +
        " ORDER BY p.created_at DESC, p.payment_id DESC " +
        " LIMIT 1) AS payment_status, " +
        "b.booked_at " +
        "FROM bookings b " +
        "JOIN users u ON b.user_id = u.user_id " +
        "JOIN events e ON b.event_id = e.event_id " +
        "WHERE b.event_id = ? " +
        "ORDER BY b.booked_at DESC";

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        ps.setInt(1, eventId);

        try (ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                AdminBooking booking = new AdminBooking();

                booking.setBookingReference(
                    rs.getString("booking_reference"));

                booking.setFullName(
                    rs.getString("full_name"));

                booking.setEmail(
                    rs.getString("email"));

                booking.setEventTitle(
                    rs.getString("event_title"));

                booking.setTicketQuantity(
                    rs.getInt("ticket_quantity"));

                booking.setTotalAmount(
                    rs.getBigDecimal("total_amount"));

                booking.setBookingStatus(
                    rs.getString("booking_status"));

                booking.setPaymentStatus(
                    rs.getString("payment_status"));

                booking.setBookedAt(
                    rs.getString("booked_at"));

                bookings.add(booking);
            }
        }
    }

    return bookings;
}

}
