package com.pec.attendance.service;

import com.pec.attendance.exceptions.*;
import com.pec.attendance.model.Attendance;
import com.pec.attendance.model.Student;
import com.pec.attendance.repository.AttendanceRepository;
import com.pec.attendance.repository.StudentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class AttendanceService implements ServiceInterface {

    @Autowired
    private AttendanceRepository attendanceRepository;

    @Autowired
    private StudentRepository studentRepository;

    private Timestamp getStartOfDay(LocalDate date) {
        return Timestamp.valueOf(date.atStartOfDay());
    }

    private Timestamp getEndOfDay(LocalDate date) {
        return Timestamp.valueOf(date.atTime(23, 59, 59));
    }

    @Override
    public Attendance markAttendance(String rollNumber) {

        Optional<Student> studentOptional = studentRepository.findByRollNumber(rollNumber);

        if (studentOptional.isEmpty()) {
            throw new StudentNotFoundException(rollNumber);
        }

        Student student = studentOptional.get();

        LocalDate today = LocalDate.now(ZoneId.of("Asia/Kolkata"));
        Timestamp startOfDay = Timestamp.valueOf(today.atStartOfDay());
        Timestamp endOfDay = Timestamp.valueOf(today.atTime(23, 59, 59));

        Optional<Attendance> existingAttendance = attendanceRepository.findByStudentAndTimestampBetween(student, startOfDay, endOfDay);

        if (existingAttendance.isPresent()) {
            throw new AttendanceNotFoundException(rollNumber);
        }

        try {
            Attendance attendanceRecord = new Attendance()
                    .setStudent(student)
                    .setTimeStamp(new Timestamp(System.currentTimeMillis()));

            return attendanceRepository.save(attendanceRecord);
        } catch (Exception e) {
            throw new GenericServiceException("Error while saving attendance for roll number: " + rollNumber, e);
        }
    }

    @Override
    public boolean hasAttendanceForToday(String rollNumber) {
        Optional<Student> studentOptional = studentRepository.findByRollNumber(rollNumber);

        if (studentOptional.isEmpty()) {
            throw new StudentNotFoundException(rollNumber);
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
        try {
            Timestamp startOfDay = getStartOfDay(date);
            Timestamp endOfDay = getEndOfDay(date);

            List<Attendance> attendanceList = attendanceRepository.findByTimestampBetween(startOfDay, endOfDay);

            return attendanceList.stream()
                    .map(Attendance::getStudent)
                    .collect(Collectors.toList());
        } catch (Exception e) {
            throw new GenericServiceException("Error while fetching attendance records for date: " + date, e);
        }
    }

    @Override
    public List<Student> absenteeRecord(LocalDate date) {
        try {
            Timestamp startOfDay = getStartOfDay(date);
            Timestamp endOfDay = getEndOfDay(date);

            List<Attendance> attendanceList = attendanceRepository.findByTimestampBetween(startOfDay, endOfDay);
            List<Student> presentStudents = attendanceList.stream()
                    .map(Attendance::getStudent)
                    .collect(Collectors.toList());

            return studentRepository.findAll().stream()
                    .filter(student -> !presentStudents.contains(student))
                    .collect(Collectors.toList());
        } catch (Exception e) {
            throw new GenericServiceException("Error while fetching absentee records for date: " + date, e);
        }
    }
}
