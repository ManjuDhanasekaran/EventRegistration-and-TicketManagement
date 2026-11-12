package eventManagement.util;

import java.sql.*;

public class DBConnection {

	public static final String url = "jdbc:mysql://localhost:3306/event_registration_db";
	public static final String userName = "root";
	public static final String password = "root";
	
	public static Connection getConnection() throws SQLException {
		
		return DriverManager.getConnection(url, userName, password);
	}
	
}
