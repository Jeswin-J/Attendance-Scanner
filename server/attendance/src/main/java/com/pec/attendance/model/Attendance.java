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
    private Timestamp timestamp = new Timestamp(System.currentTimeMillis());

    public Long getId() {
        return id;
    }

    public Attendance setId(Long id) {
        this.id = id;
        return this;
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
}
