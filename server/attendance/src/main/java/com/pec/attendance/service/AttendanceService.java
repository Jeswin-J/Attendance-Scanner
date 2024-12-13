package com.pec.attendance.service;

import com.pec.attendance.model.Attendance;
import com.pec.attendance.model.Student;
import com.pec.attendance.repository.AttendanceRepository;
import com.pec.attendance.repository.StudentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;
import java.util.Optional;

@Service
public class AttendanceService implements ServiceInterface {

    @Autowired
    private AttendanceRepository attendanceRepository;

    @Autowired
    private StudentRepository studentRepository;

    @Override
    public Attendance markAttendance(String rollNumber) {

        Optional<Student> studentOptional = studentRepository.findByRollNumber(rollNumber);

        if (studentOptional.isEmpty()) {
            return null;
        }

        Student student = studentOptional.get();

        LocalDate today = LocalDate.now(ZoneId.of("Asia/Kolkata"));
        Timestamp startOfDay = Timestamp.valueOf(today.atStartOfDay());
        Timestamp endOfDay = Timestamp.valueOf(today.atTime(23, 59, 59));

        Optional<Attendance> existingAttendance = attendanceRepository.findByStudentAndTimestampBetween(student, startOfDay, endOfDay);

        if (existingAttendance.isPresent()) {
            return null;
        }

        Attendance attendanceRecord = new Attendance()
                .setStudent(student)
                .setTimeStamp(new Timestamp(System.currentTimeMillis()));

        return attendanceRepository.save(attendanceRecord);
    }

    @Override
    public boolean hasAttendanceForToday(String rollNumber) {
        Optional<Student> studentOptional = studentRepository.findByRollNumber(rollNumber);

        if (studentOptional.isEmpty()) {
            return false;
        }

        Student student = studentOptional.get();

        LocalDate today = LocalDate.now(ZoneId.of("Asia/Kolkata"));
        Timestamp startOfDay = Timestamp.valueOf(today.atStartOfDay());
        Timestamp endOfDay = Timestamp.valueOf(today.atTime(23, 59, 59));

        Optional<Attendance> existingAttendance = attendanceRepository.findByStudentAndTimestampBetween(student, startOfDay, endOfDay);

        return existingAttendance.isPresent();
    }

    @Override
    public List<Student> attendanceRecord(LocalDate date) {

        Timestamp startOfDay = Timestamp.valueOf(date.atStartOfDay());
        Timestamp endOfDay = Timestamp.valueOf(date.atTime(23, 59, 59, 999999999));

        List<Attendance> attendanceList = attendanceRepository.findByTimestampBetween(startOfDay, endOfDay);

        return attendanceList.stream()
                .map(Attendance::getStudent)
                .toList();
    }
}
