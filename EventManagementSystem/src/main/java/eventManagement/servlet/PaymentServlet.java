
package eventManagement.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.UUID;

import eventManagement.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/process-payment")
public class PaymentServlet extends HttpServlet {

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null
                || !"USER".equals(session.getAttribute("role"))
                || !(session.getAttribute("userId") instanceof Number)) {

            response.sendRedirect(
                    request.getContextPath() + "/login.jsp");
            return;
        }

        int userId = ((Number)
                session.getAttribute("userId")).intValue();

        String outcome = request.getParameter("paymentOutcome");

        if (!"SUCCESS".equals(outcome)
                && !"FAILED".equals(outcome)) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid payment result.");
            return;
        }

        long bookingId;

        try {
            bookingId = Long.parseLong(
                    request.getParameter("bookingId"));

            if (bookingId <= 0) {
                throw new NumberFormatException();
            }

        } catch (NumberFormatException ex) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid booking ID.");
            return;
        }

        String result = "ERROR";
        String message;

        try (Connection con = DBConnection.getConnection()) {

            con.setAutoCommit(false);

            try {
                String bookingSql =
                    "SELECT booking_reference, booking_status, " +
                    "reservation_expires_at, " +
                    "(reservation_expires_at > NOW()) AS hold_active " +
                    "FROM bookings " +
                    "WHERE booking_id = ? AND user_id = ? FOR UPDATE";

                String bookingReference;
                String bookingStatus;
                Timestamp expiry;
                boolean holdActive;

                try (PreparedStatement ps =
                        con.prepareStatement(bookingSql)) {

                    ps.setLong(1, bookingId);
                    ps.setInt(2, userId);

                    try (ResultSet rs = ps.executeQuery()) {

                        if (!rs.next()) {
                            throw new PaymentException(
                                    "Booking not found.");
                        }

                        bookingReference =
                                rs.getString("booking_reference");

                        bookingStatus =
                                rs.getString("booking_status");

                        expiry =
                                rs.getTimestamp(
                                        "reservation_expires_at");

                        holdActive =
                                rs.getBoolean("hold_active");
                    }
                }

                if (!"PENDING_PAYMENT".equals(bookingStatus)) {
                    throw new PaymentException(
                            "This booking has already been processed.");
                }

                // Lock and verify the pending payment record.
                long paymentId;

                String paymentSql =
                    "SELECT payment_id FROM payments " +
                    "WHERE booking_id = ? AND payment_status = 'PENDING' " +
                    "ORDER BY payment_id DESC LIMIT 1 FOR UPDATE";

                try (PreparedStatement ps =
                        con.prepareStatement(paymentSql)) {

                    ps.setLong(1, bookingId);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            throw new PaymentException(
                                    "No pending payment was found.");
                        }

                        paymentId = rs.getLong("payment_id");
                    }
                }

                if (!holdActive || expiry == null) {

                    try (PreparedStatement ps = con.prepareStatement(
                            "UPDATE bookings SET booking_status = 'EXPIRED' " +
                            "WHERE booking_id = ?")) {
                        ps.setLong(1, bookingId);
                        ps.executeUpdate();
                    }

                    try (PreparedStatement ps = con.prepareStatement(
                            "UPDATE payments SET payment_status = 'FAILED' " +
                            "WHERE payment_id = ? " +
                            "AND payment_status = 'PENDING'")) {
                        ps.setLong(1, paymentId);
                        ps.executeUpdate();
                    }

                    con.commit();

                    result = "EXPIRED";
                    message =
                            "Your reservation expired. Please book again.";

                } else if ("SUCCESS".equals(outcome)) {

                    String transactionReference =
                            "SIM-" + UUID.randomUUID()
                                        .toString()
                                        .replace("-", "")
                                        .substring(0, 16)
                                        .toUpperCase();

                    try (PreparedStatement ps = con.prepareStatement(
                            "UPDATE payments SET " +
                            "payment_status = 'SUCCESS', " +
                            "transaction_reference = ?, paid_at = NOW() " +
                            "WHERE payment_id = ? " +
                            "AND payment_status = 'PENDING'")) {

                        ps.setString(1, transactionReference);
                        ps.setLong(2, paymentId);

                        if (ps.executeUpdate() != 1) {
                            throw new PaymentException(
                                    "Payment could not be updated.");
                        }
                    }

                    try (PreparedStatement ps = con.prepareStatement(
                            "UPDATE bookings SET booking_status = 'CONFIRMED' " +
                            "WHERE booking_id = ? " +
                            "AND booking_status = 'PENDING_PAYMENT' " +
                            "AND reservation_expires_at > NOW()")) {

                        ps.setLong(1, bookingId);

                        if (ps.executeUpdate() != 1) {
                            throw new PaymentException(
                                    "The reservation expired before confirmation.");
                        }
                    }
                 
                 // Generate one ticket for each ticket in this booking.
                 

                 int ticketQuantity;

                 String quantitySql =
                         "SELECT ticket_quantity FROM bookings WHERE booking_id = ?";

                 try (PreparedStatement ps = con.prepareStatement(quantitySql)) {
                     ps.setLong(1, bookingId);

                     try (ResultSet rs = ps.executeQuery()) {
                         if (!rs.next()) {
                             throw new SQLException("Booking not found for ticket generation.");
                         }

                         ticketQuantity = rs.getInt("ticket_quantity");
                     }
                 }

                 String ticketSql =
                         "INSERT INTO tickets " +
                         "(booking_id, ticket_number, ticket_status, issued_at) " +
                         "VALUES (?, ?, 'VALID', NOW())";

                 try (PreparedStatement ps = con.prepareStatement(ticketSql)) {

                     for (int i = 0; i < ticketQuantity; i++) {

                         String ticketNumber =
                                 "TKT-" + UUID.randomUUID()
                                             .toString()
                                             .replace("-", "")
                                             .substring(0, 16)
                                             .toUpperCase();

                         ps.setLong(1, bookingId);
                         ps.setString(2, ticketNumber);
                         ps.addBatch();
                     }

                     ps.executeBatch();
                 }
                
                    con.commit();

                    result = "SUCCESS";
                    message = "Your simulated payment was successful!";

                } else {

                    try (PreparedStatement ps = con.prepareStatement(
                            "UPDATE payments SET payment_status = 'FAILED' " +
                            "WHERE payment_id = ? " +
                            "AND payment_status = 'PENDING'")) {

                        ps.setLong(1, paymentId);

                        if (ps.executeUpdate() != 1) {
                            throw new PaymentException(
                                    "Payment could not be updated.");
                        }
                    }

                    try (PreparedStatement ps = con.prepareStatement(
                            "UPDATE bookings SET booking_status = 'CANCELLED', " +
                            "cancelled_at = NOW(), " +
                            "reservation_expires_at = NOW() " +
                            "WHERE booking_id = ? " +
                            "AND booking_status = 'PENDING_PAYMENT'")) {

                        ps.setLong(1, bookingId);

                        if (ps.executeUpdate() != 1) {
                            throw new PaymentException(
                                    "Booking could not be cancelled.");
                        }
                    }

                    con.commit();

                    result = "FAILED";
                    message =
                            "Payment failed. Your temporary reservation " +
                            "has been cancelled.";
                }

            } catch (PaymentException | SQLException ex) {
                con.rollback();

                if (ex instanceof PaymentException) {
                    result = "ERROR";
                    message = ex.getMessage();
                } else {
                    throw (SQLException) ex;
                }
            } finally {
                con.setAutoCommit(true);
            }

        } catch (SQLException ex) {
            throw new ServletException(
                    "Unable to process payment.", ex);
        }

        request.setAttribute("paymentResult", result);
        request.setAttribute("resultMessage", message);
        request.setAttribute("bookingReference", getBookingReference(
                bookingId, userId));

        request.getRequestDispatcher("/payment-result.jsp")
               .forward(request, response);
    }

    private String getBookingReference(long bookingId, int userId)
            throws ServletException {

        String sql =
            "SELECT booking_reference FROM bookings " +
            "WHERE booking_id = ? AND user_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, bookingId);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString("booking_reference") : "";
            }

        } catch (SQLException ex) {
            throw new ServletException(
                    "Unable to load booking reference.", ex);
        }
    }

    private static class PaymentException extends Exception {
        private static final long serialVersionUID = 1L;

        PaymentException(String message) {
            super(message);
        }
    }
}
