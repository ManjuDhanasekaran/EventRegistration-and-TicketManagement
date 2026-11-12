
package eventManagement.servlet;

import java.io.IOException;
import java.sql.SQLException;

import eventManagement.dao.BookingDAO;
import eventManagement.model.Booking;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/create-booking")
public class BookingServlet extends HttpServlet {

    private final BookingDAO bookingDAO = new BookingDAO();

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null ||
                !"USER".equals(session.getAttribute("role")) ||
                !(session.getAttribute("userId") instanceof Number)) {

            response.sendRedirect(
                    request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            int userId = ((Number)
                    session.getAttribute("userId")).intValue();

            int eventId = Integer.parseInt(
                    request.getParameter("eventId"));

            int quantity = Integer.parseInt(
                    request.getParameter("quantity"));

            Booking booking = bookingDAO.createPendingBooking(
                    userId, eventId, quantity);

            request.setAttribute("booking", booking);
            request.getRequestDispatcher("/payment.jsp")
                   .forward(request, response);

        } catch (NumberFormatException ex) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid event or ticket quantity.");

        } catch (IllegalArgumentException ex) {
            request.setAttribute("errorMessage", ex.getMessage());
            request.getRequestDispatcher("/booking-error.jsp")
                   .forward(request, response);

        } catch (SQLException ex) {
            throw new ServletException(
                    "Unable to create booking.", ex);
        }
    }
}
