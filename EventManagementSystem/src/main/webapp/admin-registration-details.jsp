
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List,eventManagement.model.Event,eventManagement.model.AdminBooking" %>

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    if (!"ADMIN".equals(session.getAttribute("role"))) {
        response.sendError(403, "Access denied");
        return;
    }

    Event event = (Event) request.getAttribute("event");

    List<AdminBooking> bookings =
            (List<AdminBooking>) request.getAttribute("bookings");

    if (event == null) {
        response.sendError(404, "Event not found");
        return;
    }

    String adminName = String.valueOf(session.getAttribute("fullName"));
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Registration Details | Evently</title>

<style>
* {
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: "Segoe UI", Arial, sans-serif;
    background: #f4f6fb;
    color: #1d2742;
}

.layout {
    display: flex;
    min-height: 100vh;
}

/* Sidebar */
aside {
    width: 245px;
    background: #17213c;
    padding: 28px 17px;
    color: white;
    flex-shrink: 0;
}

.brand {
    font-size: 24px;
    font-weight: 800;
    padding: 0 13px 35px;
}

.brand span {
    color: #8c9eff;
}

.label {
    color: #8f9ab5;
    font-size: 11px;
    letter-spacing: 1.5px;
    padding: 10px 13px;
}

nav a {
    display: block;
    text-decoration: none;
    padding: 14px 13px;
    border-radius: 9px;
    color: #c5cde0;
    margin: 5px 0;
    font-size: 14px;
}

nav a.active,
nav a:hover {
    background: #303d61;
    color: white;
}

/* Main */
.main {
    flex: 1;
    min-width: 0;
}

header {
    height: 76px;
    background: white;
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0 34px;
    border-bottom: 1px solid #e8ebf3;
}

header small {
    color: #7c879e;
}

.admin-info {
    display: flex;
    align-items: center;
    gap: 12px;
}

.avatar {
    background: #e9edff;
    color: #3949ab;
    border-radius: 50%;
    width: 40px;
    height: 40px;
    display: grid;
    place-items: center;
    font-weight: bold;
}

.content {
    padding: 32px 34px;
    max-width: 1400px;
    margin: auto;
}

h1 {
    margin: 0 0 8px;
    font-size: 28px;
}

.muted {
    color: #7b8499;
    font-size: 14px;
}

.page-heading {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 15px;
    flex-wrap: wrap;
    margin-bottom: 25px;
}

.btn {
    display: inline-block;
    text-decoration: none;
    padding: 11px 17px;
    border-radius: 8px;
    font-weight: 700;
    font-size: 13px;
}

.back-btn {
    background: white;
    color: #45516b;
    border: 1px solid #dce1ec;
}

.back-btn:hover {
    background: #f1f3fa;
}

/* Event details */
.section {
    background: white;
    border: 1px solid #e9ecf4;
    border-radius: 14px;
    padding: 24px;
    margin-bottom: 24px;
    box-shadow: 0 5px 18px #27365b08;
}

.section h2 {
    margin: 0 0 20px;
    font-size: 18px;
}

.event-title {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    flex-wrap: wrap;
    margin-bottom: 20px;
}

.event-title h2 {
    margin: 0;
    font-size: 22px;
}

.pill {
    display: inline-block;
    border-radius: 20px;
    padding: 5px 9px;
    font-size: 10px;
    font-weight: 800;
}

.PUBLISHED {
    background: #e4f8ec;
    color: #16834b;
}

.DRAFT {
    background: #eef1f7;
    color: #65718b;
}

.CANCELLED {
    background: #ffebed;
    color: #c2394b;
}

.COMPLETED {
    background: #e9e9ff;
    color: #5551b5;
}

.details-grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 20px;
}

.detail-item small {
    display: block;
    color: #818ba1;
    font-size: 12px;
    margin-bottom: 6px;
}

.detail-item strong {
    font-size: 14px;
    overflow-wrap: anywhere;
}

.description {
    margin-top: 22px;
    padding-top: 18px;
    border-top: 1px solid #edf0f6;
    line-height: 1.7;
    color: #58647d;
    font-size: 14px;
}

/* Registration summary cards */
.summary {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    gap: 17px;
    margin-bottom: 24px;
}

.summary-card {
    background: white;
    border: 1px solid #e9ecf4;
    border-radius: 14px;
    padding: 20px;
    box-shadow: 0 5px 18px #27365b08;
}

.summary-card small {
    color: #78839a;
    font-size: 13px;
}

.summary-card h2 {
    margin: 10px 0 0;
    color: #4f5fe8;
    font-size: 28px;
}

.summary-card.confirmed h2 {
    color: #16834b;
}

.summary-card.pending h2 {
    color: #d18a00;
}

.summary-card.cancelled h2 {
    color: #c2394b;
}

.summary-card.expired h2 {
    color: #8a5360;
}

.summary-card.available h2 {
    color: #16834b;
}

/* Registration table */
.table-wrapper {
    overflow-x: auto;
}

table {
    width: 100%;
    border-collapse: collapse;
    font-size: 13px;
    min-width: 850px;
}

th {
    text-align: left;
    background: #f8f9fc;
    padding: 13px;
    color: #818ba1;
    text-transform: uppercase;
    font-size: 11px;
    white-space: nowrap;
}

td {
    padding: 15px 13px;
    border-bottom: 1px solid #edf0f6;
}

.status {
    display: inline-block;
    padding: 5px 9px;
    border-radius: 20px;
    font-size: 10px;
    font-weight: 800;
}

.CONFIRMED,
.SUCCESS {
    background: #e4f8ec;
    color: #16834b;
}

.PENDING_PAYMENT,
.PENDING {
    background: #fff4dc;
    color: #a56b00;
}

.FAILED,
.EXPIRED {
    background: #ffebed;
    color: #c2394b;
}

.REFUNDED,
.CANCELLED {
    background: #eef1f7;
    color: #65718b;
}

.empty {
    text-align: center;
    color: #8a93a8;
    padding: 35px;
}

.admin-logout {
    background: white;
    color: #4f5fe8;
    border: 1px solid #dce1ec;
    padding: 10px 17px;
    border-radius: 9px;
    font-size: 13px;
    font-weight: 700;
    cursor: pointer;
    transition: all 0.2s ease;
}

.admin-logout:hover {
    background: #4f5fe8;
    color: white;
    border-color: #4f5fe8;
    transform: translateY(-2px);
}
@media(max-width: 1000px) {
    .details-grid {
        grid-template-columns: repeat(2, minmax(0, 1fr));
    }

    .summary {
        grid-template-columns: repeat(2, minmax(0, 1fr));
    }
}

@media(max-width: 650px) {
    aside {
        width: 68px;
        padding: 20px 7px;
    }

    .brand {
        font-size: 0;
        padding: 5px 10px 30px;
    }

    .brand span {
        font-size: 22px;
    }

    .label {
        display: none;
    }

    nav a {
        font-size: 0;
        text-align: center;
        padding: 14px 4px;
    }

    nav a::first-letter {
        font-size: 17px;
    }

    header {
        padding: 0 14px;
    }

    .content {
        padding: 22px 14px;
    }

    .section {
        padding: 16px;
    }

    .details-grid {
        grid-template-columns: 1fr;
    }

    .summary {
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 10px;
    }

    .summary-card {
        padding: 14px;
    }

    .summary-card h2 {
        font-size: 23px;
    }
}
</style>
</head>

<body>

<div class="layout">

    <!-- Sidebar -->
    <aside>
        <div class="brand">event<span>ly.</span></div>

        <div class="label">WORKSPACE</div>

        <nav>
            <a href="<%= request.getContextPath() %>/admin-dashboard.jsp">
                ▦ &nbsp; Dashboard
            </a>

            <a href="<%= request.getContextPath() %>/admin/events">
                ▣ &nbsp; Manage Events
            </a>

            <a class="active" href="<%= request.getContextPath() %>/admin/registrations">
                ♧ &nbsp; Registrations
            </a>
        </nav>
    </aside>

    <!-- Main content -->
    <main class="main">

        <header>
            <div>
                <strong>Registration Details</strong><br>
                <small>Event registration overview</small>
            </div>

            
<div style="display:flex;align-items:center;gap:18px">

    <div class="avatar">A</div>

    <div>
        <strong style="font-size:14px">
            <%= String.valueOf(session.getAttribute("fullName")) %>
        </strong><br>
        <small>Administrator</small>
    </div>

    <form action="<%= request.getContextPath() %>/logout"
          method="post">
        <button type="submit" class="admin-logout">
            Logout ↗
        </button>
    </form>

</div>
            
        </header>

        <div class="content">

            <!-- Page heading -->
            <div class="page-heading">

                <div>
                    <h1>Event Details</h1>

                    <div class="muted">
                        Complete information and customer registrations.
                    </div>
                </div>

                <a class="btn back-btn"
                   href="<%= request.getContextPath() %>/admin/registrations">
                    ← Back to Registrations
                </a>

            </div>

            <!-- Event information -->
            <section class="section">

                <div class="event-title">

                    <h2><%= event.getTitle() %></h2>

                    <span class="pill <%= event.getStatus() %>">
                        <%= event.getStatus() %>
                    </span>

                </div>

                <div class="details-grid">

                    <div class="detail-item">
                        <small>Event Date</small>
                        <strong><%= event.getEventDate() %></strong>
                    </div>

                    <div class="detail-item">
                        <small>Start Time</small>
                        <strong><%= event.getStartTime() %></strong>
                    </div>

                    <div class="detail-item">
                        <small>End Time</small>
                        <strong><%= event.getEndTime() %></strong>
                    </div>

                    <div class="detail-item">
                        <small>Venue</small>
                        <strong><%= event.getVenue() %></strong>
                    </div>

                    <div class="detail-item">
                        <small>Ticket Price</small>
                        <strong>₹<%= event.getTicketPrice() %></strong>
                    </div>

                    <div class="detail-item">
                        <small>Total Seats</small>
                        <strong><%= event.getTotalSeats() %></strong>
                    </div>

                    <div class="detail-item">
                        <small>Registration Deadline</small>
                        <strong><%= event.getRegistrationDeadline() %></strong>
                    </div>

                </div>

                <div class="description">

                    <strong>Description</strong>

                    <p>
                        <%= event.getDescription() == null ||
                            event.getDescription().trim().isEmpty()
                            ? "No description available."
                            : event.getDescription() %>
                    </p>

                </div>

            </section>

            <!-- Registration statistics -->
            <div class="summary">

                <div class="summary-card">
                    <small>Total Event Seats</small>
                    <h2><%= event.getTotalSeats() %></h2>
                </div>

                <div class="summary-card confirmed">
                    <small>Confirmed Bookings</small>
                    <h2><%= event.getConfirmedBookings() %></h2>
                </div>

                <div class="summary-card confirmed">
                    <small>Confirmed Tickets</small>
                    <h2><%= event.getConfirmedTickets() %></h2>
                </div>

                <div class="summary-card pending">
                    <small>Pending Bookings</small>
                    <h2><%= event.getPendingBookings() %></h2>
                </div>

                <div class="summary-card pending">
                    <small>Pending Tickets</small>
                    <h2><%= event.getPendingTickets() %></h2>
                </div>

                <div class="summary-card cancelled">
                    <small>Cancelled Bookings</small>
                    <h2><%= event.getCancelledBookings() %></h2>
                </div>

                <div class="summary-card cancelled">
                    <small>Cancelled Tickets</small>
                    <h2><%= event.getCancelledTickets() %></h2>
                </div>

                <div class="summary-card expired">
                    <small>Expired Bookings</small>
                    <h2><%= event.getExpiredBookings() %></h2>
                </div>

                <div class="summary-card expired">
                    <small>Expired Tickets</small>
                    <h2><%= event.getExpiredTickets() %></h2>
                </div>

                <div class="summary-card available">
                    <small>Available Seats</small>
                    <h2><%= event.getAvailableSeats() %></h2>
                </div>

            </div>

            <!-- Customer registrations -->
            <section class="section">

                <h2>Customer Registrations</h2>

                <div class="muted"
                     style="margin-top:-12px; margin-bottom:20px">
                    All booking records for this event.
                </div>

                <div class="table-wrapper">

                    <table>

                        <thead>
                            <tr>
                                <th>Booking Reference</th>
                                <th>Customer Name</th>
                                <th>Email</th>
                                <th>Tickets</th>
                                <th>Amount</th>
                                <th>Booking Status</th>
                                <th>Payment Status</th>
                                <th>Booked At</th>
                            </tr>
                        </thead>

                        <tbody>

                        <%
                            if (bookings != null && !bookings.isEmpty()) {

                                for (AdminBooking b : bookings) {
                        %>

                            <tr>

                                <td>
                                    <strong><%= b.getBookingReference() %></strong>
                                </td>

                                <td><%= b.getFullName() %></td>

                                <td><%= b.getEmail() %></td>

                                <td><%= b.getTicketQuantity() %></td>

                                <td>₹<%= b.getTotalAmount() %></td>

                                <td>
                                    <span class="status <%= b.getBookingStatus() %>">
                                        <%= b.getBookingStatus() %>
                                    </span>
                                </td>

                                <td>
                                    <span class="status <%= b.getPaymentStatus() == null
                                            ? "PENDING" : b.getPaymentStatus() %>">

                                        <%= b.getPaymentStatus() == null
                                                ? "N/A" : b.getPaymentStatus() %>

                                    </span>
                                </td>

                                <td><%= b.getBookedAt() %></td>

                            </tr>

                        <%
                                }

                            } else {
                        %>

                            <tr>
                                <td colspan="8" class="empty">
                                    No registrations found for this event.
                                </td>
                            </tr>

                        <%
                            }
                        %>

                        </tbody>

                    </table>

                </div>

            </section>

        </div>

    </main>

</div>

</body>
</html>
