
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Booking Error | Eventify</title>

<style>
    body {
        margin: 0;
        min-height: 100vh;
        display: grid;
        place-items: center;
        background: #f7f8fc;
        font-family: "Segoe UI", Arial, sans-serif;
        color: #252943;
    }

    .card {
        width: min(420px, 85%);
        padding: 35px;
        text-align: center;
        background: white;
        border-radius: 22px;
        box-shadow: 0 12px 40px rgba(30, 35, 70, .09);
    }

    .icon {
        font-size: 48px;
    }

    h2 {
        margin-bottom: 10px;
    }

    p {
        color: #73788c;
    }

    a {
        display: inline-block;
        margin-top: 15px;
        padding: 12px 20px;
        border-radius: 10px;
        background: #6546e8;
        color: white;
        text-decoration: none;
        font-weight: 700;
    }
</style>
</head>

<body>
    <div class="card">
        <div class="icon">⚠️</div>
        <h2>Booking Unsuccessful</h2>

       <p>
    <%= request.getAttribute("errorMessage") == null
            ? "Please try again."
            : request.getAttribute("errorMessage") %>
</p>

        <a href="${pageContext.request.contextPath}/events">
            Back to Events
        </a>
    </div>
</body>
</html>
