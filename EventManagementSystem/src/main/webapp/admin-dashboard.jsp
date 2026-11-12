
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List,eventManagement.model.Event,eventManagement.dao.EventDAO" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    if (!"ADMIN".equals(session.getAttribute("role"))) {
        response.sendError(403, "Access denied");
        return;
    }

    List<Event> events = null;
    String loadError = null;
    int total = 0, published = 0, drafts = 0, cancelled = 0;

    try {
        events = new EventDAO().findAll();
        total = events.size();

        for (Event e : events) {
            if ("PUBLISHED".equals(e.getStatus())) published++;
            if ("DRAFT".equals(e.getStatus())) drafts++;
            if ("CANCELLED".equals(e.getStatus())) cancelled++;
        }
    } catch (Exception ex) {
        application.log("Unable to load dashboard event counts", ex);
        loadError = "Event statistics are temporarily unavailable.";
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Admin Dashboard | Evently</title>
<style>
    * { box-sizing: border-box; }
    body {
        margin: 0; font-family: "Segoe UI", Arial, sans-serif;
        background: #f4f6fb; color: #1d2742;
    }
    .layout { display: flex; min-height: 100vh; }
    aside {
        width: 245px; background: #17213c;
        padding: 28px 17px; color: white; flex-shrink: 0;
    }
    .brand {
        font-size: 24px; font-weight: 800;
        padding: 0 13px 35px;
    }
    .brand span { color: #8c9eff; }
    .label {
        color: #8f9ab5; font-size: 11px;
        letter-spacing: 1.5px; padding: 10px 13px;
    }
    nav a {
        display: block; text-decoration: none;
        padding: 14px 13px; border-radius: 9px;
        color: #c5cde0; margin: 5px 0; font-size: 14px;
    }
    nav a.active, nav a:hover {
        background: #303d61; color: white;
    }
    .main { flex: 1; min-width: 0; }
    header {
        height: 76px; background: white;
        display: flex; justify-content: space-between;
        align-items: center; padding: 0 34px;
        border-bottom: 1px solid #e8ebf3;
    }
    header small { color: #7c879e; }
    .avatar {
        background: #e9edff; color: #3949ab;
        border-radius: 50%; width: 40px; height: 40px;
        display: grid; place-items: center; font-weight: bold;
    }
    .content { padding: 32px 34px; max-width: 1400px; margin: auto; }
    h1 { margin: 0 0 8px; font-size: 28px; }
    .muted { color: #7b8499; font-size: 14px; }
    .welcome {
        background: linear-gradient(115deg, #4f5fe8, #7b61e8);
        border-radius: 17px; color: white; padding: 28px 30px;
        margin: 25px 0;
        display: flex; justify-content: space-between;
        align-items: center; gap: 20px; flex-wrap: wrap;
    }
    .welcome h2 { margin: 0 0 8px; font-size: 23px; }
    .welcome p { margin: 0; color: #e4e7ff; font-size: 14px; }
    .btn {
        display: inline-block; text-decoration: none;
        padding: 12px 17px; border-radius: 8px;
        font-weight: 700; font-size: 13px;
    }
    .white-btn { background: white; color: #4f5fe8; }
    .stats {
        display: grid;
        grid-template-columns: repeat(4, minmax(0, 1fr));
        gap: 17px; margin-bottom: 25px;
    }
    .stat {
        background: white; border: 1px solid #e9ecf4;
        border-radius: 14px; padding: 21px;
        box-shadow: 0 5px 18px #27365b08;
    }
    .stat-top {
        display: flex; justify-content: space-between;
        align-items: center; gap: 8px;
    }
    .stat-name { color: #78839a; font-size: 13px; }
    .stat-icon {
        width: 38px; height: 38px; border-radius: 10px;
        display: grid; place-items: center;
        background: #edf0ff; color: #4f5fe8;
    }
    .stat h2 { margin: 16px 0 5px; font-size: 29px; }
    .stat small { color: #8992a6; font-size: 12px; }
    .section {
        background: white; border: 1px solid #e9ecf4;
        border-radius: 14px; padding: 24px;
    }
    .section-head {
        display: flex; justify-content: space-between;
        align-items: center; gap: 12px; flex-wrap: wrap;
        margin-bottom: 20px;
    }
    .section h2 { margin: 0 0 5px; font-size: 18px; }
    .outline {
        border: 1px solid #dce1ec; color: #45516b;
        background: white;
    }
    table { width: 100%; border-collapse: collapse; font-size: 13px; }
    th {
        text-align: left; background: #f8f9fc;
        padding: 13px; color: #818ba1;
        text-transform: uppercase; font-size: 11px;
    }
    td { padding: 15px 13px; border-bottom: 1px solid #edf0f6; }
    .pill {
        display: inline-block; border-radius: 20px;
        padding: 5px 9px; font-size: 10px; font-weight: 800;
    }
    .PUBLISHED { background: #e4f8ec; color: #16834b; }
    .DRAFT { background: #eef1f7; color: #65718b; }
    .CANCELLED { background: #ffebed; color: #c2394b; }
    .COMPLETED { background: #e9e9ff; color: #5551b5; }
    .empty { text-align: center; color: #8a93a8; padding: 30px; }
    
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
        .stats { grid-template-columns: repeat(2, minmax(0, 1fr)); }
    }
    @media(max-width: 650px) {
        aside { width: 68px; padding: 20px 7px; }
        .brand { font-size: 0; padding: 5px 10px 30px; }
        .brand span { font-size: 22px; }
        .label { display: none; }
        nav a { font-size: 0; text-align: center; padding: 14px 4px; }
        nav a::first-letter { font-size: 17px; }
        header { padding: 0 14px; }
        .content { padding: 22px 14px; }
        .stats { gap: 10px; }
        .stat { padding: 14px; }
        .stat h2 { font-size: 24px; }
        .section { padding: 14px; }
    }
</style>
</head>
<body>
<div class="layout">
    <aside>
        <div class="brand">event<span>ly.</span></div>
        <div class="label">WORKSPACE</div>
        <nav>
            <a class="active" href="<%= request.getContextPath() %>/admin-dashboard.jsp">▦ &nbsp; Dashboard</a>
            <a href="<%= request.getContextPath() %>/admin/events">▣ &nbsp; Manage Events</a>
            <a href="<%= request.getContextPath() %>/admin/registrations"> ♧ &nbsp; Registrations</a>
            
        </nav>
    </aside>

    <main class="main">
        <header>
            <div>
                <strong>Admin Dashboard</strong><br>
                <small>Your event management overview</small>
            </div>
          <!--  <div style="display:flex;align-items:center;gap:12px">
                <div class="avatar">A</div>
                <div>
                    <strong style="font-size:13px"><%= String.valueOf(session.getAttribute("fullName")) %></strong><br>
                    <small>Administrator</small>
                </div>
            </div>-->
            
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
            <h1>Dashboard Overview</h1>
            <div class="muted">Here's what's happening with your events.</div>

            <section class="welcome">
                <div>
                    <h2>Let's make your next event amazing!</h2>
                    <p>Create events, manage schedules, and prepare for registrations.</p>
                </div>
                <a class="btn white-btn"
                   href="<%= request.getContextPath() %>/admin/events">+ Create New Event</a>
            </section>

            <% if (loadError != null) { %>
                <p class="muted"><%= loadError %></p>
            <% } %>

            <section class="stats">
                <div class="stat">
                    <div class="stat-top">
                        <span class="stat-name">Total Events</span>
                        <span class="stat-icon">▦</span>
                    </div>
                    <h2><%= total %></h2>
                    <small>All event records</small>
                </div>
                <div class="stat">
                    <div class="stat-top">
                        <span class="stat-name">Published</span>
                        <span class="stat-icon">✓</span>
                    </div>
                    <h2><%= published %></h2>
                    <small>Visible for registration when eligible</small>
                </div>
                <div class="stat">
                    <div class="stat-top">
                        <span class="stat-name">Drafts</span>
                        <span class="stat-icon">✎</span>
                    </div>
                    <h2><%= drafts %></h2>
                    <small>Still being prepared</small>
                </div>
                <div class="stat">
                    <div class="stat-top">
                        <span class="stat-name">Cancelled</span>
                        <span class="stat-icon">×</span>
                    </div>
                    <h2><%= cancelled %></h2>
                    <small>Events marked as cancelled</small>
                </div>
            </section>

            <section class="section">
                <div class="section-head">
                    <div>
                        <h2>Recent Events</h2>
                        <div class="muted">Your latest event records</div>
                    </div>
                    <a class="btn outline"
                       href="<%= request.getContextPath() %>/admin/events">View All Events →</a>
                </div>

                <div style="overflow-x:auto">
                    <table>
                        <thead>
                            <tr>
                                <th>Event Name</th>
                                <th>Date</th>
                                <th>Venue</th>
                                <th>Price</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% if (events != null && !events.isEmpty()) {
                            int count = 0;
                            for (Event e : events) {
                                if (count++ == 5) break;
                        %>
                            <tr>
                                <td><strong><%= e.getTitle().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;") %></strong></td>
                                <td><%= e.getEventDate() %></td>
                                <td><%= e.getVenue().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;") %></td>
                                <td>₹<%= String.format("%.2f", e.getTicketPrice()) %></td>
                                <td><span class="pill <%= e.getStatus() %>"><%= e.getStatus() %></span></td>
                            </tr>
                        <%  }
                           } else { %>
                            <tr><td colspan="5" class="empty">No events created yet. Start by creating your first event.</td></tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </section>
        </div>
    </main>
</div>
</body>
</html>
