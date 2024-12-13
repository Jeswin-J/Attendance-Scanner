package com.pec.attendance.exceptions;

public class AttendanceNotFoundException extends RuntimeException {
    public AttendanceNotFoundException(String rollNumber) {
        super("Attendance already marked for today for roll number: " + rollNumber);
    }
}
