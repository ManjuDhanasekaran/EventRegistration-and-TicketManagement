package eventManagement.dao;


import eventManagement.model.Event;
import eventManagement.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EventDAO {

    private void setEventFields(PreparedStatement ps, Event e)
            throws SQLException {

        ps.setString(1, e.getTitle());
        ps.setString(2, e.getDescription());
        ps.setDate(3, Date.valueOf(e.getEventDate()));
        ps.setTime(4, Time.valueOf(normalizeTime(e.getStartTime())));
        ps.setTime(5, Time.valueOf(normalizeTime(e.getEndTime())));
        ps.setString(6, e.getVenue());
        ps.setBigDecimal(7,
                java.math.BigDecimal.valueOf(e.getTicketPrice()));
        ps.setInt(8, e.getTotalSeats());
        ps.setTimestamp(9, Timestamp.valueOf(
                normalizeDateTime(e.getRegistrationDeadline())));
        ps.setString(10, e.getStatus());
    }

    private String normalizeTime(String time) {
        return time.length() == 5 ? time + ":00" : time;
    }

    private String normalizeDateTime(String value) {
        String normalized = value.replace("T", " ");
        return normalized.length() == 16
                ? normalized + ":00" : normalized;
    }

    private Event mapEvent(ResultSet rs) throws SQLException {
        Event e = new Event();

        e.setEventId(rs.getInt("event_id"));
        e.setTitle(rs.getString("title"));
        e.setDescription(rs.getString("description"));
        e.setEventDate(rs.getDate("event_date").toString());
        e.setStartTime(rs.getTime("start_time").toString());
        e.setEndTime(rs.getTime("end_time").toString());
        e.setVenue(rs.getString("venue"));
        e.setTicketPrice(rs.getBigDecimal("ticket_price").doubleValue());
        e.setTotalSeats(rs.getInt("total_seats"));
        e.setRegistrationDeadline(
                rs.getTimestamp("registration_deadline").toString()
                  .replace(" ", "T"));
        e.setStatus(rs.getString("status"));
        e.setCreatedBy(rs.getInt("created_by"));

        return e;
    }

    public List<Event> findAll() throws SQLException {
        List<Event> events = new ArrayList<>();

        String sql = "SELECT * FROM events ORDER BY created_at DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                events.add(mapEvent(rs));
            }
        }

        return events;
    }

    public Event findById(int id) throws SQLException {
        String sql = "SELECT * FROM events WHERE event_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapEvent(rs);
                }
            }
        }

        return null;
    }

    public boolean create(Event e, int adminId) throws SQLException {
        String sql = "INSERT INTO events "
                + "(title, description, event_date, start_time, end_time, "
                + "venue, ticket_price, total_seats, registration_deadline, "
                + "status, created_by) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            setEventFields(ps, e);
            ps.setInt(11, adminId);

            return ps.executeUpdate() == 1;
        }
    }

    public boolean update(Event e) throws SQLException {
        String sql = "UPDATE events SET title=?, description=?, "
                + "event_date=?, start_time=?, end_time=?, venue=?, "
                + "ticket_price=?, total_seats=?, registration_deadline=?, "
                + "status=? WHERE event_id=?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            setEventFields(ps, e);
            ps.setInt(11, e.getEventId());

            return ps.executeUpdate() == 1;
        }
    }

    public boolean updateStatus(int id, String status)
            throws SQLException {

        String sql = "UPDATE events SET status=? WHERE event_id=?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, id);

            return ps.executeUpdate() == 1;
        }
    }
    

public List<Event> findPublishedEvents() throws SQLException {

    List<Event> events = new ArrayList<>();

    String sql =
        "SELECT e.*, " +
        "GREATEST(0, e.total_seats - COALESCE((" +
        "  SELECT SUM(b.ticket_quantity) " +
        "  FROM bookings b " +
        "  WHERE b.event_id = e.event_id " +
        "  AND (b.booking_status = 'CONFIRMED' " +
        "       OR (b.booking_status = 'PENDING_PAYMENT' " +
        "           AND b.reservation_expires_at > NOW()))" +
        "), 0)) AS available_seats " +
        "FROM events e " +
        "WHERE e.status = 'PUBLISHED' " +
        "AND e.event_date >= CURDATE() " +
        "AND e.registration_deadline > NOW() " +
        "ORDER BY e.event_date, e.start_time";

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {
            Event event = mapEvent(rs);
            event.setAvailableSeats(rs.getInt("available_seats"));
            events.add(event);
        }
    }

    return events;
}

public Event findPublishedById(int id) throws SQLException {

    String sql =
        "SELECT e.*, " +
        "GREATEST(0, e.total_seats - COALESCE((" +
        "  SELECT SUM(b.ticket_quantity) " +
        "  FROM bookings b " +
        "  WHERE b.event_id = e.event_id " +
        "  AND (b.booking_status = 'CONFIRMED' " +
        "       OR (b.booking_status = 'PENDING_PAYMENT' " +
        "           AND b.reservation_expires_at > NOW()))" +
        "), 0)) AS available_seats " +
        "FROM events e " +
        "WHERE e.event_id = ? " +
        "AND e.status = 'PUBLISHED' " +
        "AND e.event_date >= CURDATE() " +
        "AND e.registration_deadline > NOW()";

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        ps.setInt(1, id);

        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                Event event = mapEvent(rs);
                event.setAvailableSeats(
                    rs.getInt("available_seats"));
                return event;
            }
        }
    }

    return null;
}


public List<Event> findAllWithRegistrationCount() throws SQLException {

    List<Event> events = new ArrayList<>();

    String sql =
        "SELECT e.*, " +

        // Total booking history
        "COUNT(b.booking_id) AS registration_count, " +
        "COALESCE(SUM(b.ticket_quantity), 0) AS registered_tickets, " +

        // Confirmed bookings
        "SUM(CASE WHEN b.booking_status = 'CONFIRMED' " +
        "THEN 1 ELSE 0 END) AS confirmed_bookings, " +

        "COALESCE(SUM(CASE WHEN b.booking_status = 'CONFIRMED' " +
        "THEN b.ticket_quantity ELSE 0 END), 0) AS confirmed_tickets, " +

        // Active pending bookings
        "SUM(CASE WHEN b.booking_status = 'PENDING_PAYMENT' " +
        "AND b.reservation_expires_at > NOW() " +
        "THEN 1 ELSE 0 END) AS pending_bookings, " +

        "COALESCE(SUM(CASE WHEN b.booking_status = 'PENDING_PAYMENT' " +
        "AND b.reservation_expires_at > NOW() " +
        "THEN b.ticket_quantity ELSE 0 END), 0) AS pending_tickets, " +

        // Cancelled bookings
        "SUM(CASE WHEN b.booking_status = 'CANCELLED' " +
        "THEN 1 ELSE 0 END) AS cancelled_bookings, " +

        "COALESCE(SUM(CASE WHEN b.booking_status = 'CANCELLED' " +
        "THEN b.ticket_quantity ELSE 0 END), 0) AS cancelled_tickets, " +

        // Expired bookings, including pending reservations past expiry
        "SUM(CASE WHEN b.booking_status = 'EXPIRED' " +
        "OR (b.booking_status = 'PENDING_PAYMENT' " +
        "AND (b.reservation_expires_at IS NULL " +
        "OR b.reservation_expires_at <= NOW())) " +
        "THEN 1 ELSE 0 END) AS expired_bookings, " +

        "COALESCE(SUM(CASE WHEN b.booking_status = 'EXPIRED' " +
        "OR (b.booking_status = 'PENDING_PAYMENT' " +
        "AND (b.reservation_expires_at IS NULL " +
        "OR b.reservation_expires_at <= NOW())) " +
        "THEN b.ticket_quantity ELSE 0 END), 0) AS expired_tickets " +

        "FROM events e " +
        "LEFT JOIN bookings b ON e.event_id = b.event_id " +
        "GROUP BY e.event_id " +
        "ORDER BY e.created_at DESC";

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {

            Event event = mapEvent(rs);

            // Total booking history
            event.setRegistrationCount(
                rs.getInt("registration_count"));

            event.setRegisteredTickets(
                rs.getInt("registered_tickets"));

            // Confirmed
            event.setConfirmedBookings(
                rs.getInt("confirmed_bookings"));

            event.setConfirmedTickets(
                rs.getInt("confirmed_tickets"));

            // Pending
            event.setPendingBookings(
                rs.getInt("pending_bookings"));

            event.setPendingTickets(
                rs.getInt("pending_tickets"));

            // Cancelled
            event.setCancelledBookings(
                rs.getInt("cancelled_bookings"));

            event.setCancelledTickets(
                rs.getInt("cancelled_tickets"));

            // Expired
            event.setExpiredBookings(
                rs.getInt("expired_bookings"));

            event.setExpiredTickets(
                rs.getInt("expired_tickets"));

            // Available seats
            int availableSeats = event.getTotalSeats()
                    - event.getConfirmedTickets()
                    - event.getPendingTickets();

            event.setAvailableSeats(
                Math.max(0, availableSeats));

            events.add(event);
        }
    }

    return events;
}


public Event findByIdWithRegistrationStats(int eventId)
        throws SQLException {

    String sql =
        "SELECT e.*, " +

        "COUNT(b.booking_id) AS registration_count, " +
        "COALESCE(SUM(b.ticket_quantity), 0) AS registered_tickets, " +

        "SUM(CASE WHEN b.booking_status = 'CONFIRMED' " +
        "THEN 1 ELSE 0 END) AS confirmed_bookings, " +

        "COALESCE(SUM(CASE WHEN b.booking_status = 'CONFIRMED' " +
        "THEN b.ticket_quantity ELSE 0 END), 0) AS confirmed_tickets, " +

        "SUM(CASE WHEN b.booking_status = 'PENDING_PAYMENT' " +
        "AND b.reservation_expires_at > NOW() " +
        "THEN 1 ELSE 0 END) AS pending_bookings, " +

        "COALESCE(SUM(CASE WHEN b.booking_status = 'PENDING_PAYMENT' " +
        "AND b.reservation_expires_at > NOW() " +
        "THEN b.ticket_quantity ELSE 0 END), 0) AS pending_tickets, " +

        "SUM(CASE WHEN b.booking_status = 'CANCELLED' " +
        "THEN 1 ELSE 0 END) AS cancelled_bookings, " +

        "COALESCE(SUM(CASE WHEN b.booking_status = 'CANCELLED' " +
        "THEN b.ticket_quantity ELSE 0 END), 0) AS cancelled_tickets, " +

        "SUM(CASE WHEN b.booking_status = 'EXPIRED' " +
        "OR (b.booking_status = 'PENDING_PAYMENT' " +
        "AND (b.reservation_expires_at IS NULL " +
        "OR b.reservation_expires_at <= NOW())) " +
        "THEN 1 ELSE 0 END) AS expired_bookings, " +

        "COALESCE(SUM(CASE WHEN b.booking_status = 'EXPIRED' " +
        "OR (b.booking_status = 'PENDING_PAYMENT' " +
        "AND (b.reservation_expires_at IS NULL " +
        "OR b.reservation_expires_at <= NOW())) " +
        "THEN b.ticket_quantity ELSE 0 END), 0) AS expired_tickets " +

        "FROM events e " +
        "LEFT JOIN bookings b ON e.event_id = b.event_id " +
        "WHERE e.event_id = ? " +
        "GROUP BY e.event_id";

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        ps.setInt(1, eventId);

        try (ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {

                Event event = mapEvent(rs);

                event.setRegistrationCount(
                    rs.getInt("registration_count"));

                event.setRegisteredTickets(
                    rs.getInt("registered_tickets"));

                event.setConfirmedBookings(
                    rs.getInt("confirmed_bookings"));

                event.setConfirmedTickets(
                    rs.getInt("confirmed_tickets"));

                event.setPendingBookings(
                    rs.getInt("pending_bookings"));

                event.setPendingTickets(
                    rs.getInt("pending_tickets"));

                event.setCancelledBookings(
                    rs.getInt("cancelled_bookings"));

                event.setCancelledTickets(
                    rs.getInt("cancelled_tickets"));

                event.setExpiredBookings(
                    rs.getInt("expired_bookings"));

                event.setExpiredTickets(
                    rs.getInt("expired_tickets"));

                int availableSeats = event.getTotalSeats()
                        - event.getConfirmedTickets()
                        - event.getPendingTickets();

                event.setAvailableSeats(
                    Math.max(0, availableSeats));

                return event;
            }
        }
    }

    return null;
}

}

