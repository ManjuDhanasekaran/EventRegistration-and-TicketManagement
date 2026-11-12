
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="eventManagement.model.UserProfile" %>

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
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(
            request.getContextPath() + "/login.jsp"
        );
        return;
    }

    UserProfile profile =
        (UserProfile) request.getAttribute("profile");

    if (profile == null) {
        response.sendRedirect(
            request.getContextPath() + "/profile"
        );
        return;
    }

    String contextPath = request.getContextPath();
    String message = (String) request.getAttribute("message");
    String error = (String) request.getAttribute("error");

    String initial = profile.getFullName() == null
        || profile.getFullName().trim().isEmpty()
        ? "U"
        : profile.getFullName().trim().substring(0, 1).toUpperCase();
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>My Profile | Eventify</title>

<style>
    * {
        box-sizing: border-box;
    }

    body {
        margin: 0;
        font-family: Arial, Helvetica, sans-serif;
        background: #f4f6fb;
        color: #20263a;
    }

    
    .page {
        max-width: 1050px;
        margin: 45px auto;
        padding: 0 20px;
    }

    .heading {
        margin-bottom: 26px;
    }

    .heading h1 {
        margin: 0 0 9px;
        font-size: 30px;
    }

    .heading p {
        margin: 0;
        color: #777e93;
        line-height: 1.6;
    }

    .profile-layout {
        display: grid;
        grid-template-columns: 280px 1fr;
        gap: 25px;
        align-items: start;
    }

    .card {
        background: #fff;
        border-radius: 17px;
        padding: 30px;
        box-shadow: 0 8px 30px rgba(30, 40, 80, .06);
    }

    .profile-summary {
        text-align: center;
    }

    .avatar {
        width: 90px;
        height: 90px;
        margin: 0 auto 18px;
        border-radius: 50%;
        background: #e9e7ff;
        color: #635bdb;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 36px;
        font-weight: 800;
    }

    .profile-summary h2 {
        margin: 0 0 9px;
        font-size: 20px;
        overflow-wrap: anywhere;
    }

    .profile-summary p {
        margin: 0;
        color: #777e93;
        font-size: 14px;
        overflow-wrap: anywhere;
    }

    .account-label {
        display: inline-block;
        margin-top: 20px;
        padding: 8px 13px;
        background: #f0fdf4;
        color: #15803d;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 700;
    }

    .form-card h2 {
        margin: 0 0 8px;
        font-size: 22px;
    }

    .form-intro {
        color: #777e93;
        font-size: 14px;
        line-height: 1.6;
        margin: 0 0 25px;
    }

    .field {
        margin-bottom: 21px;
    }

    .field label {
        display: block;
        font-weight: 700;
        font-size: 14px;
        margin-bottom: 9px;
    }

    .field input {
        width: 100%;
        padding: 13px 14px;
        border: 1px solid #dce0eb;
        border-radius: 9px;
        outline: none;
        font-size: 15px;
        color: #20263a;
        background: #fff;
    }

    .field input:focus {
        border-color: #635bdb;
        box-shadow: 0 0 0 3px rgba(99, 91, 219, .12);
    }

    .field small {
        display: block;
        margin-top: 7px;
        color: #83899a;
        font-size: 12px;
    }

    .actions {
        display: flex;
        gap: 12px;
        flex-wrap: wrap;
        margin-top: 28px;
    }

    .btn {
        display: inline-block;
        border: 0;
        border-radius: 9px;
        padding: 13px 20px;
        font-weight: 700;
        font-size: 14px;
        text-decoration: none;
        cursor: pointer;
    }

    .btn-primary {
        background: #635bdb;
        color: #fff;
    }

    .btn-primary:hover {
        background: #5148c7;
    }

    .btn-secondary {
        background: #f0f1f7;
        color: #444b61;
    }

    .message {
        padding: 14px 16px;
        border-radius: 9px;
        margin-bottom: 20px;
        font-size: 14px;
        line-height: 1.5;
    }

    .success {
        color: #047857;
        background: #ecfdf5;
        border: 1px solid #a7f3d0;
    }

    .error {
        color: #be123c;
        background: #fff1f2;
        border: 1px solid #fecdd3;
    }

    .footer {
        text-align: center;
        padding: 25px 15px;
        color: #8b90a1;
        font-size: 13px;
    }

    @media (max-width: 700px) {
        .profile-layout {
            grid-template-columns: 1fr;
        }

        .page {
            margin-top: 28px;
        }

       
        .card {
            padding: 23px;
        }
    }
</style>
</head>

<body>

<jsp:include page="navbar.jsp" />

<main class="page">

    <div class="heading">
        <h1>My Profile</h1>
        <p>Manage your personal details and keep your Eventify account up to date.</p>
    </div>

    <% if (message != null) { %>
        <div class="message success"><%= esc(message) %></div>
    <% } %>

    <% if (error != null) { %>
        <div class="message error"><%= esc(error) %></div>
    <% } %>

    <div class="profile-layout">

        <section class="card profile-summary">
            <div class="avatar"><%= esc(initial) %></div>

            <h2><%= esc(profile.getFullName()) %></h2>
            <p><%= esc(profile.getEmail()) %></p>

            <span class="account-label">Registered User</span>
        </section>

        <section class="card form-card">
            <h2>Personal Information</h2>

            <p class="form-intro">
                Update your name and email address below.
                Your account ID and role cannot be changed here.
            </p>

            <form method="post"
                  action="<%= contextPath %>/update-profile">

                <div class="field">
                    <label for="userId">User ID</label>
                    <input type="text"
                           id="userId"
                           value="<%= profile.getUserId() %>"
                           readonly>
                    <small>Your user ID is assigned by Eventify.</small>
                </div>

                <div class="field">
                    <label for="fullName">Full Name</label>
                    <input type="text"
                           id="fullName"
                           name="fullName"
                           minlength="2"
                           maxlength="100"
                           value="<%= esc(profile.getFullName()) %>"
                           autocomplete="name"
                           required>
                </div>

                <div class="field">
                    <label for="email">Email Address</label>
                    <input type="email"
                           id="email"
                           name="email"
                           maxlength="254"
                           value="<%= esc(profile.getEmail()) %>"
                           autocomplete="email"
                           required>
                    <small>Your email must not already belong to another account.</small>
                </div>

                <div class="actions">
                    <button class="btn btn-primary" type="submit">
                        Save Changes
                    </button>

                    <a class="btn btn-secondary"
                       href="<%= contextPath %>/home.jsp">
                        Back to Home
                    </a>
                </div>

            </form>
        </section>

    </div>
</main>

<footer class="footer">
    © 2026 Eventify. Your events, your experiences.
</footer>

</body>
</html>
