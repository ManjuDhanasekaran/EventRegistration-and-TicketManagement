
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List,eventManagement.model.Event" %>
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

    List<Event> events = (List<Event>) request.getAttribute("events");
    String fullName = String.valueOf(session.getAttribute("fullName"));
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Explore Events | Evently</title>

<style>
* { box-sizing: border-box; }

body {
    margin: 0;
    font-family: "Segoe UI", Arial, sans-serif;
    background: #f6f7fc;
    color: #202944;
}



.hero {
    padding: 53px 6% 45px;
    background: linear-gradient(120deg, #252b57, #554bd9 70%, #8372ef);
    color: white;
}

.hero-inner {
    max-width: 1250px;
    margin: auto;
}

.eyebrow {
    font-size: 12px;
    font-weight: 800;
    letter-spacing: 2px;
    color: #d9d8ff;
    text-transform: uppercase;
}

.hero h1 {
    font-size: clamp(30px, 4vw, 44px);
    margin: 13px 0 12px;
    letter-spacing: -1px;
}

.hero p {
    color: #e2e3ff;
    font-size: 16px;
    margin: 0;
}

.search-box {
    max-width: 650px;
    margin-top: 28px;
    background: white;
    display: flex;
    align-items: center;
    gap: 12px;
    border-radius: 12px;
    padding: 5px 16px;
    box-shadow: 0 10px 30px #161a482b;
}

.search-box span { font-size: 20px; color: #7e87a0; }

.search-box input {
    flex: 1;
    min-width: 0;
    border: 0;
    outline: 0;
    padding: 13px 0;
    font-size: 14px;
    color: #202944;
    background: transparent;
}

.container {
    max-width: 1250px;
    padding: 36px 24px 60px;
    margin: auto;
}

.section-heading {
    display: flex;
    justify-content: space-between;
    align-items: end;
    gap: 16px;
    flex-wrap: wrap;
    margin-bottom: 23px;
}

.section-heading h2 {
    margin: 0 0 7px;
    font-size: 25px;
}
.section-heading p {
    margin: 0;
    color: #858da2;
    font-size: 14px;
}

.count {
    color: #625cf0;
    background: #edecff;
    border-radius: 20px;
    padding: 8px 13px;
    font-size: 12px;
    font-weight: 800;
}

.filters {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
    margin-bottom: 25px;
}

.filter {
    border: 1px solid #e0e3ef;
    background: white;
    color: #69738a;
    border-radius: 24px;
    padding: 10px 16px;
    font-size: 13px;
    cursor: pointer;
    font-weight: 700;
}

.filter.active, .filter:hover {
    background: #625cf0;
    color: white;
    border-color: #625cf0;
}

.event-grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 23px;
}

.event-card {
    overflow: hidden;
    background: white;
    border: 1px solid #e9ebf3;
    border-radius: 15px;
    box-shadow: 0 6px 22px #25325b08;
    transition: transform .2s, box-shadow .2s;
}

.event-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 14px 28px #25325b12;
}

.art {
    height: 135px;
    display: flex;
    justify-content: space-between;
    align-items: start;
    padding: 17px;
    color: white;
    background: linear-gradient(135deg, #4856c9, #9b75ed);
}

.art-1 { background: linear-gradient(135deg, #176b87, #53c6bd); }
.art-2 { background: linear-gradient(135deg, #c05a75, #efb36d); }
.art-3 { background: linear-gradient(135deg, #5447a8, #b07ce0); }
.art-4 { background: linear-gradient(135deg, #2f7557, #9ecf78); }
.art-5 { background: linear-gradient(135deg, #304b8f, #73a5e9); }

.art-icon {
    font-size: 35px;
    filter: drop-shadow(0 4px 8px #0002);
}

.art-label {
    font-size: 11px;
    letter-spacing: 1px;
    text-transform: uppercase;
    font-weight: 800;
    background: #ffffff26;
    border: 1px solid #ffffff42;
    padding: 7px 10px;
    border-radius: 20px;
}

.card-body { padding: 20px; }

.event-title {
    font-size: 18px;
    line-height: 1.4;
    font-weight: 800;
    margin: 0 0 16px;
    color: #252e49;
    overflow-wrap: anywhere;
}

.info {
    display: flex;
    align-items: start;
    gap: 10px;
    color: #788299;
    font-size: 13px;
    margin: 12px 0;
    line-height: 1.5;
}

.info-icon {
    width: 22px;
    flex-shrink: 0;
    color: #625cf0;
    font-size: 15px;
}

.description {
    color: #7a849b;
    font-size: 13px;
    line-height: 1.6;
    min-height: 41px;
    margin: 14px 0;
    overflow-wrap: anywhere;
}

.card-bottom {
    border-top: 1px solid #edf0f6;
    padding-top: 16px;
    margin-top: 17px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 10px;
}

.price {
    color: #252e49;
    font-weight: 800;
    font-size: 21px;
}
.price small {
    display: block;
    font-size: 11px;
    color: #9299ab;
    font-weight: 500;
    margin-top: 3px;
}

.details-btn {
    background: #625cf0;
    color: white;
    border-radius: 8px;
    padding: 11px 14px;
    text-decoration: none;
    font-size: 12px;
    font-weight: 800;
    white-space: nowrap;
}
.details-btn:hover { background: #4d47d2; }

.seats {
    font-size: 12px;
    font-weight: 700;
    color: #188452;
    margin-top: 15px;
}
.seats.full { color: #bd4450; }

.empty {
    display: none;
    text-align: center;
    background: white;
    border: 1px dashed #d9ddec;
    padding: 55px 20px;
    border-radius: 15px;
    color: #7b8499;
    grid-column: 1 / -1;
}
.empty h3 { color: #27314d; }

footer {
    text-align: center;
    color: #939aae;
    padding: 25px;
    font-size: 12px;
    background: white;
    border-top: 1px solid #e9ebf4;
}

@media(max-width: 1000px) {
    .event-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
}

@media(max-width: 650px) {
    
    .hero { padding: 40px 20px; }
    .container { padding: 28px 15px 40px; }
    .event-grid { grid-template-columns: 1fr; }
}
</style>
</head>

<body>
<jsp:include page="navbar.jsp" />

<section class="hero">
    <div class="hero-inner">
        <div class="eyebrow">Discover something new</div>
        <h1>Find your next experience.</h1>
        <p>Explore events, meet people, and make memorable moments.</p>

        <div class="search-box">
            <span>⌕</span>
            <input id="search" type="search"
                   placeholder="Search by event name or venue..."
                   aria-label="Search events">
        </div>
    </div>
</section>

<main class="container">
    <div class="section-heading">
        <div>
            <h2>Explore Events</h2>
            <p>Choose an event that interests you.</p>
        </div>
        <span class="count" id="eventCount">
            <%= events == null ? 0 : events.size() %> EVENTS
        </span>
    </div>

    <div class="filters">
        <button class="filter active" data-filter="all">All Events</button>
        <button class="filter" data-filter="upcoming">Upcoming</button>
        <button class="filter" data-filter="free">Free</button>
        <button class="filter" data-filter="paid">Paid</button>
    </div>

    <div class="event-grid" id="eventGrid">
    <% if (events != null) {
        int index = 0;
        for (Event e : events) {
            String desc = e.getDescription() == null
                    ? "" : e.getDescription();
            if (desc.length() > 105) {
                desc = desc.substring(0, 102) + "...";
            }

            String dateText = e.getEventDate();
            String timeText = e.getStartTimeInput();
            int artNumber = index++ % 6;
    %>
        <article class="event-card"
                 data-title="<%= esc(e.getTitle().toLowerCase()) %>"
                 data-venue="<%= esc(e.getVenue().toLowerCase()) %>"
                 data-price="<%= e.getTicketPrice() %>"
                 data-date="<%= esc(dateText) %>">

            <div class="art art-<%= artNumber %>">
                <span class="art-label">Featured event</span>
                <span class="art-icon">
                    <%= new String[] {"✦", "⌘", "♫", "◎", "✧", "◆"}[artNumber] %>
                </span>
            </div>

            <div class="card-body">
                <h3 class="event-title"><%= esc(e.getTitle()) %></h3>

                <div class="info">
                    <span class="info-icon">▦</span>
                    <span><%= esc(dateText) %> · <%= esc(timeText) %></span>
                </div>

                <div class="info">
                    <span class="info-icon">⌖</span>
                    <span><%= esc(e.getVenue()) %></span>
                </div>

                <p class="description"><%= esc(desc) %></p>

                <% if (e.getAvailableSeats() <= 0) { %>
                    <div class="seats full">Currently fully booked</div>
                <% } else { %>
                    <div class="seats">
                        <%= e.getAvailableSeats() %> seats available
                    </div>
                <% } %>

                <div class="card-bottom">
                    <div class="price">
                        <%= e.getTicketPrice() == 0
                                ? "Free"
                                : "₹" + String.format("%.2f", e.getTicketPrice()) %>
                        <small>per ticket</small>
                    </div>

                    <a class="details-btn"
                       href="<%= request.getContextPath() %>/event-details?id=<%= e.getEventId() %>">
                        View Details →
                    </a>
                </div>
            </div>
        </article>
    <%  }
       } %>

        <div class="empty" id="emptyState">
            <div style="font-size:36px">⌕</div>
            <h3>No events found</h3>
            <p>Try a different search or filter.</p>
        </div>
    </div>
</main>

<footer>Evently · Discover events and create memories.</footer>

<script>
    const searchInput = document.getElementById("search");
    const cards = [...document.querySelectorAll(".event-card")];
    const filterButtons = [...document.querySelectorAll(".filter")];
    const emptyState = document.getElementById("emptyState");
    const eventCount = document.getElementById("eventCount");

    let currentFilter = "all";

    function updateEvents() {
        const query = searchInput.value.trim().toLowerCase();
        let visibleCount = 0;
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        cards.forEach(card => {
            const matchesSearch =
                card.dataset.title.includes(query) ||
                card.dataset.venue.includes(query);

            const price = Number(card.dataset.price);
            const date = new Date(card.dataset.date + "T00:00:00");

            let matchesFilter = true;

            if (currentFilter === "free") {
                matchesFilter = price === 0;
            } else if (currentFilter === "paid") {
                matchesFilter = price > 0;
            } else if (currentFilter === "upcoming") {
                matchesFilter = date >= today;
            }

            const show = matchesSearch && matchesFilter;
            card.style.display = show ? "" : "none";

            if (show) visibleCount++;
        });

        emptyState.style.display = visibleCount === 0 ? "block" : "none";
        eventCount.textContent = visibleCount + " EVENTS";
    }

    searchInput.addEventListener("input", updateEvents);

    filterButtons.forEach(button => {
        button.addEventListener("click", () => {
            currentFilter = button.dataset.filter;

            filterButtons.forEach(b => b.classList.remove("active"));
            button.classList.add("active");

            updateEvents();
        });
    });

    updateEvents();
</script>
</body>
</html>
