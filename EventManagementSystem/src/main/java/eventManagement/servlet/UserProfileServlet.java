
package eventManagement.servlet;

import java.io.IOException;
import java.sql.SQLException;

import eventManagement.dao.UserProfileDAO;
import eventManagement.model.UserProfile;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/profile")
public class UserProfileServlet extends HttpServlet {

    private final UserProfileDAO profileDAO = new UserProfileDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String contextPath = request.getContextPath();
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        if (!"USER".equals(String.valueOf(session.getAttribute("role")))) {
            response.sendRedirect(contextPath + "/admin-dashboard.jsp");
            return;
        }

        int userId = ((Number) session.getAttribute("userId")).intValue();

        try {
            UserProfile profile = profileDAO.findById(userId);

            if (profile == null) {
                response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "User profile not found."
                );
                return;
            }

            request.setAttribute("profile", profile);

            String status = request.getParameter("status");

            if ("success".equals(status)) {
                request.setAttribute(
                    "message", "Your profile was updated successfully."
                );
            } else if ("invalid".equals(status)) {
                request.setAttribute(
                    "error", "Please enter a valid name and email address."
                );
            } else if ("duplicate".equals(status)) {
                request.setAttribute(
                    "error", "This email address is already registered."
                );
            } else if ("failed".equals(status)) {
                request.setAttribute(
                    "error", "Unable to update your profile. Please try again."
                );
            }

            request.getRequestDispatcher("/profile.jsp")
                   .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException("Unable to load user profile.", e);
        }
    }
}
