
package eventManagement.servlet;

import java.io.IOException;
import java.sql.SQLException;

import eventManagement.dao.EventDAO;
import eventManagement.model.Event;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/event-details")
public class EventDetailsServlet extends HttpServlet {

    private final EventDAO eventDAO = new EventDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null
                || session.getAttribute("userId") == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login.jsp");
            return;
        }

        if (!"USER".equals(session.getAttribute("role"))) {
            response.sendError(403, "User access required");
            return;
        }

        try {
            String idText = request.getParameter("id");

            if (idText == null || idText.isBlank()) {
                response.sendError(400, "Event ID is required");
                return;
            }

            int id = Integer.parseInt(idText);

            if (id <= 0) {
                response.sendError(400, "Invalid event ID");
                return;
            }

            Event event = eventDAO.findPublishedById(id);

            if (event == null) {
                response.sendError(
                    404, "Event not found or registration is closed");
                return;
            }

            request.setAttribute("event", event);

            request.getRequestDispatcher("/event-details.jsp")
                   .forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(400, "Invalid event ID");
        } catch (SQLException e) {
            log("Unable to load event details", e);
            response.sendError(
                500, "Unable to load event details");
        }
    }
}
