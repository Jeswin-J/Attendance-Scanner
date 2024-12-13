package com.pec.attendance.service;

import com.pec.attendance.model.Attendance;
import com.pec.attendance.model.Student;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
public interface ServiceInterface {
    Attendance markAttendance(String rollNumber);

    boolean hasAttendanceForToday(String rollNumber);

    List<Student> attendanceRecord(LocalDate date);
}
