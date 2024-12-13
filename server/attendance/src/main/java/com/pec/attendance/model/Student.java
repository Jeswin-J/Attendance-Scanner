package com.pec.attendance.model;

import com.pec.attendance.enums.Venue;
import jakarta.persistence.*;
import lombok.Getter;

@Entity
@Getter
public class Student {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, unique = true)
    private String rollNumber;

    @Column(nullable = false)
    private String year;

    @Column(nullable = false)
    private String department;

    @Column(nullable = false)
    private Character section;

    @Enumerated(EnumType.STRING)
    private Venue venue;


    //Setters
    public Student setId(Long id) {
        this.id = id;
        return this;
    }

    public Student setName(String name) {
        this.name = name;
        return this;
    }

    public Student setRollNumber(String rollNumber) {
        this.rollNumber = rollNumber;
        return this;
    }

    public Student setYear(String year) {
        this.year = year;
        return this;
    }

    public Student setDepartment(String department) {
        this.department = department;
        return this;
    }

    public Student setSection(Character section) {
        this.section = section;
        return this;
    }

    public Student setVenue(Venue venue) {
        this.venue = venue;
        return this;
    }
}
