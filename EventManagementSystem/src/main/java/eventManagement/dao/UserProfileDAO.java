
package eventManagement.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import eventManagement.model.UserProfile;
import eventManagement.util.DBConnection;

public class UserProfileDAO {

    public UserProfile findById(int userId) throws SQLException {

        String sql =
            "SELECT user_id, full_name, email " +
            "FROM users WHERE user_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    UserProfile profile = new UserProfile();

                    profile.setUserId(rs.getInt("user_id"));
                    profile.setFullName(rs.getString("full_name"));
                    profile.setEmail(rs.getString("email"));

                    return profile;
                }
            }
        }

        return null;
    }

    public boolean emailExistsForAnotherUser(
            String email, int userId) throws SQLException {

        String sql =
            "SELECT user_id FROM users " +
            "WHERE LOWER(email) = LOWER(?) AND user_id <> ? " +
            "LIMIT 1";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean updateProfile(
            int userId, String fullName, String email)
            throws SQLException {

        String sql =
            "UPDATE users SET full_name = ?, email = ? " +
            "WHERE user_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setInt(3, userId);

            return ps.executeUpdate() == 1;
        }
    }
}
