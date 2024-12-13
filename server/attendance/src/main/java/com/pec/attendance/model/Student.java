package com.pec.attendance.model;

import com.pec.attendance.enums.Venue;
import jakarta.persistence.*;

@Entity
@Table(name = "student")
public class Student {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long studentId;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, unique = true)
    private String registerNumber;

    @Column(nullable = false, unique = true)
    private String rollNumber;

    @Column(nullable = false)
    private String year;

    @Column(nullable = false)
    private String department;

    @Column(nullable = false)
    private Character section;

    @Column(nullable = true)
    @Enumerated(EnumType.STRING)
    private Venue venue;

    public Long getStudentId() {
        return studentId;
    }


    public void setStudentId(Long studentId) {
        this.studentId = studentId;
    }

    public String getName() {
        return name;
    }

    public Student setName(String name) {
        this.name = name;
        return this;
    }

    public String getRollNumber() {
        return rollNumber;
    }

    public Student setRollNumber(String rollNumber) {
        this.rollNumber = rollNumber;
        return this;
    }

    public String getYear() {
        return year;
    }

    public Student setYear(String year) {
        this.year = year;
        return this;
    }

    public String getDepartment() {
        return department;
    }

    public Student setDepartment(String department) {
        this.department = department;
        return this;
    }

    public Character getSection() {
        return section;
    }

    public Student setSection(Character section) {
        this.section = section;
        return this;
    }

    public Venue getVenue() {
        return venue;
    }

    public Student setVenue(Venue venue) {
        this.venue = venue;
        return this;
    }

    public String getRegisterNumber() {
        return registerNumber;
    }

    public Student setRegisterNumber(String registerNumber) {
        this.registerNumber = registerNumber;
        return this;
    }
}
