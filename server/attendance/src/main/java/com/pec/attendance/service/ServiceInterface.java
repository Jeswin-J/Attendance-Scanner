package com.pec.attendance.service;

import com.pec.attendance.model.Attendance;
import com.pec.attendance.model.Student;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.util.List;

@Service
public interface ServiceInterface {
    Attendance markAttendance(String rollNumber);

    boolean hasAttendanceForToday(String rollNumber);

    List<Student> attendanceRecord(LocalDate date);

    List<Student> absenteeRecord(LocalDate date);

    void saveStudentsFromCsv(MultipartFile file) throws Exception;
}
