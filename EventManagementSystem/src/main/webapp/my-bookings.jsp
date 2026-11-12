
<%@ page import="java.util.List" %>
<%@ page import="eventManagement.model.MyBooking" %>

<%!
    private String esc(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }

    private String statusClass(String status) {
        if (status == null) return "neutral";

        switch (status.toUpperCase()) {
            case "CONFIRMED":
            case "SUCCESS":
                return "success";
            case "PENDING_PAYMENT":
            case "PENDING":
                return "pending";
            case "CANCELLED":
            case "FAILED":
            case "EXPIRED":
                return "danger";
            case "REFUNDED":
                return "refunded";
            default:
                return "neutral";
        }
    }
%>

<%
    if (session.getAttribute("userId") == null
            || !"USER".equals(String.valueOf(session.getAttribute("role")))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    List<MyBooking> bookings =
        (List<MyBooking>) request.getAttribute("bookings");

    if (bookings == null) {
        bookings = java.util.Collections.emptyList();
    }

    String contextPath = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Bookings | Eventify</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f4f6fb;
            color: #20243a;
        }



        .container {
            width: 86%;
            max-width: 1100px;
            margin: 38px auto;
        }

        .page-heading {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
            margin-bottom: 26px;
        }

        h1 {
            margin: 0 0 8px;
            font-size: 30px;
        }

        .subtitle {
            margin: 0;
            color: #747b91;
            line-height: 1.6;
        }

        .primary-btn {
            display: inline-block;
            padding: 12px 18px;
            background: #6554d9;
            color: white;
            text-decoration: none;
            border-radius: 9px;
            font-weight: bold;
        }

        .booking-card {
            background: #ffffff;
            border: 1px solid #e8eaf2;
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 18px;
            box-shadow: 0 5px 18px rgba(27, 35, 75, 0.04);
        }

        .card-top {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 15px;
            flex-wrap: wrap;
            padding-bottom: 18px;
            border-bottom: 1px solid #eceef5;
        }

        .event-title {
            font-size: 21px;
            margin: 0 0 8px;
        }

        .reference {
            color: #747b91;
            font-size: 13px;
            overflow-wrap: anywhere;
        }

        .badge {
            display: inline-block;
            border-radius: 20px;
            padding: 7px 11px;
            font-size: 12px;
            font-weight: bold;
            white-space: nowrap;
        }

        .success {
            color: #13764a;
            background: #e4f8ed;
        }

        .pending {
            color: #946200;
            background: #fff3d2;
        }

        .danger {
            color: #b42335;
            background: #ffe8eb;
        }

        .refunded {
            color: #5947b9;
            background: #eeeaff;
        }

        .neutral {
            color: #525a70;
            background: #eef0f5;
        }

        .details {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 22px;
            padding: 22px 0;
        }

        .detail-label {
            display: block;
            color: #81879a;
            font-size: 12px;
            margin-bottom: 7px;
        }

        .detail-value {
            font-weight: bold;
            font-size: 15px;
            overflow-wrap: anywhere;
        }

        .card-bottom {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 15px;
            border-top: 1px solid #eceef5;
            padding-top: 18px;
        }

        .payment-info {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
            font-size: 13px;
        }

        .tickets-link {
            color: #6554d9;
            font-weight: bold;
            text-decoration: none;
        }

        .tickets-link:hover {
            text-decoration: underline;
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
            background: white;
            border-radius: 16px;
            border: 1px solid #e8eaf2;
        }

        .empty-icon {
            font-size: 45px;
            margin-bottom: 15px;
        }

        .empty-state h2 {
            margin-bottom: 10px;
        }

        .empty-state p {
            color: #747b91;
            line-height: 1.6;
            margin-bottom: 24px;
        }

        footer {
            text-align: center;
            color: #858ba0;
            padding: 24px;
            font-size: 13px;
        }

        @media (max-width: 700px) {
            .container {
                width: 92%;
                margin-top: 25px;
            }

            

            .details {
                grid-template-columns: repeat(2, minmax(0, 1fr));
                gap: 20px 12px;
            }

            .booking-card {
                padding: 18px;
            }

            h1 {
                font-size: 25px;
            }
            .cancel-btn {
			    background: #dc3545;
			    color: white;
			    border: none;
			    padding: 10px 15px;
			    border-radius: 8px;
			    font-weight: bold;
			    cursor: pointer;
				}

			.cancel-btn:hover {
			    background: #b02a37;
			}
        }
    </style>
</head>

<body>

<jsp:include page="navbar.jsp" />


<main class="container">

    <div class="page-heading">
        <div>
            <h1>My Bookings</h1>
            <p class="subtitle">
                View your event reservations and payment details.
            </p>
        </div>

        <a class="primary-btn" href="<%= contextPath %>/events">
            + Explore Events
        </a>
    </div>

    <% if (bookings.isEmpty()) { %>

        <div class="empty-state">
            <div class="empty-icon">&#127915;</div>
            <h2>No bookings yet</h2>
            <p>
                You haven't booked any events yet.
                Explore our events and reserve your place!
            </p>
            <a class="primary-btn" href="<%= contextPath %>/events">
                Browse Events
            </a>
        </div>

    <% } else { %>

        <% for (MyBooking b : bookings) { %>

            <section class="booking-card">

                <div class="card-top">
                    <div>
                        <h2 class="event-title">
                            <%= esc(b.getEventTitle()) %>
                        </h2>

                        <div class="reference">
                            Booking reference:
                            <strong><%= esc(b.getBookingReference()) %></strong>
                        </div>
                    </div>

                    <span class="badge <%= statusClass(b.getBookingStatus()) %>">
                        <%= esc(b.getBookingStatus()) %>
                    </span>
                </div>

                <div class="details">

                    <div>
                        <span class="detail-label">Event date</span>
                        <span class="detail-value">
                            <%= esc(b.getEventDate()) %>
                        </span>
                    </div>

                    <div>
                        <span class="detail-label">Start time</span>
                        <span class="detail-value">
                            <%= esc(b.getStartTime()) %>
                        </span>
                    </div>

                    <div>
                        <span class="detail-label">Tickets booked</span>
                        <span class="detail-value">
                            <%= b.getTicketQuantity() %>
                        </span>
                    </div>

                    <div>
                        <span class="detail-label">Total amount</span>
                        <span class="detail-value">
                            &#8377;<%= b.getTotalAmount() == null
                                ? "0.00"
                                : b.getTotalAmount().toPlainString() %>
                        </span>
                    </div>

                    <div>
                        <span class="detail-label">Booked on</span>
                        <span class="detail-value">
                            <%= esc(b.getBookedAt()) %>
                        </span>
                    </div>

                    <div>
                        <span class="detail-label">Payment status</span>
                        <span class="badge <%= statusClass(b.getPaymentStatus()) %>">
                            <%= esc(b.getPaymentStatus() == null
                                ? "N/A" : b.getPaymentStatus()) %>
                        </span>
                    </div>

                </div>
                
<div class="card-bottom">

    <div class="payment-info">
        <span>Booking status:</span>

        <span class="badge <%= statusClass(b.getBookingStatus()) %>">
            <%= esc(b.getBookingStatus()) %>
        </span>
    </div>

    <div style="display:flex; align-items:center; gap:15px; flex-wrap:wrap;">

        <a class="tickets-link"
           href="<%= contextPath %>/my-tickets">
            View My Tickets &rarr;
        </a>

        <% if ("CONFIRMED".equals(b.getBookingStatus())
                || "PENDING_PAYMENT".equals(b.getBookingStatus())) { %>

            <form action="<%= contextPath %>/cancel-booking"
                  method="post"
                  onsubmit="return confirm('Are you sure you want to cancel this booking?');">

                <input type="hidden"
                       name="bookingReference"
                       value="<%= esc(b.getBookingReference()) %>">

                <button type="submit" class="cancel-btn">
                    Cancel Booking
                </button>

            </form>

        <% } %>

    </div>

</div>
                

              <!--    <div class="card-bottom">
                    <div class="payment-info">
                        <span>Booking status:</span>
                        <span class="badge <%= statusClass(b.getBookingStatus()) %>">
                            <%= esc(b.getBookingStatus()) %>
                        </span>
                    </div>

                    <a class="tickets-link"
                       href="<%= contextPath %>/my-tickets">
                        View My Tickets &rarr;
                    </a>
                </div> -->

            </section>

        <% } %>

    <% } %>
    
    

</main>

<footer>
    &copy; 2026 Eventify. Your events, your memories.
</footer>

</body>
</html>
