
<%
    String fullName = (String) session.getAttribute("fullName");
    String role = (String) session.getAttribute("role");

    if (fullName == null || role == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    if ("ADMIN".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/admin-dashboard.jsp");
        return;
    }
%>

<style>
.logo {
    font-size: 27px;
    font-weight: 800;
    letter-spacing: -1px;
    color: #6546e8;
    transition: color 0.2s ease;
}

.nav-links {
    display: flex;
    align-items: center;
    gap: 30px;
    font-size: 15px;
    font-weight: 600;
    color: #656b80;
}

.nav-links a {
    transition: color 0.2s ease;
}

.nav-links a:hover {
    color: #6546e8;
}

.welcome {
    color: #555c73;
    font-size: 14px;
    font-weight: 600;
}

.logout-btn {
    border: 1px solid #e1e3ed;
    padding: 10px 18px;
    border-radius: 10px;
    background: white;
    color: #343951;
    cursor: pointer;
    font-size: 14px;
    font-weight: 700;
    transition: all 0.2s ease;
}

.logout-btn:hover {
    background: #f2efff;
    border-color: #c9bfff;
    color: #6546e8;
}
    .navbar {
        min-height: 76px;
        padding: 16px 7%;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 20px;
        background: #ffffff;
        box-shadow: 0 3px 18px rgba(30, 35, 70, 0.06);
        position: sticky;
        top: 0;
        z-index: 10;
    }

    .logo {
        font-size: 25px;
        font-weight: 800;
        letter-spacing: -1px;
        color: #6546e8;
        text-decoration: none;
    }

    .logo span {
        color: #252943;
    }

    .nav-links {
        display: flex;
        align-items: center;
        gap: 28px;
        font-size: 14px;
        font-weight: 600;
        color: #656b80;
    }

    .nav-links a {
    	font-size: 17px;
        text-decoration: none;
        color: inherit;
    }

    .nav-links a:hover {
        color: #6546e8;
    }

    .nav-actions {
        display: flex;
        align-items: center;
        gap: 14px;
    }

    .welcome {
        color: #555c73;
        font-size: 15px;
    }

    .logout-btn {
        border: 1px solid #e1e3ed;
        padding: 9px 16px;
        border-radius: 10px;
        background: white;
        color: #343951;
        cursor: pointer;
        font-size: 15px;
        font-weight: 700;
    }

    .logout-btn:hover {
        background: #f2efff;
        border-color: #c9bfff;
    }

    @media (max-width: 900px) {
        .navbar {
            flex-wrap: wrap;
        }

        .nav-links {
            order: 3;
            width: 100%;
            justify-content: center;
            flex-wrap: wrap;
            gap: 18px;
        }
    }

    @media (max-width: 560px) {
        .navbar {
            padding: 15px 5%;
        }

        .welcome {
            display: none;
        }

        .nav-links {
            font-size: 13px;
        }
    }
</style>

<nav class="navbar">

    <a class="logo"
       href="${pageContext.request.contextPath}/home.jsp">
        Event<span>ify.</span>
    </a>

    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/home.jsp">Home</a>
        <a href="${pageContext.request.contextPath}/events">Explore Events</a>
        <a href="${pageContext.request.contextPath}/my-bookings">My Bookings</a>
        <a href="${pageContext.request.contextPath}/my-tickets">My Tickets</a>
        <a href="${pageContext.request.contextPath}/profile">My Profile</a>
    </div>

    <div class="nav-actions">
        <span class="welcome">Hi, <%= fullName %></span>

        <form action="${pageContext.request.contextPath}/logout"
              method="post">
            <button class="logout-btn" type="submit">
                Logout
            </button>
        </form>
    </div>

</nav>
