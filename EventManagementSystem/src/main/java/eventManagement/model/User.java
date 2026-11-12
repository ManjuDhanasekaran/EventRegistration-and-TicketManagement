package eventManagement.model;

public class User {
	
	private String fullName;
	private String email;
	private String password;
	private int userId;
	private String status;
	private String role;
	
	
	public User(int userId, String fullName, String email, String password, String role ,String status) {
		super();
		this.fullName = fullName;
		this.email = email;
		this.password = password;
		this.userId = userId;
		this.status = status;
		this.role = role;
	}
	

	public User(String fullName, String email, String password) {
		super();
		this.fullName = fullName;
		this.email = email;
		this.password = password;
		this.role = "USER";
        this.status = "ACTIVE";
	}

	public String getFullName() {
		return fullName;
	}

	public String getEmail() {
		return email;
	}


	public String getPassword() {
		return password;
	}

	public int getUserId() {
		return userId;
	}

	public String getStatus() {
		return status;
	}

	public String getRole() {
		return role;
	}

}
