
package eventManagement.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import eventManagement.model.Ticket;
import eventManagement.util.DBConnection;

public class TicketDAO {

    public List<Ticket> findByUserId(int userId)
            throws SQLException {

        List<Ticket> tickets = new ArrayList<>();

        String sql =
            "SELECT t.ticket_number, t.ticket_status, " +
            "b.booking_reference, e.title, e.event_date, " +
            "e.start_time, e.venue " +
            "FROM tickets t " +
            "JOIN bookings b ON t.booking_id = b.booking_id " +
            "JOIN events e ON b.event_id = e.event_id " +
            "WHERE b.user_id = ? " +
            "ORDER BY t.issued_at DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    Ticket ticket = new Ticket();

                    ticket.setTicketNumber(
                            rs.getString("ticket_number"));

                    ticket.setTicketStatus(
                            rs.getString("ticket_status"));

                    ticket.setBookingReference(
                            rs.getString("booking_reference"));

                    ticket.setEventTitle(
                            rs.getString("title"));

                    ticket.setEventDate(
                            rs.getDate("event_date").toString());

                    ticket.setStartTime(
                            rs.getTime("start_time").toString());

                    ticket.setVenue(
                            rs.getString("venue"));

                    tickets.add(ticket);
                }
            }
        }

        return tickets;
    }
}
