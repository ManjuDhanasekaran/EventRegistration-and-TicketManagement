
package eventManagement.servlet;

import java.io.IOException;
import java.sql.SQLException;

import eventManagement.dao.UserProfileDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/update-profile")
public class UpdateProfileServlet extends HttpServlet {

    private final UserProfileDAO profileDAO = new UserProfileDAO();

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

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

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");

        if (fullName == null || email == null) {
            response.sendRedirect(contextPath + "/profile?status=invalid");
            return;
        }

        fullName = fullName.trim();
        email = email.trim().toLowerCase(java.util.Locale.ROOT);

        // Validate the full name.
        if (fullName.length() < 2 || fullName.length() > 100
                || fullName.matches(".*\\s{2,}.*")) {
            response.sendRedirect(contextPath + "/profile?status=invalid");
            return;
        }

        // Validate the email format.
        if (email.length() > 254
                || !email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            response.sendRedirect(contextPath + "/profile?status=invalid");
            return;
        }

        try {
            // Prevent a user from taking another user's email.
            if (profileDAO.emailExistsForAnotherUser(email, userId)) {
                response.sendRedirect(
                    contextPath + "/profile?status=duplicate"
                );
                return;
            }

            boolean updated =
                profileDAO.updateProfile(userId, fullName, email);

            if (updated) {
                session.setAttribute("fullName", fullName);

                response.sendRedirect(
                    contextPath + "/profile?status=success"
                );
            } else {
                response.sendRedirect(
                    contextPath + "/profile?status=failed"
                );
            }

        } catch (SQLException e) {
            // A database uniqueness constraint may also reject the update.
            String message = e.getMessage() == null ? "" : e.getMessage();

            if ("23000".equals(e.getSQLState())
                    || message.toLowerCase(java.util.Locale.ROOT)
                              .contains("duplicate")) {
                response.sendRedirect(
                    contextPath + "/profile?status=duplicate"
                );
                return;
            }

            throw new ServletException("Unable to update user profile.", e);
        }
    }
}
