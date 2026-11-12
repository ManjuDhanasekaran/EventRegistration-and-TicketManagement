
package eventManagement.model;

public class Event {

    private int eventId;
    private String title;
    private String description;
    private String eventDate;
    private String startTime;
    private String endTime;
    private String venue;
    private double ticketPrice;
    private int totalSeats;
    private String registrationDeadline;
    private String status;
    private int createdBy;
    private int availableSeats;
    private int registrationCount;
    private int registeredTickets;
    private int confirmedBookings;
    private int confirmedTickets;

    private int cancelledBookings;
    private int cancelledTickets;

    private int pendingBookings;
    private int pendingTickets;

    private int expiredBookings;
    private int expiredTickets;

    public int getEventId() { return eventId; }
    public void setEventId(int eventId) { this.eventId = eventId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) {
        this.description = description;
    }

    public String getEventDate() { return eventDate; }
    public void setEventDate(String eventDate) {
        this.eventDate = eventDate;
    }

    public String getStartTime() { return startTime; }
    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    public String getEndTime() { return endTime; }
    public void setEndTime(String endTime) {
        this.endTime = endTime;
    }

    public String getVenue() { return venue; }
    public void setVenue(String venue) { this.venue = venue; }

    public double getTicketPrice() { return ticketPrice; }
    public void setTicketPrice(double ticketPrice) {
        this.ticketPrice = ticketPrice;
    }

    public int getTotalSeats() { return totalSeats; }
    public void setTotalSeats(int totalSeats) {
        this.totalSeats = totalSeats;
    }

    public String getRegistrationDeadline() {
        return registrationDeadline;
    }

    public void setRegistrationDeadline(String deadline) {
        this.registrationDeadline = deadline;
    }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public String getStartTimeInput() {
        return startTime == null ? "" : startTime.substring(0, 5);
    }

    public String getEndTimeInput() {
        return endTime == null ? "" : endTime.substring(0, 5);
    }

    public String getDeadlineInput() {
        return registrationDeadline == null
                ? "" : registrationDeadline.replace(" ", "T");
    }
    
    public int getAvailableSeats() {
        return availableSeats;
    }

    public void setAvailableSeats(int availableSeats) {
        this.availableSeats = availableSeats;
    }
	public int getRegistrationCount() {
		return registrationCount;
	}
	public void setRegistrationCount(int registrationCount) {
		this.registrationCount = registrationCount;
	}
	public int getRegisteredTickets() {
		return registeredTickets;
	}
	public void setRegisteredTickets(int registeredTickets) {
		this.registeredTickets = registeredTickets;
	}
    
	public int getConfirmedBookings() {
	    return confirmedBookings;
	}

	public void setConfirmedBookings(int confirmedBookings) {
	    this.confirmedBookings = confirmedBookings;
	}

	public int getConfirmedTickets() {
	    return confirmedTickets;
	}

	public void setConfirmedTickets(int confirmedTickets) {
	    this.confirmedTickets = confirmedTickets;
	}

	public int getCancelledBookings() {
	    return cancelledBookings;
	}

	public void setCancelledBookings(int cancelledBookings) {
	    this.cancelledBookings = cancelledBookings;
	}

	public int getCancelledTickets() {
	    return cancelledTickets;
	}

	public void setCancelledTickets(int cancelledTickets) {
	    this.cancelledTickets = cancelledTickets;
	}

	public int getPendingBookings() {
	    return pendingBookings;
	}

	public void setPendingBookings(int pendingBookings) {
	    this.pendingBookings = pendingBookings;
	}

	public int getPendingTickets() {
	    return pendingTickets;
	}

	public void setPendingTickets(int pendingTickets) {
	    this.pendingTickets = pendingTickets;
	}

	public int getExpiredBookings() {
	    return expiredBookings;
	}

	public void setExpiredBookings(int expiredBookings) {
	    this.expiredBookings = expiredBookings;
	}

	public int getExpiredTickets() {
	    return expiredTickets;
	}

	public void setExpiredTickets(int expiredTickets) {
	    this.expiredTickets = expiredTickets;
	}
}
