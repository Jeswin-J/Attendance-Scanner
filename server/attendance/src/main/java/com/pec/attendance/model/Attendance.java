package com.pec.attendance.model;

import jakarta.persistence.*;

import java.sql.Timestamp;

@Entity
@Table(name = "attendance")
public class Attendance {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long attendanceId;

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "studentId", nullable = false)
    private Student student;

    @Column(nullable = false)
    private Timestamp timestamp;


    public Long getAttendanceId() {
        return attendanceId;
    }


    public void setAttendanceId(Long attendanceId) {
        this.attendanceId = attendanceId;
    }

    public Timestamp getTimestamp() {
        return timestamp;
    }

    public Attendance setTimeStamp(Timestamp timestamp) {
        this.timestamp = timestamp;
        return this;
    }

    public Student getStudent() {
        return student;
    }

    public Attendance setStudent(Student student) {
        this.student = student;
        return this;
    }
}
