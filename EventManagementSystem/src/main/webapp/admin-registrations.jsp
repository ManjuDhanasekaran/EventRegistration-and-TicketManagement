
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List,eventManagement.model.Event" %>

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    if (!"ADMIN".equals(session.getAttribute("role"))) {
        response.sendError(403, "Access denied");
        return;
    }

    List<Event> events = (List<Event>) request.getAttribute("events");

    String adminName = String.valueOf(session.getAttribute("fullName"));
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Registrations | Evently</title>

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

/* Main content */
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

/* Page heading */
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
    cursor: pointer;
}

.back-btn {
    background: white;
    color: #45516b;
    border: 1px solid #dce1ec;
}

.back-btn:hover {
    background: #f1f3fa;
}

/* Event cards */
.event-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 20px;
}

.event-card {
    background: white;
    border: 1px solid #e9ecf4;
    border-radius: 14px;
    padding: 23px;
    box-shadow: 0 5px 18px #27365b08;
    transition: transform 0.2s, box-shadow 0.2s;
}

.event-card:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 22px #27365b12;
}

.card-top {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 12px;
    margin-bottom: 18px;
}

.event-card h2 {
    margin: 0;
    font-size: 19px;
    overflow-wrap: anywhere;
}

.pill {
    display: inline-block;
    border-radius: 20px;
    padding: 5px 9px;
    font-size: 10px;
    font-weight: 800;
    white-space: nowrap;
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

.event-info {
    color: #7b8499;
    font-size: 13px;
    line-height: 1.9;
}

.card-divider {
    border: 0;
    border-top: 1px solid #edf0f6;
    margin: 18px 0;
}

.registration-info {
    display: flex;
    gap: 15px;
    flex-wrap: wrap;
    margin-bottom: 20px;
}

.registration-box {
    flex: 1;
    min-width: 110px;
    background: #f5f6ff;
    border-radius: 10px;
    padding: 13px;
}

.registration-box small {
    display: block;
    color: #7b8499;
    font-size: 12px;
}

.registration-box strong {
    display: block;
    color: #4f5fe8;
    font-size: 23px;
    margin-top: 5px;
}

.view-btn {
    display: block;
    text-align: center;
    background: linear-gradient(115deg, #4f5fe8, #7b61e8);
    color: white;
}

.view-btn:hover {
    opacity: 0.92;
}

.empty {
    background: white;
    border: 1px solid #e9ecf4;
    border-radius: 14px;
    padding: 45px 20px;
    text-align: center;
    color: #8a93a8;
    grid-column: 1 / -1;
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
    .event-grid {
        grid-template-columns: 1fr;
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

    .event-card {
        padding: 17px;
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

    <!-- Main -->
    <main class="main">

        <header>
            <div>
                <strong>Event Registrations</strong><br>
                <small>Manage registrations for your events</small>
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
                    <h1>Registrations</h1>
                    <div class="muted">
                        Select an event to view its registration details.
                    </div>
                </div>

                <a class="btn back-btn"
                   href="<%= request.getContextPath() %>/admin-dashboard.jsp">
                    ← Back to Dashboard
                </a>

            </div>

            <!-- Event cards -->
            <div class="event-grid">

                <% if (events != null && !events.isEmpty()) {
                    for (Event e : events) {
                %>

                <div class="event-card">

                    <div class="card-top">
                        <h2>
                            <%= e.getTitle() %>
                        </h2>

                        <span class="pill <%= e.getStatus() %>">
                            <%= e.getStatus() %>
                        </span>
                    </div>

                    <div class="event-info">
                        <div>📅 &nbsp; <%= e.getEventDate() %></div>
                        <div>📍 &nbsp; <%= e.getVenue() %></div>
                        <div>🕒 &nbsp; <%= e.getStartTime() %></div>
                        <div>💰 &nbsp; ₹<%= e.getTicketPrice() %></div>
                    </div>

                    <hr class="card-divider">

                    <div class="registration-info">

                        <div class="registration-box">
                            <small>Registrations</small>
                            <strong><%= e.getRegistrationCount() %></strong>
                        </div>

                        <div class="registration-box">
                            <small>Tickets Booked</small>
                            <strong><%= e.getRegisteredTickets() %></strong>
                        </div>

                    </div>

                    <a class="btn view-btn"
                       href="<%= request.getContextPath() %>/admin/registrations/details?eventId=<%= e.getEventId() %>">
                        View Details →
                    </a>

                </div>

                <%  }
                   } else { %>

                    <div class="empty">
                        <h3>No events available</h3>
                        <p>Create an event first to manage its registrations.</p>
                    </div>

                <% } %>

            </div>

        </div>

    </main>

</div>

</body>
</html>
