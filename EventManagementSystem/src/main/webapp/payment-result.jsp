
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%
    if (session.getAttribute("userId") == null ||
        !"USER".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String paymentResult =
        (String) request.getAttribute("paymentResult");

    String resultMessage =
        (String) request.getAttribute("resultMessage");

    String bookingReference =
        (String) request.getAttribute("bookingReference");

    if (paymentResult == null || resultMessage == null) {
        response.sendRedirect(request.getContextPath() + "/events");
        return;
    }

    boolean success = "SUCCESS".equals(paymentResult);
    boolean expired = "EXPIRED".equals(paymentResult);
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Payment Result | Eventify</title>

<style>
    * {
        box-sizing: border-box;
    }

    body {
        margin: 0;
        min-height: 100vh;
        display: grid;
        place-items: center;
        padding: 20px;
        background: #f6f7fc;
        font-family: "Segoe UI", Arial, sans-serif;
        color: #252943;
    }

    .result-card {
        background: white;
        width: min(470px, 100%);
        padding: 38px;
        border-radius: 24px;
        text-align: center;
        border: 1px solid #e9eaf3;
        box-shadow: 0 15px 45px rgba(30, 35, 70, .08);
    }

    .result-icon {
        width: 78px;
        height: 78px;
        border-radius: 50%;
        margin: 0 auto 22px;
        display: grid;
        place-items: center;
        font-size: 38px;
        background: <%= success ? "#dcfce7"
                         : expired ? "#fff1d9" : "#fee2e2" %>;
    }

    h1 {
        font-size: 27px;
        margin-bottom: 12px;
    }

    .message {
        color: #74798d;
        font-size: 15px;
        line-height: 1.7;
    }

    .reference {
        background: #f5f3ff;
        border-radius: 12px;
        padding: 15px;
        margin: 24px 0;
        overflow-wrap: anywhere;
    }

    .reference small {
        display: block;
        color: #777d91;
        margin-bottom: 5px;
    }

    .reference strong {
        color: #6546e8;
    }

    .button {
        display: inline-block;
        padding: 13px 22px;
        background: #6546e8;
        color: white;
        text-decoration: none;
        border-radius: 11px;
        font-size: 14px;
        font-weight: 700;
    }

    .button:hover {
        background: #5033d0;
    }
</style>
</head>

<body>

<div class="result-card">

    <div class="result-icon">
        <%= success ? "✓" : expired ? "⌛" : "!" %>
    </div>

    <h1>
        <%= success ? "Booking Confirmed!"
             : expired ? "Reservation Expired"
             : "Payment Unsuccessful" %>
    </h1>

    <p class="message">
        <%= resultMessage %>
    </p>

    <% if (bookingReference != null
            && !bookingReference.isEmpty()) { %>

        <div class="reference">
            <small>Booking Reference</small>
            <strong><%= bookingReference %></strong>
        </div>

    <% } %>

    <% if (success) { %>
        <a class="button"
           href="${pageContext.request.contextPath}/events">
            Explore More Events
        </a>
    <% } else { %>
        <a class="button"
           href="${pageContext.request.contextPath}/events">
            Back to Events
        </a>
    <% } %>

</div>

</body>
</html>
