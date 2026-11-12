
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="eventManagement.model.Ticket" %>

<%!
    private String esc(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    if (session.getAttribute("userId") == null ||
        !"USER".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    List<Ticket> tickets =
        (List<Ticket>) request.getAttribute("tickets");

    if (tickets == null) {
        response.sendRedirect(request.getContextPath() + "/my-tickets");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>My Tickets | Eventify</title>

<style>
    * {
        box-sizing: border-box;
    }

    body {
        margin: 0;
        font-family: "Segoe UI", Arial, sans-serif;
        color: #252943;
        background: #f7f8fc;
    }

    a {
        text-decoration: none;
    }

    
    .container {
        width: min(1050px, 90%);
        margin: 45px auto;
    }

    .heading {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 20px;
        margin-bottom: 28px;
    }

    .heading h1 {
        font-size: 32px;
        margin: 0 0 6px;
        letter-spacing: -.8px;
    }

    .heading p {
        color: #80859a;
        margin: 0;
        font-size: 14px;
    }

    .browse-btn {
        padding: 12px 18px;
        border-radius: 11px;
        background: #6546e8;
        color: white;
        font-size: 14px;
        font-weight: 700;
        white-space: nowrap;
    }

    .browse-btn:hover {
        background: #5033d0;
    }

    .ticket-list {
        display: grid;
        gap: 20px;
    }

    .ticket {
        display: grid;
        grid-template-columns: 1fr 230px;
        background: white;
        border: 1px solid #e8e9f2;
        border-radius: 19px;
        overflow: hidden;
        box-shadow: 0 8px 24px rgba(30,35,70,.035);
    }

    .ticket-main {
        padding: 26px;
    }

    .ticket-top {
        display: flex;
        justify-content: space-between;
        align-items: start;
        gap: 12px;
        margin-bottom: 18px;
    }

    .ticket h2 {
        font-size: 21px;
        margin: 0 0 8px;
    }

    .ticket-reference {
        color: #888da0;
        font-size: 12px;
        overflow-wrap: anywhere;
    }

    .status {
        display: inline-block;
        padding: 6px 10px;
        border-radius: 20px;
        background: #dcfce7;
        color: #166534;
        font-size: 11px;
        font-weight: 800;
        white-space: nowrap;
    }

    .status.cancelled {
        background: #fee2e2;
        color: #991b1b;
    }

    .status.used {
        background: #e5e7eb;
        color: #374151;
    }

    .details {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 18px;
    }

    .detail-label {
        color: #9296a7;
        font-size: 11px;
        text-transform: uppercase;
        letter-spacing: .6px;
        margin-bottom: 5px;
    }

    .detail-value {
        font-size: 14px;
        font-weight: 600;
        overflow-wrap: anywhere;
    }

    .ticket-side {
        background: #f2efff;
        border-left: 2px dashed #d7ceff;
        padding: 26px 20px;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        text-align: center;
    }

    .ticket-symbol {
        width: 58px;
        height: 58px;
        border-radius: 17px;
        display: grid;
        place-items: center;
        background: white;
        color: #6546e8;
        font-size: 29px;
        margin-bottom: 15px;
    }

    .ticket-side small {
        color: #7b719f;
        font-size: 11px;
        text-transform: uppercase;
        letter-spacing: .7px;
    }

    .ticket-number {
        color: #5033d0;
        font-weight: 800;
        font-size: 14px;
        margin-top: 6px;
        overflow-wrap: anywhere;
    }

    .empty {
        text-align: center;
        padding: 65px 20px;
        border-radius: 20px;
        background: white;
        border: 1px solid #e8e9f2;
    }

    .empty-icon {
        font-size: 52px;
        margin-bottom: 12px;
    }

    .empty h2 {
        margin: 0 0 10px;
    }

    .empty p {
        color: #85899b;
        margin-bottom: 24px;
    }

    footer {
        text-align: center;
        color: #9296a7;
        font-size: 12px;
        padding: 28px 15px;
        margin-top: 50px;
    }

    @media (max-width: 720px) {
       

        .heading {
            align-items: start;
            flex-direction: column;
        }

        .ticket {
            grid-template-columns: 1fr;
        }

        .ticket-side {
            border-left: none;
            border-top: 2px dashed #d7ceff;
        }
    }

    @media (max-width: 450px) {
        .details {
            grid-template-columns: 1fr;
        }

        .ticket-top {
            flex-direction: column;
        }

        .ticket-main {
            padding: 21px;
        }
    }
</style>
</head>

<body>

<jsp:include page="navbar.jsp" />


<main class="container">

    <div class="heading">
        <div>
            <h1>My Tickets 🎟️</h1>
            <p>Your confirmed event tickets, all in one place.</p>
        </div>

        <a class="browse-btn"
           href="${pageContext.request.contextPath}/events">
            + Explore Events
        </a>
    </div>

    <% if (tickets.isEmpty()) { %>

        <div class="empty">
            <div class="empty-icon">🎫</div>
            <h2>No tickets yet</h2>
            <p>
                Once your payment is successful, your event tickets
                will appear here.
            </p>
            <a class="browse-btn"
               href="${pageContext.request.contextPath}/events">
                Find an Event
            </a>
        </div>

    <% } else { %>

        <div class="ticket-list">

        <% for (Ticket ticket : tickets) { 
               String status = ticket.getTicketStatus();
               String statusClass = "VALID".equals(status) ? ""
                   : "CANCELLED".equals(status) ? "cancelled" : "used";
        %>

            <article class="ticket">

                <div class="ticket-main">

                    <div class="ticket-top">
                        <div>
                            <h2><%= esc(ticket.getEventTitle()) %></h2>
                            <div class="ticket-reference">
                                Booking: <%= esc(ticket.getBookingReference()) %>
                            </div>
                        </div>

                        <span class="status <%= statusClass %>">
                            <%= esc(status) %>
                        </span>
                    </div>

                    <div class="details">

                        <div>
                            <div class="detail-label">Event Date</div>
                            <div class="detail-value">
                                <%= esc(ticket.getEventDate()) %>
                            </div>
                        </div>

                        <div>
                            <div class="detail-label">Start Time</div>
                            <div class="detail-value">
                                <%= esc(ticket.getStartTime()) %>
                            </div>
                        </div>

                        <div>
                            <div class="detail-label">Venue</div>
                            <div class="detail-value">
                                <%= esc(ticket.getVenue()) %>
                            </div>
                        </div>

                        <div>
                            <div class="detail-label">Ticket Status</div>
                            <div class="detail-value">
                                <%= esc(status) %>
                            </div>
                        </div>

                    </div>
                </div>

                <div class="ticket-side">
                    <div class="ticket-symbol">🎟️</div>
                    <small>Unique Ticket Number</small>
                    <div class="ticket-number">
                        <%= esc(ticket.getTicketNumber()) %>
                    </div>
                </div>

            </article>

        <% } %>

        </div>

    <% } %>

</main>

<footer>
    © 2026 Eventify — Discover experiences. Make memories.
</footer>

</body>
</html>
