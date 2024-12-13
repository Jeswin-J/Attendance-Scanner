package com.pec.attendance.exceptions;

public class StudentNotFoundException extends RuntimeException {
    public StudentNotFoundException(String rollNumber) {
        super("Student not found with roll number: " + rollNumber);
    }
}

