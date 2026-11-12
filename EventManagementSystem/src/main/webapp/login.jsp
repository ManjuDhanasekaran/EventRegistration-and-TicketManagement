
<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Login - Event Registration</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <style>
        body {
            margin: 0;
            min-height: 100vh;
            display: grid;
            place-items: center;
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #dbeafe, #eef2ff);
        }

        .card {
            width: min(360px, 85%);
            background: white;
            padding: 30px;
            border-radius: 14px;
            box-shadow: 0 8px 28px #00000015;
        }

        h2 {
            text-align: center;
            color: #1e293b;
        }

        .subtitle {
            text-align: center;
            color: #64748b;
            margin-bottom: 25px;
        }

        label {
            display: block;
            margin-top: 16px;
            font-weight: bold;
            color: #334155;
        }

        input {
            box-sizing: border-box;
            width: 100%;
            padding: 12px;
            margin-top: 7px;
            border: 1px solid #cbd5e1;
            border-radius: 7px;
        }

        button {
            width: 100%;
            padding: 12px;
            margin-top: 23px;
            border: none;
            border-radius: 7px;
            background: #2563eb;
            color: white;
            font-size: 16px;
            cursor: pointer;
        }

        button:hover {
            background: #1d4ed8;
        }

        .message {
            text-align: center;
            color: #b91c1c;
        }

        .success {
            text-align: center;
            color: #15803d;
        }

        .footer {
            text-align: center;
            margin-top: 20px;
        }
    </style>
</head>

<body>
    <div class="card">
        <h2>Welcome Back!</h2>
        <p class="subtitle">Login to explore upcoming events</p>

        <% if ("1".equals(request.getParameter("registered"))) { %>
            <p class="success">
                Registration successful! Please log in.
            </p>
        <% } %>

        <% if (request.getAttribute("message") != null) { %>
            <p class="message">
                <%= request.getAttribute("message") %>
            </p>
        <% } %>

        <form action="${pageContext.request.contextPath}/login"
              method="post">

            <label>Email Address</label>
            <input type="email" name="email"
                   autocomplete="username" required>

            <label>Password</label>
            <input type="password" name="password"
                   autocomplete="current-password" required>

            <button type="submit">Login</button>
        </form>

        <div class="footer">
            Don't have an account?
            <a href="${pageContext.request.contextPath}/register.jsp">
                Register
            </a>
        </div>
    </div>
</body>
</html>
