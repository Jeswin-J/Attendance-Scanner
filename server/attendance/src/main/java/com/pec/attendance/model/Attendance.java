package com.pec.attendance.model;

import jakarta.persistence.*;

import java.sql.Timestamp;

@Entity
@Table(name = "attendance")
public class Attendance {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String rollNumber;

    @Column(nullable = false)
    private Timestamp timestamp;


    public Long getId() {
        return id;
    }

    public String getRollNumber() {
        return rollNumber;
    }

    public Attendance setRollNumber(String rollNumber) {
        this.rollNumber = rollNumber;
        return this;
    }

    public Timestamp getTimestamp() {
        return timestamp;
    }

    public Attendance setTimeStamp(Timestamp timestamp) {
        this.timestamp = timestamp;
        return this;
    }
}
