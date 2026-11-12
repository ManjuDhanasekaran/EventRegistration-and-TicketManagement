
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="eventManagement.model.Event" %>
<%!
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    if (!"USER".equals(session.getAttribute("role"))) {
        response.sendError(403, "Access denied");
        return;
    }

    Event event = (Event) request.getAttribute("event");

    if (event == null) {
        response.sendError(404, "Event not found");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><%= esc(event.getTitle()) %> | Evently</title>

<style>
* { box-sizing: border-box; }

body {
    margin: 0;
    font-family: "Segoe UI", Arial, sans-serif;
    color: #202944;
    background: #f5f6fc;
}

nav {
    height: 75px;
    background: white;
    border-bottom: 1px solid #e7eaf3;
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0 6%;
    gap: 15px;
}

.brand {
    font-size: 25px;
    font-weight: 800;
    color: #202944;
    text-decoration: none;
}
.brand span { color: #625cf0; }

.back {
    color: #625cf0;
    text-decoration: none;
    font-weight: 700;
    font-size: 14px;
}

.banner {
    min-height: 240px;
    padding: 45px 7%;
    display: flex;
    align-items: center;
    color: white;
    background: linear-gradient(120deg, #252b57, #554bd9, #8a76ed);
}

.banner-inner { max-width: 1100px; width: 100%; margin: auto; }

.tag {
    display: inline-block;
    background: #ffffff25;
    border: 1px solid #ffffff48;
    border-radius: 30px;
    padding: 8px 12px;
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 1px;
    font-weight: 800;
}

h1 {
    font-size: clamp(30px, 4vw, 44px);
    line-height: 1.2;
    margin: 20px 0 12px;
    overflow-wrap: anywhere;
}

.banner p { color: #e4e4ff; margin: 0; }

.container {
    max-width: 1100px;
    padding: 35px 20px 60px;
    margin: auto;
}

.layout {
    display: grid;
    grid-template-columns: minmax(0, 1.6fr) minmax(270px, .8fr);
    gap: 24px;
    align-items: start;
}

.card {
    background: white;
    border: 1px solid #e8eaf3;
    border-radius: 15px;
    padding: 27px;
    box-shadow: 0 7px 22px #25325b08;
}

h2 { font-size: 20px; margin: 0 0 17px; }

.description {
    color: #69748b;
    line-height: 1.9;
    font-size: 15px;
    overflow-wrap: anywhere;
    white-space: pre-wrap;
}

.detail {
    display: flex;
    align-items: start;
    gap: 13px;
    padding: 15px 0;
    border-bottom: 1px solid #edf0f6;
}

.detail:last-child { border-bottom: 0; }

.icon {
    background: #efeeff;
    color: #625cf0;
    width: 39px;
    height: 39px;
    border-radius: 10px;
    display: grid;
    place-items: center;
    flex-shrink: 0;
    font-size: 18px;
}

.detail small {
    display: block;
    color: #8a93a7;
    font-size: 12px;
    margin-bottom: 5px;
}

.detail strong { font-size: 14px; overflow-wrap: anywhere; }

.price {
    font-size: 29px;
    font-weight: 800;
    margin: 10px 0;
}

.price small {
    font-size: 12px;
    font-weight: 500;
    color: #8a93a7;
}

.seats {
    background: #e9f8ef;
    color: #188452;
    padding: 12px;
    border-radius: 8px;
    font-size: 13px;
    margin: 18px 0;
    font-weight: 700;
}

.seats.full {
    background: #fff0f0;
    color: #bd4450;
}

.book-btn {
    display: block;
    width: 100%;
    text-align: center;
    padding: 14px;
    background: #625cf0;
    color: white;
    border-radius: 9px;
    text-decoration: none;
    font-weight: 800;
    border: 0;
    cursor: pointer;
}

.book-btn.disabled {
    background: #e4e6ef;
    color: #858ca0;
    cursor: not-allowed;
}

.note {
    font-size: 12px;
    color: #9098aa;
    line-height: 1.6;
    margin-top: 15px;
    text-align: center;
}

@media(max-width: 720px) {
    nav { padding: 0 17px; }
    .banner { padding: 35px 22px; }
    .container { padding: 22px 14px 40px; }
    .layout { grid-template-columns: 1fr; }
    .card { padding: 21px; }
}
</style>
</head>

<body>
<nav>
    <a class="brand" href="<%= request.getContextPath() %>/home.jsp">
        event<span>ly.</span>
    </a>
    <a class="back" href="<%= request.getContextPath() %>/events">
        ← Back to Events
    </a>
</nav>

<section class="banner">
    <div class="banner-inner">
        <span class="tag">Event details</span>
        <h1><%= esc(event.getTitle()) %></h1>
        <p>Discover the details and plan your experience.</p>
    </div>
</section>

<main class="container">
    <div class="layout">
        <section class="card">
            <h2>About this event</h2>

            <div class="description"><%= event.getDescription() == null || event.getDescription().isBlank()
                    ? "More information about this event will be available soon."
                    : esc(event.getDescription()) %></div>

            <br>

            <h2>Event information</h2>

            <div class="detail">
                <div class="icon">▦</div>
                <div>
                    <small>Date</small>
                    <strong><%= esc(event.getEventDate()) %></strong>
                </div>
            </div>

            <div class="detail">
                <div class="icon">◷</div>
                <div>
                    <small>Time</small>
                    <strong><%= esc(event.getStartTimeInput()) %>
                        – <%= esc(event.getEndTimeInput()) %></strong>
                </div>
            </div>

            <div class="detail">
                <div class="icon">⌖</div>
                <div>
                    <small>Venue</small>
                    <strong><%= esc(event.getVenue()) %></strong>
                </div>
            </div>

            <div class="detail">
                <div class="icon">◷</div>
                <div>
                    <small>Registration deadline</small>
                    <strong><%= esc(event.getDeadlineInput().replace("T", " ")) %></strong>
                </div>
            </div>
        </section>

        <aside class="card">
            <h2>Your event pass</h2>

            <div class="price">
                <%= event.getTicketPrice() == 0
                        ? "Free"
                        : "₹" + String.format("%.2f", event.getTicketPrice()) %>
                <small>/ ticket</small>
            </div>

            <% if (event.getAvailableSeats() <= 0) { %>
                <div class="seats full">This event is currently fully booked.</div>
                <button class="book-btn disabled" disabled>Fully Booked</button>
            <% } else { %>
                <div class="seats">
                    <%= event.getAvailableSeats() %> seats currently available
                </div>
                <% if (event.getAvailableSeats() > 0) { %>

    <form action="${pageContext.request.contextPath}/create-booking"
          method="post">

        <input type="hidden" name="eventId"
               value="<%= event.getEventId() %>">

        <label for="quantity">Number of tickets</label>

        <select name="quantity" id="quantity" required>
            <% for (int i = 1;
                    i <= Math.min(10, event.getAvailableSeats());
                    i++) { %>
                <option value="<%= i %>">
                    <%= i %> ticket(s)
                </option>
            <% } %>
        </select>

        <p>
            Price per ticket: ₹<%= event.getTicketPrice() %>
        </p>

        <button type="submit">Continue to Payment</button>
    </form>

<% } else { %>

    <p>Sorry, this event is fully booked.</p>

<% } %>
            <% } %>

            <p class="note">
                Availability may change before you complete a booking.
                The booking process will be added in the next module.
            </p>
        </aside>
    </div>
</main>
</body>
</html>
