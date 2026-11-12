
package eventManagement.servlet;

import java.io.IOException;
import java.sql.SQLException;

import eventManagement.dao.EventDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/events")
public class UserEventServlet extends HttpServlet {

    private final EventDAO eventDAO = new EventDAO();

    private boolean requireUser(HttpServletRequest request,
                                HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        if (session == null
                || session.getAttribute("userId") == null) {
            response.sendRedirect(
                request.getContextPath() + "/login.jsp");
            return false;
        }

        if (!"USER".equals(session.getAttribute("role"))) {
            response.sendError(403, "User access required");
            return false;
        }

        return true;
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        if (!requireUser(request, response)) {
            return;
        }

        try {
            request.setAttribute(
                "events", eventDAO.findPublishedEvents());

            request.getRequestDispatcher("/events.jsp")
                   .forward(request, response);

        } catch (SQLException e) {
            log("Unable to load published events", e);
            response.sendError(
                500, "Unable to load events. Please try again later.");
        }
    }
}
