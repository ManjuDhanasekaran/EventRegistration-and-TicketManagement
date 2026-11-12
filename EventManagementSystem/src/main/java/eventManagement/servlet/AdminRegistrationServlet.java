
package eventManagement.servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import eventManagement.dao.EventDAO;
import eventManagement.model.Event;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin/registrations")
public class AdminRegistrationServlet extends HttpServlet {

    private final EventDAO eventDAO = new EventDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String contextPath = request.getContextPath();

        HttpSession session = request.getSession(false);

        if (session == null ||
                session.getAttribute("userId") == null) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        if (!"ADMIN".equals(session.getAttribute("role"))) {
            response.sendError(403, "Access denied");
            return;
        }

        try {
            List<Event> events =
                    eventDAO.findAllWithRegistrationCount();

            request.setAttribute("events", events);

            request.getRequestDispatcher(
                    "/admin-registrations.jsp"
            ).forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to load events.", e);
        }
    }
}
