
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
    if (!"ADMIN".equals(session.getAttribute("role"))) {
        response.sendError(403, "Access denied");
        return;
    }

    Event edit = (Event) request.getAttribute("eventToEdit");
    List<Event> events = (List<Event>) request.getAttribute("events");
    String message = (String) request.getAttribute("message");
    boolean editing = edit != null;
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Manage Events | Evently Admin</title>
<style>
    * { box-sizing: border-box; }
    body {
        margin: 0;
        font-family: "Segoe UI", Arial, sans-serif;
        background: #f4f6fb;
        color: #1d2742;
    }
    .layout { display: flex; min-height: 100vh; }
    .sidebar {
        width: 245px;
        flex-shrink: 0;
        background: #17213c;
        color: white;
        padding: 28px 17px;
    }
    .brand {
        font-size: 23px;
        font-weight: 800;
        padding: 0 13px 34px;
        letter-spacing: -.5px;
    }
    .brand span { color: #8c9eff; }
    .nav-label {
        color: #8f9ab5;
        font-size: 11px;
        letter-spacing: 1.5px;
        padding: 10px 13px;
    }
    .nav a {
        display: block;
        color: #c5cde0;
        text-decoration: none;
        padding: 13px;
        border-radius: 9px;
        margin: 5px 0;
        font-size: 14px;
    }
    .nav a:hover, .nav a.active {
        background: #303d61;
        color: white;
    }
    .nav a.active { box-shadow: inset 3px 0 #8c9eff; }
    .side-bottom {
        margin-top: 40px;
        padding: 12px;
        color: #aeb9d1;
        font-size: 13px;
        border-top: 1px solid #35415e;
    }
    .main { flex: 1; min-width: 0; }
    .topbar {
        height: 76px;
        background: white;
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 0 34px;
        border-bottom: 1px solid #e8ebf3;
    }
    .topbar small { color: #7c879e; }
    .profile {
        background: #e9edff;
        color: #3949ab;
        border-radius: 50%;
        width: 39px; height: 39px;
        display: grid; place-items: center;
        font-weight: bold;
    }
    .content { padding: 30px 34px 45px; max-width: 1500px; margin: auto; }
    .heading {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 15px;
        flex-wrap: wrap;
        margin-bottom: 24px;
    }
    h1 { margin: 0 0 7px; font-size: 27px; }
    .muted { color: #7b8499; font-size: 14px; }
    .btn {
        display: inline-block;
        border: 0;
        border-radius: 8px;
        padding: 11px 16px;
        font-weight: 600;
        font-size: 13px;
        text-decoration: none;
        cursor: pointer;
    }
    .primary { background: #4f5fe8; color: white; }
    .primary:hover { background: #3d4bd0; }
    .secondary { background: #edf0f8; color: #3b4660; }
    .danger { background: #fff0f0; color: #c43c4a; }
    .grid {
        display: grid;
        grid-template-columns: minmax(300px, .85fr) minmax(430px, 1.5fr);
        gap: 22px;
        align-items: start;
    }
    .card {
        background: white;
        border: 1px solid #e9ecf4;
        border-radius: 15px;
        padding: 23px;
        box-shadow: 0 5px 18px #27365b08;
        min-width: 0;
    }
    .card h2 { font-size: 18px; margin: 0 0 5px; }
    .card-sub { color: #8992a6; font-size: 13px; margin-bottom: 22px; }
    .field { margin-bottom: 15px; }
    label {
        display: block;
        font-size: 12px;
        font-weight: 700;
        margin-bottom: 7px;
        color: #4d5871;
    }
    input, textarea, select {
        width: 100%;
        padding: 11px 12px;
        border: 1px solid #dce1ec;
        border-radius: 8px;
        font: inherit;
        font-size: 13px;
        background: #fff;
        color: #27334e;
    }
    input:focus, textarea:focus, select:focus {
        outline: 2px solid #dce0ff;
        border-color: #6875ef;
    }
    textarea { min-height: 76px; resize: vertical; }
    .two { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
    .form-actions { display: flex; gap: 9px; margin-top: 20px; }
    .form-actions .btn { flex: 1; text-align: center; }
    .alert {
        padding: 12px 15px; border-radius: 9px;
        background: #fff0f0; color: #b42332;
        margin-bottom: 20px; font-size: 14px;
    }
    .success {
        background: #e8f8ef; color: #177245;
        padding: 12px 15px; border-radius: 9px;
        margin-bottom: 20px; font-size: 14px;
    }
    .table-head {
        display: flex; justify-content: space-between;
        align-items: center; gap: 12px; margin-bottom: 18px;
        flex-wrap: wrap;
    }
    .search { max-width: 230px; }
    .table-wrap { overflow-x: auto; }
    table { width: 100%; border-collapse: collapse; font-size: 13px; }
    th {
        text-align: left; padding: 13px 11px;
        color: #818ba1; font-size: 11px;
        text-transform: uppercase; letter-spacing: .5px;
        background: #f8f9fc; white-space: nowrap;
    }
    td {
        padding: 15px 11px; border-bottom: 1px solid #edf0f6;
        vertical-align: middle;
    }
    tbody tr:hover { background: #fafbff; }
    .event-title { font-weight: 700; color: #26324c; min-width: 130px; }
    .event-date { color: #78839a; font-size: 12px; margin-top: 5px; }
    .pill {
        display: inline-block; padding: 5px 9px;
        border-radius: 20px; font-size: 10px;
        font-weight: 800; letter-spacing: .3px;
    }
    .DRAFT { background: #eef1f7; color: #65718b; }
    .PUBLISHED { background: #e4f8ec; color: #16834b; }
    .CANCELLED { background: #ffebed; color: #c2394b; }
    .COMPLETED { background: #e9e9ff; color: #5551b5; }
    .actions { display: flex; gap: 6px; align-items: center; flex-wrap: wrap; }
    .actions .btn { padding: 7px 9px; font-size: 11px; }
    .status-form { display: flex; gap: 5px; margin-top: 7px; }
    .status-form select { width: auto; min-width: 100px; padding: 6px; font-size: 11px; }
    .status-form button { padding: 6px 8px; }
    .empty { text-align: center; color: #8a93a8; padding: 35px 10px; }
    .bottom-note { color: #98a0b1; font-size: 12px; margin-top: 20px; }
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
    @media (max-width: 1100px) {
        .grid { grid-template-columns: 1fr; }
    }
    @media (max-width: 680px) {
        .sidebar { width: 68px; padding: 20px 8px; }
        .brand { font-size: 0; padding: 5px 10px 30px; }
        .brand span { font-size: 22px; }
        .nav-label, .nav .nav-text, .side-bottom { display: none; }
        .nav a { text-align: center; font-size: 0; padding: 14px 4px; }
        .nav a::first-letter { font-size: 16px; }
        .topbar { padding: 0 16px; }
        .content { padding: 22px 14px; }
        .card { padding: 17px; }
        .two { grid-template-columns: 1fr; gap: 0; }
    }
</style>
</head>
<body>
<div class="layout">
    <aside class="sidebar">
        <div class="brand">event<span>ly.</span></div>
        <div class="nav-label">WORKSPACE</div>
        <nav class="nav">
            <a href="<%= request.getContextPath() %>/admin-dashboard.jsp">▦ &nbsp; <span class="nav-text">Dashboard</span></a>
            <a class="active" href="<%= request.getContextPath() %>/admin/events">▣ &nbsp; <span class="nav-text">Manage Events</span></a>
            <a href="<%= request.getContextPath() %>/admin/registrations"> ♧ &nbsp; Registrations</a>
        </nav>
        <div class="side-bottom">Evently Admin<br><br>Manage your events with ease.</div>
    </aside>

    <main class="main">
        <header class="topbar">
            <div>
                <strong>Event Management</strong><br>
                <small>Admin workspace / Events</small>
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

        <section class="content">
            <div class="heading">
                <div>
                    <h1>Manage Events</h1>
                    <div class="muted">Create, organize, and keep track of your events.</div>
                </div>
                <a class="btn primary" href="<%= request.getContextPath() %>/admin/events">+ New Event</a>
            </div>

            <% if (message != null) { %>
                <div class="alert"><%= esc(message) %></div>
            <% } %>
            <% if ("1".equals(request.getParameter("success"))) { %>
                <div class="success">✓ Changes saved successfully.</div>
            <% } %>

            <div class="grid">
                <section class="card">
                    <h2><%= editing ? "Edit Event" : "Create New Event" %></h2>
                    <div class="card-sub">
                        <%= editing ? "Update the details below." : "Add an event to your schedule." %>
                    </div>

                    <form action="<%= request.getContextPath() %>/admin/events"
                          method="post">
                        <input type="hidden" name="action" value="save">
                        <% if (editing) { %>
                            <input type="hidden" name="eventId" value="<%= edit.getEventId() %>">
                        <% } %>

                        <div class="field">
                            <label>EVENT TITLE *</label>
                            <input name="title" required minlength="3" maxlength="150"
                                   placeholder="e.g. Java Developer Meetup"
                                   value="<%= editing ? esc(edit.getTitle()) : "" %>">
                        </div>

                        <div class="field">
                            <label>DESCRIPTION</label>
                            <textarea name="description" maxlength="5000"
                                      placeholder="What is this event about?"><%= editing ? esc(edit.getDescription()) : "" %></textarea>
                        </div>

                        <div class="field">
                            <label>VENUE *</label>
                            <input name="venue" required maxlength="200"
                                   placeholder="Event venue or location"
                                   value="<%= editing ? esc(edit.getVenue()) : "" %>">
                        </div>

                        <div class="field">
                            <label>EVENT DATE *</label>
                            <input type="date" name="eventDate" required
                                   value="<%= editing ? esc(edit.getEventDate()) : "" %>">
                        </div>

                        <div class="two">
                            <div class="field">
                                <label>START TIME *</label>
                                <input type="time" name="startTime" required
                                       value="<%= editing ? esc(edit.getStartTimeInput()) : "" %>">
                            </div>
                            <div class="field">
                                <label>END TIME *</label>
                                <input type="time" name="endTime" required
                                       value="<%= editing ? esc(edit.getEndTimeInput()) : "" %>">
                            </div>
                        </div>

                        <div class="two">
                            <div class="field">
                                <label>TICKET PRICE (₹) *</label>
                                <input type="number" name="ticketPrice" required
                                       min="0" step="0.01" placeholder="499.00"
                                       value="<%= editing ? edit.getTicketPrice() : "" %>">
                            </div>
                            <div class="field">
                                <label>TOTAL SEATS *</label>
                                <input type="number" name="totalSeats" required
                                       min="1" step="1" placeholder="100"
                                       value="<%= editing ? edit.getTotalSeats() : "" %>">
                            </div>
                        </div>

                        <div class="field">
                            <label>REGISTRATION DEADLINE *</label>
                            <input type="datetime-local" name="registrationDeadline" required
                                   value="<%= editing ? esc(edit.getDeadlineInput()) : "" %>">
                        </div>

                        <div class="field">
                            <label>EVENT STATUS *</label>
                            <select name="status" required>
                                <option value="DRAFT" <%= editing && "DRAFT".equals(edit.getStatus()) ? "selected" : "" %>>Draft</option>
                                <option value="PUBLISHED" <%= editing && "PUBLISHED".equals(edit.getStatus()) ? "selected" : "" %>>Published</option>
                                <option value="CANCELLED" <%= editing && "CANCELLED".equals(edit.getStatus()) ? "selected" : "" %>>Cancelled</option>
                                <option value="COMPLETED" <%= editing && "COMPLETED".equals(edit.getStatus()) ? "selected" : "" %>>Completed</option>
                            </select>
                        </div>

                        <div class="form-actions">
                            <button class="btn primary" type="submit">
                                <%= editing ? "Save Changes" : "Create Event" %>
                            </button>
                            <% if (editing) { %>
                                <a class="btn secondary" href="<%= request.getContextPath() %>/admin/events">Cancel</a>
                            <% } else { %>
                                <button class="btn secondary" type="reset">Clear</button>
                            <% } %>
                        </div>
                    </form>
                </section>

                <section class="card">
                    <div class="table-head">
                        <div>
                            <h2>All Events</h2>
                            <div class="card-sub" style="margin:5px 0 0">
                                Review and update your event listings.
                            </div>
                        </div>
                        <input id="search" class="search" type="search"
                               placeholder="Search events...">
                    </div>

                    <div class="table-wrap">
                        <table id="eventsTable">
                            <thead>
                                <tr>
                                    <th>Event</th>
                                    <th>Price</th>
                                    <th>Seats</th>
                                    <th>Status</th>
                                    <th>Manage</th>
                                </tr>
                            </thead>
                            <tbody>
                            <% if (events != null && !events.isEmpty()) {
                                for (Event e : events) { %>
                                <tr>
                                    <td>
                                        <div class="event-title"><%= esc(e.getTitle()) %></div>
                                        <div class="event-date">
                                            <%= esc(e.getEventDate()) %> · <%= esc(e.getVenue()) %>
                                        </div>
                                    </td>
                                    <td>₹<%= String.format("%.2f", e.getTicketPrice()) %></td>
                                    <td><%= e.getTotalSeats() %></td>
                                    <td><span class="pill <%= esc(e.getStatus()) %>"><%= esc(e.getStatus()) %></span></td>
                                    <td>
                                        <div class="actions">
                                            <a class="btn secondary"
                                               href="<%= request.getContextPath() %>/admin/events?action=edit&id=<%= e.getEventId() %>">Edit</a>
                                        </div>
                                        <form class="status-form"
                                              action="<%= request.getContextPath() %>/admin/events"
                                              method="post">
                                            <input type="hidden" name="action" value="status">
                                            <input type="hidden" name="eventId" value="<%= e.getEventId() %>">
                                            <select name="status" aria-label="Change event status">
                                                <option value="DRAFT" <%= "DRAFT".equals(e.getStatus()) ? "selected" : "" %>>Draft</option>
                                                <option value="PUBLISHED" <%= "PUBLISHED".equals(e.getStatus()) ? "selected" : "" %>>Publish</option>
                                                <option value="CANCELLED" <%= "CANCELLED".equals(e.getStatus()) ? "selected" : "" %>>Cancel</option>
                                                <option value="COMPLETED" <%= "COMPLETED".equals(e.getStatus()) ? "selected" : "" %>>Complete</option>
                                            </select>
                                            <button class="btn primary" type="submit">Save</button>
                                        </form>
                                    </td>
                                </tr>
                            <%  }
                               } else { %>
                                <tr>
                                    <td colspan="5" class="empty">
                                        No events yet. Create your first event using the form.
                                    </td>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                    <div class="bottom-note">Tip: Save events as Draft while preparing them. Publish them when they're ready for registration.</div>
                </section>
            </div>
        </section>
    </main>
</div>

<script>
    const searchInput = document.getElementById("search");
    searchInput.addEventListener("input", function () {
        const query = this.value.toLowerCase();
        document.querySelectorAll("#eventsTable tbody tr").forEach(row => {
            row.style.display =
                row.innerText.toLowerCase().includes(query) ? "" : "none";
        });
    });
</script>
</body>
</html>
