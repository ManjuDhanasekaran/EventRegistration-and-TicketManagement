
package eventManagement.servlet;

import java.io.IOException;
import java.sql.SQLException;

import eventManagement.dao.BookingDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/cancel-booking")
public class CancelBookingServlet extends HttpServlet {

    private final BookingDAO bookingDAO = new BookingDAO();

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String contextPath = request.getContextPath();

        HttpSession session = request.getSession(false);

        // 1. Verify the login session.
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        // 2. Only normal users can cancel their bookings.
        if (!"USER".equals(String.valueOf(session.getAttribute("role")))) {
            response.sendRedirect(contextPath + "/admin-dashboard.jsp");
            return;
        }

        // 3. Read the logged-in user's ID.
        int userId = ((Number) session.getAttribute("userId")).intValue();

        // 4. Read and validate the booking reference.
        String bookingReference = request.getParameter("bookingReference");

        if (bookingReference == null || bookingReference.trim().isEmpty()) {
            response.sendRedirect(contextPath + "/my-bookings?cancel=invalid");
            return;
        }

        try {
            boolean cancelled = bookingDAO.cancelBooking(
                userId, bookingReference.trim()
            );

            if (cancelled) {
                response.sendRedirect(
                    contextPath + "/my-bookings?cancel=success"
                );
            } else {
                response.sendRedirect(
                    contextPath + "/my-bookings?cancel=failed"
                );
            }

        } catch (SQLException e) {
            throw new ServletException("Unable to cancel the booking.", e);
        }
    }
}
