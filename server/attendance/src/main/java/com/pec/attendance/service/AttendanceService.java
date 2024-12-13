package com.pec.attendance.service;

import com.pec.attendance.model.Attendance;
import com.pec.attendance.model.Student;
import com.pec.attendance.repository.AttendanceRepository;
import com.pec.attendance.repository.StudentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.util.Optional;

@Service
public class AttendanceService implements ServiceInterface {

    @Autowired
    private AttendanceRepository attendanceRepository;

    @Autowired
    private StudentRepository studentRepository;

    @Override
    public Attendance markAttendance(String rollNumber) {

        Optional<Student> student = studentRepository.findByRollNumber(rollNumber);

        if(student.isEmpty()){
            return null;
        }

        Attendance attendanceRecord = new Attendance()
                .setStudent(student.get())
                .setTimeStamp(new Timestamp(System.currentTimeMillis()));

        return attendanceRepository.save(attendanceRecord);
    }
}
