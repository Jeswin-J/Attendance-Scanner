package com.pec.attendance.service;

import com.pec.attendance.model.Attendance;
import com.pec.attendance.repository.AttendanceRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;

@Service
public class AttendanceService implements ServiceInterface {

    @Autowired
    private AttendanceRepository attendanceRepository;

    @Override
    public Attendance markAttendance(String rollNumber) {

        Attendance attendanceRecord = new Attendance()
                .setRollNumber(rollNumber)
                .setTimeStamp(new Timestamp(System.currentTimeMillis()));

        return attendanceRepository.save(attendanceRecord);
    }
}
