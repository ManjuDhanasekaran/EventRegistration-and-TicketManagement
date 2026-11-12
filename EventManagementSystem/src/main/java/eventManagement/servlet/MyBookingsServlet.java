package eventManagement.servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import eventManagement.dao.BookingDAO;
import eventManagement.model.MyBooking;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/my-bookings")
public class MyBookingsServlet extends HttpServlet {

    private final BookingDAO bookingDAO = new BookingDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(
                request.getContextPath() + "/login.jsp");
            return;
        }

        if (!"USER".equals(String.valueOf(
                session.getAttribute("role")))) {
            response.sendRedirect(
                request.getContextPath() + "/admin-dashboard.jsp");
            return;
        }

        int userId = ((Number) session.getAttribute("userId")).intValue();

        try {
            List<MyBooking> bookings =
                bookingDAO.findBookingsByUserId(userId);

            request.setAttribute("bookings", bookings);

            request.getRequestDispatcher("/my-bookings.jsp")
                   .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                "Unable to retrieve your bookings.", e);
        }
    }
}