
package eventManagement.servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import eventManagement.dao.TicketDAO;
import eventManagement.model.Ticket;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/my-tickets")
public class TicketServlet extends HttpServlet {

    private final TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doGet(
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

        try {
            List<Ticket> tickets =
                    ticketDAO.findByUserId(userId);

            request.setAttribute("tickets", tickets);

            request.getRequestDispatcher("/my-tickets.jsp")
                   .forward(request, response);

        } catch (SQLException ex) {
            throw new ServletException(
                    "Unable to load your tickets.", ex);
        }
    }
}
