
<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Create Account</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f1f5f9;
            margin: 0;
            min-height: 100vh;
            display: grid;
            place-items: center;
        }

        .card {
            background: white;
            width: min(360px, 85%);
            padding: 28px;
            border-radius: 12px;
            box-shadow: 0 5px 22px #00000012;
        }

        h2 { text-align: center; color: #1e293b; }

        label {
            display: block;
            margin-top: 15px;
            font-weight: bold;
        }

        input {
            box-sizing: border-box;
            width: 100%;
            padding: 11px;
            margin-top: 6px;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
        }

        button {
            width: 100%;
            margin-top: 22px;
            padding: 12px;
            background: #2563eb;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
        }

        .message {
            color: #b91c1c;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="card">
        <h2>Create Account</h2>

        <% if (request.getAttribute("message") != null) { %>
            <p class="message">
                <%= request.getAttribute("message") %>
            </p>
        <% } %>

        <form action="${pageContext.request.contextPath}/register"
              method="post">

            <label>Full Name</label>
            <input type="text" name="fullName"
                   minlength="2" required>

            <label>Email</label>
            <input type="email" name="email" required>

            <label>Password</label>
            <input type="password" name="password" 
                   minlength="8" required>

            <button type="submit">Register</button>
        </form>

        <p style="text-align:center">
            Already registered?
            <a href="${pageContext.request.contextPath}/login.jsp">
                Login
            </a>
        </p>
    </div>
</body>
</html>
