package com.pec.attendance.dto;


public class MarkAttendanceRequest {
    private String rollNumber;

    public String getRollNumber() {
        return rollNumber;
    }

    public MarkAttendanceRequest setRollNumber(String rollNumber) {
        this.rollNumber = rollNumber;
        return this;
    }
}
