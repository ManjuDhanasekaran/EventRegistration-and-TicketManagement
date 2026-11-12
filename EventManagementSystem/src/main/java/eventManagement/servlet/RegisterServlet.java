package eventManagement.servlet;


import java.io.IOException;
import java.sql.SQLException;

import eventManagement.dao.UserDAO;
import eventManagement.model.User;
import eventManagement.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

  
	private static final long serialVersionUID = 1L;
	
	private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String name = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (name == null || name.trim().length() < 2
                || email == null
                || !email.matches(
                    "^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")
                || password == null
                || password.length() < 8) {

            request.setAttribute("message",
                    "Enter a valid name and email. "
                  + "Password must be at least 8 characters.");

            request.getRequestDispatcher("/register.jsp")
                   .forward(request, response);
            return;
        }

        try {
            String passwordHash =
                    PasswordUtil.hashPassword(password);

            User user = new User(
                    name.trim(),
                    email.trim().toLowerCase(),
                    passwordHash
            );

            if (userDAO.register(user)) {
                response.sendRedirect(
                        request.getContextPath()
                        + "/login.jsp?registered=1");
            } else {
                request.setAttribute("message",
                        "Registration failed. Please try again.");
                request.getRequestDispatcher("/register.jsp")
                       .forward(request, response);
            }

        } catch (SQLException e) {
            if ("23000".equals(e.getSQLState())) {
                request.setAttribute("message",
                        "This email may already be registered.");
            } else {
                log("Registration database error", e);
                request.setAttribute("message",
                        "Unable to register now. Please try again.");
            }

            request.getRequestDispatcher("/register.jsp")
                   .forward(request, response);
        }
    }
}

