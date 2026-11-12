
package eventManagement.servlet;

import eventManagement.dao.EventDAO;
import eventManagement.model.Event;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.Set;

@WebServlet("/admin/events")
public class AdminEventServlet extends HttpServlet {

    private final EventDAO eventDAO = new EventDAO();

    private static final Set<String> STATUSES =
            Set.of("DRAFT", "PUBLISHED", "CANCELLED", "COMPLETED");

    private boolean requireAdmin(HttpServletRequest request,
                                 HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login.jsp");
            return false;
        }

        if (!"ADMIN".equals(session.getAttribute("role"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Administrator access required");
            return false;
        }

        return true;
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        if (!requireAdmin(request, response)) return;

        try {
            String action = request.getParameter("action");

            if ("edit".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                Event event = eventDAO.findById(id);

                if (event == null) {
                    response.sendError(404, "Event not found");
                    return;
                }

                request.setAttribute("eventToEdit", event);
            }

            request.setAttribute("events", eventDAO.findAll());

            request.getRequestDispatcher("/manage-events.jsp")
                   .forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(400, "Invalid event ID");
        } catch (SQLException e) {
            log("Unable to load events", e);
            response.sendError(500, "Unable to load events");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        if (!requireAdmin(request, response)) return;

        request.setCharacterEncoding("UTF-8");

        try {
            String action = request.getParameter("action");

            if ("status".equals(action)) {
                int id = Integer.parseInt(
                        request.getParameter("eventId"));
                String status = request.getParameter("status");

                if (!STATUSES.contains(status)) {
                    response.sendError(400, "Invalid event status");
                    return;
                }

                if (!eventDAO.updateStatus(id, status)) {
                    response.sendError(404, "Event not found");
                    return;
                }

            } else if ("save".equals(action)) {
                Event event = readAndValidateEvent(request);

                String idText = request.getParameter("eventId");

                if (idText == null || idText.isBlank()) {
                    int adminId = ((Number) request.getSession(false)
                            .getAttribute("userId")).intValue();

                    eventDAO.create(event, adminId);
                } else {
                    event.setEventId(Integer.parseInt(idText));

                    if (!eventDAO.update(event)) {
                        response.sendError(404, "Event not found");
                        return;
                    }
                }

            } else {
                response.sendError(400, "Unknown action");
                return;
            }

            response.sendRedirect(
                    request.getContextPath() + "/admin/events?success=1");

        } catch (IllegalArgumentException e) {
            request.setAttribute("message", e.getMessage());
            reloadPage(request, response);

        } catch (SQLException e) {
            log("Unable to save event", e);
            request.setAttribute("message",
                    "Unable to save the event. Please check the details and try again.");
            reloadPage(request, response);
        }
    }

    private Event readAndValidateEvent(HttpServletRequest request) {
        Event e = new Event();

        String title = trim(request.getParameter("title"));
        String description = trim(request.getParameter("description"));
        String date = trim(request.getParameter("eventDate"));
        String start = trim(request.getParameter("startTime"));
        String end = trim(request.getParameter("endTime"));
        String venue = trim(request.getParameter("venue"));
        String priceText = trim(request.getParameter("ticketPrice"));
        String seatsText = trim(request.getParameter("totalSeats"));
        String deadline = trim(request.getParameter("registrationDeadline"));
        String status = trim(request.getParameter("status"));

        if (title.length() < 3 || venue.isBlank()
                || date.isBlank() || start.isBlank()
                || end.isBlank() || priceText.isBlank()
                || seatsText.isBlank() || deadline.isBlank()) {
            throw new IllegalArgumentException(
                    "Please fill in all required fields.");
        }

        if (title.length() > 150 || venue.length() > 200) {
            throw new IllegalArgumentException(
                    "Title or venue is too long.");
        }

        if (!STATUSES.contains(status)) {
            throw new IllegalArgumentException("Invalid event status.");
        }

        try {
            LocalDate.parse(date);
            LocalTime startTime = LocalTime.parse(start);
            LocalTime endTime = LocalTime.parse(end);

            if (!endTime.isAfter(startTime)) {
                throw new IllegalArgumentException(
                        "End time must be after start time.");
            }

            LocalDateTime.parse(deadline);

            BigDecimal price = new BigDecimal(priceText);
            int seats = Integer.parseInt(seatsText);

            if (price.compareTo(BigDecimal.ZERO) < 0
                    || seats <= 0) {
                throw new IllegalArgumentException(
                        "Price cannot be negative and seats must be positive.");
            }

            e.setTitle(title);
            e.setDescription(description);
            e.setEventDate(date);
            e.setStartTime(start);
            e.setEndTime(end);
            e.setVenue(venue);
            e.setTicketPrice(price.doubleValue());
            e.setTotalSeats(seats);
            e.setRegistrationDeadline(deadline);
            e.setStatus(status);

            return e;

        } catch (java.time.format.DateTimeParseException
                 | NumberFormatException ex) {
            throw new IllegalArgumentException(
                    "Please enter valid dates, times, price, and seat capacity.");
        }
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private void reloadPage(HttpServletRequest request,
                            HttpServletResponse response)
            throws ServletException, IOException {

        try {
            request.setAttribute("events", eventDAO.findAll());
            request.getRequestDispatcher("/manage-events.jsp")
                   .forward(request, response);
        } catch (SQLException e) {
            log("Unable to reload events page", e);
            response.sendError(500, "Unable to load events");
        }
    }
}
