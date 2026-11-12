package eventManagement.servlet;
import java.io.IOException;
import java.sql.*;

import eventManagement.dao.UserDAO;
import eventManagement.model.User;
import eventManagement.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email == null || password == null
                || email.isBlank() || password.isEmpty()) {

            request.setAttribute("message",
                    "Please enter your email and password.");

            request.getRequestDispatcher("/login.jsp")
                   .forward(request, response);
            return;
        }

        try {
            User user = userDAO.findByEmail(
                    email.trim().toLowerCase());

            if (user == null
                    || !"ACTIVE".equals(user.getStatus())
                    || !PasswordUtil.verifyPassword(
                            password, user.getPassword())) {

                request.setAttribute("message",
                        "Invalid email or password.");

                request.getRequestDispatcher("/login.jsp")
                       .forward(request, response);
                return;
            }

            // Create a new session ID after authentication
            HttpSession session = request.getSession(true);
            request.changeSessionId();

            session.setAttribute("userId", user.getUserId());
            session.setAttribute("fullName", user.getFullName());
            session.setAttribute("email", user.getEmail());
            session.setAttribute("role", user.getRole());

            session.setMaxInactiveInterval(30 * 60);

            if ("ADMIN".equals(user.getRole())) {
                response.sendRedirect(
                        request.getContextPath()
                        + "/admin-dashboard.jsp");
            } else {
                response.sendRedirect(
                        request.getContextPath()
                        + "/home.jsp");
            }

        } catch (SQLException e) {
            log("Login database error", e);

            request.setAttribute("message",
                    "Unable to log in right now. Please try again.");

            request.getRequestDispatcher("/login.jsp")
                   .forward(request, response);
        }
    }
}
