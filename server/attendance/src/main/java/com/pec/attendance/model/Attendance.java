package com.pec.attendance.model;

import jakarta.persistence.*;
import lombok.Getter;

import java.sql.Timestamp;

@Entity
@Getter
public class Attendance {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String rollNumber;

    @Column(nullable = false)
    private Timestamp timestamp = new Timestamp(System.currentTimeMillis());


    //Setters
    public Attendance setId(Long id) {
        this.id = id;
        return this;
    }

    public Attendance setRollNumber(String rollNumber) {
        this.rollNumber = rollNumber;
        return this;
    }

    public Attendance setTimestamp(Timestamp timestamp) {
        this.timestamp = timestamp;
        return this;
    }
}
