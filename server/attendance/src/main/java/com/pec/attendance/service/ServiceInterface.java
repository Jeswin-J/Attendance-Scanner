package com.pec.attendance.service;

import com.pec.attendance.model.Attendance;
import org.springframework.stereotype.Service;

@Service
public interface ServiceInterface {
    Attendance markAttendance(String rollNumber);

    boolean hasAttendanceForToday(String rollNumber);
}
