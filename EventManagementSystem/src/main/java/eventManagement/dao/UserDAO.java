package eventManagement.dao;

import eventManagement.model.*;
import eventManagement.util.*;
import java.sql.*;

public class UserDAO {

	
	 public boolean register(User user) throws SQLException {

	        String sql =
	            "INSERT INTO users "
	          + "(full_name, email, password_hash, role, status) "
	          + "VALUES (?, ?, ?, 'USER', 'ACTIVE')";

	        try (Connection con = DBConnection.getConnection();
	             PreparedStatement ps =
	                     con.prepareStatement(sql)) {

	            ps.setString(1, user.getFullName());
	            ps.setString(2, user.getEmail());
	            ps.setString(3, user.getPassword());

	            return ps.executeUpdate() == 1;
	        }
	    } 
	 
	 
	 public User findByEmail(String email) throws SQLException {
		 
		  String sql = "SELECT user_id, full_name, email, "
		            + "password_hash, role, status "
		            + "FROM users WHERE email = ?";
		  
		  
		  try(Connection con = DBConnection.getConnection();
				  PreparedStatement ps = con.prepareStatement(sql)){
			   ps.setString(1, email);
			   ResultSet rs = ps.executeQuery();
			   
			   
			   
			   while(rs.next()) {
				    return new User(
	                        rs.getInt("user_id"),
	                        rs.getString("full_name"),
	                        rs.getString("email"),
	                        rs.getString("password_hash"),
	                        rs.getString("role"),
	                        rs.getString("status")
	                );
			   }
		  }
		  
		  return null;
	 }
	 
	 
	 
	}	
		 


