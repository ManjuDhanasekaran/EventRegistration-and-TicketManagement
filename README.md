# Event Registration and Ticket Management System

A web-based Event Registration and Ticket Management System developed using Java and Advanced Java technologies. This application allows users to browse events, register for events, book tickets, process simulated payments, and manage their bookings. It also provides an Admin module to manage events and monitor user registrations.

## 🚀 Features

### 👤 User Module
- User Registration and Login
- Session Management and Logout
- View Available Events
- Book Event Tickets
- Simulated Payment Processing
- Handle Payment Success and Failure Scenarios
- View My Bookings
- View My Tickets
- Cancel Bookings
- User Profile Management

### 🔐 Admin Module
- Admin Login
- Admin Dashboard
- Add New Events
- Edit Existing Events
- Manage Events
- Update Event Status
- Manage Event Registrations
- View Booking and Payment Status

### 💳 Payment Module
- Simulated payment processing.
- Handles payment success and failure scenarios.
- Updates booking and payment statuses based on payment results.
- Generates tickets for successful bookings.

**Note:** The payment functionality is implemented as a simulated payment workflow for demonstration purposes. It is not integrated with a real payment gateway such as Razorpay, Stripe, or PayPal.

## 🛠️ Technologies Used

| Technology | Purpose |
|---|---|
| Java 21 | Backend Development |
| JSP | Dynamic Web Pages |
| Servlets | Request and Response Handling |
| JDBC | Database Connectivity |
| MySQL | Database Management |
| HTML5 | Page Structure |
| CSS3 | Styling |
| Apache Tomcat 10.1 | Application Server |
| Eclipse IDE | Development Environment |
| Git & GitHub | Version Control |

## 🏗️ Project Architecture

The application follows a layered architecture:

- **Model:** Represents application data.
- **DAO (Data Access Object):** Handles database operations using JDBC.
- **Servlet:** Handles HTTP requests and application logic.
- **JSP:** Provides the user interface.
- **Util:** Contains utility classes such as database connection management.

## ⚙️ Prerequisites

Before running the application, make sure you have installed:

- Java JDK 21
- Eclipse IDE for Enterprise Java and Web Developers
- Apache Tomcat 10.1
- MySQL Server
- MySQL Workbench
- MySQL JDBC Driver

## 🗄️ Database Configuration

1. Start the MySQL Server.
2. Create the project database.
3. Create the required database tables using the SQL scripts.
4. Configure the database connection in the `DBConnection` utility class.
5. Update the database username and password according to your local MySQL configuration.

Example database configuration:

```java
String url = "jdbc:mysql://localhost:3306/eventmanagement";
String username = "root";
String password = "your_password";
```

Replace the database name, username, and password with your own configuration.

## ▶️ How to Run the Project

1. Clone or download this repository.
2. Open Eclipse IDE.
3. Import the project into Eclipse as an existing Dynamic Web Project.
4. Configure JDK 21.
5. Configure Apache Tomcat 10.1.
6. Set up the MySQL database and tables.
7. Configure the database connection.
8. Add the MySQL JDBC Driver if required.
9. Run the project on the Tomcat server.
10. Open the application in your browser.

```text
http://localhost:8081/EventManagement/
```

*Note: Update the port number and context path according to your local server configuration.*

## 🧪 Testing

The application has been tested for the following functionalities:

- User registration and login.
- Session handling and logout.
- Admin access restrictions.
- Event creation and editing.
- Event status management.
- Event booking.
- Payment success and failure scenarios.
- Ticket generation.
- Booking cancellation.
- Admin and user module functionality.

## 🔒 Security Notes

- Do not expose database credentials in the repository.
- Configure your own database credentials before running the application.
- Admin and user access are handled through role-based session checks.

## 👩‍💻 Developer

**Manju Dhanasekaran**

Java Developer | Java | JDBC | Servlets | JSP | MySQL

## 📌 Project Status

Core User and Admin functionalities have been implemented and tested.

Future enhancements may include:
- Enhanced input validation and error handling.
- Application logging.
- Real payment gateway integration.
- Additional security improvements.

---

⭐ If you find this project useful, feel free to explore the source code and share your feedback!
