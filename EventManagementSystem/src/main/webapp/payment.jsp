
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="eventManagement.model.Booking" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>

<%
    if (session.getAttribute("userId") == null ||
        !"USER".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    Booking booking = (Booking) request.getAttribute("booking");

    if (booking == null) {
        response.sendRedirect(request.getContextPath() + "/events");
        return;
    }

    NumberFormat currency =
        NumberFormat.getCurrencyInstance(new Locale("en", "IN"));
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Payment | Eventify</title>

<style>
    * {
        box-sizing: border-box;
    }

    body {
        margin: 0;
        font-family: "Segoe UI", Arial, sans-serif;
        background: #f6f7fc;
        color: #252943;
    }

    .navbar {
        padding: 20px 7%;
        background: white;
        box-shadow: 0 3px 15px rgba(30, 35, 70, .05);
    }

    .logo {
        color: #6546e8;
        font-size: 25px;
        font-weight: 800;
        text-decoration: none;
    }

    .logo span {
        color: #252943;
    }

    .container {
        width: min(920px, 92%);
        margin: 45px auto;
    }

    .heading {
        text-align: center;
        margin-bottom: 30px;
    }

    .heading h1 {
        font-size: 32px;
        margin-bottom: 8px;
    }

    .heading p {
        color: #7b8095;
    }

    .payment-layout {
        display: grid;
        grid-template-columns: 1.1fr .9fr;
        gap: 22px;
    }

    .card {
        background: white;
        border: 1px solid #e9eaf3;
        border-radius: 20px;
        padding: 28px;
        box-shadow: 0 10px 30px rgba(30, 35, 70, .04);
    }

    .card h2 {
        font-size: 19px;
        margin-top: 0;
        margin-bottom: 22px;
    }

    .row-item {
        display: flex;
        justify-content: space-between;
        gap: 15px;
        padding: 14px 0;
        border-bottom: 1px solid #eff0f6;
        font-size: 14px;
    }

    .row-item span:first-child {
        color: #777d91;
    }

    .row-item strong {
        text-align: right;
        overflow-wrap: anywhere;
    }

    .total {
        margin-top: 12px;
        padding-top: 20px;
        border-top: 2px dashed #e3e1f4;
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 12px;
    }

    .total strong {
        font-size: 24px;
        color: #6546e8;
    }

    .demo-label {
        display: inline-block;
        padding: 7px 11px;
        background: #fff1d9;
        color: #975900;
        border-radius: 8px;
        font-size: 12px;
        font-weight: 700;
        margin-bottom: 18px;
    }

    .notice {
        background: #f2efff;
        border-radius: 12px;
        padding: 14px;
        color: #55419e;
        font-size: 13px;
        margin: 20px 0;
    }

    .pay-button {
        width: 100%;
        border: none;
        border-radius: 11px;
        padding: 14px;
        font-size: 14px;
        font-weight: 700;
        cursor: pointer;
        margin-top: 12px;
    }

    .success-button {
        background: #6546e8;
        color: white;
    }

    .success-button:hover {
        background: #5033d0;
    }

    .failure-button {
        background: white;
        color: #d14343;
        border: 1px solid #f0cccc;
    }

    .failure-button:hover {
        background: #fff4f4;
    }

    .back-link {
        display: block;
        text-align: center;
        color: #777d91;
        font-size: 13px;
        margin-top: 18px;
        text-decoration: none;
    }

    @media (max-width: 700px) {
        .payment-layout {
            grid-template-columns: 1fr;
        }

        .container {
            margin-top: 28px;
        }

        .card {
            padding: 22px;
        }
    }
</style>
</head>

<body>

<nav class="navbar">
    <a class="logo"
       href="${pageContext.request.contextPath}/home.jsp">
        Event<span>ify.</span>
    </a>
</nav>

<main class="container">

    <div class="heading">
        <h1>Complete Your Booking</h1>
        <p>Review your booking details before continuing.</p>
    </div>

    <div class="payment-layout">

        <section class="card">
            <h2>Booking Summary</h2>

            <div class="row-item">
                <span>Booking reference</span>
                <strong><%= booking.getBookingReference() %></strong>
            </div>

            <div class="row-item">
                <span>Booking ID</span>
                <strong><%= booking.getBookingId() %></strong>
            </div>

            <div class="row-item">
                <span>Tickets</span>
                <strong><%= booking.getTicketQuantity() %></strong>
            </div>

            <div class="row-item">
                <span>Price per ticket</span>
                <strong><%= currency.format(
                    booking.getUnitPrice()) %></strong>
            </div>

            <div class="total">
                <span>Total amount</span>
                <strong><%= currency.format(
                    booking.getTotalAmount()) %></strong>
            </div>

            <div class="notice">
                Your seats are temporarily reserved for 10 minutes.
                Complete the payment simulation before the reservation
                expires.
            </div>
        </section>

        <section class="card">
            <h2>Choose Payment Result</h2>

            <span class="demo-label">
                DEMO MODE — NO REAL MONEY
            </span>

            <p style="color:#777d91;font-size:14px;">
                This project uses simulated payment buttons.
                No card or bank details are required.
            </p>

            <form action="${pageContext.request.contextPath}/process-payment"
                  method="post">

                <input type="hidden" name="bookingId"
                       value="<%= booking.getBookingId() %>">

                <button class="pay-button success-button"
                        type="submit"
                        name="paymentOutcome"
                        value="SUCCESS">
                    Simulate Successful Payment
                </button>

                <button class="pay-button failure-button"
                        type="submit"
                        name="paymentOutcome"
                        value="FAILED">
                    Simulate Failed Payment
                </button>

            </form>

            <a class="back-link"
               href="${pageContext.request.contextPath}/events">
                ← Back to Events
            </a>
        </section>

    </div>
</main>

</body>
</html>
