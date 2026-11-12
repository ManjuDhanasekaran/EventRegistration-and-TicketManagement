
package eventManagement.servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import eventManagement.dao.EventDAO;
import eventManagement.dao.BookingDAO;
import eventManagement.model.Event;
import eventManagement.model.AdminBooking;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin/registrations/details")
public class AdminRegistrationDetailsServlet extends HttpServlet {

    private final EventDAO eventDAO = new EventDAO();
    private final BookingDAO bookingDAO = new BookingDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String contextPath = request.getContextPath();

        // 1. Check admin session
        HttpSession session = request.getSession(false);

        if (session == null ||
                session.getAttribute("userId") == null) {

            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        if (!"ADMIN".equals(session.getAttribute("role"))) {

            response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Access denied"
            );
            return;
        }

        // 2. Get event ID from URL
        String eventIdValue = request.getParameter("eventId");

        if (eventIdValue == null || eventIdValue.trim().isEmpty()) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Event ID is required."
            );
            return;
        }

        try {

            int eventId = Integer.parseInt(eventIdValue);

            if (eventId <= 0) {
                response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid event ID."
                );
                return;
            }

            // 3. Retrieve selected event
            //Event event = eventDAO.findById(eventId);
            Event event = eventDAO.findByIdWithRegistrationStats(eventId);

            if (event == null) {
                response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Event not found."
                );
                return;
            }

            // 4. Retrieve registrations for this event
            List<AdminBooking> bookings =
                    bookingDAO.findBookingsByEventId(eventId);

            // 5. Send data to JSP
            request.setAttribute("event", event);
            request.setAttribute("bookings", bookings);

            request.getRequestDispatcher(
                "/admin-registration-details.jsp"
            ).forward(request, response);

        } catch (NumberFormatException e) {

            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Invalid event ID."
            );

        } catch (SQLException e) {

            throw new ServletException(
                "Unable to load event registration details.", e
            );
        }
    }
}
