package com.pec.attendance.repository;

import com.pec.attendance.model.Attendance;
import com.pec.attendance.model.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.util.Optional;

@Repository
public interface AttendanceRepository extends JpaRepository<Attendance, Long> {
    Optional<Attendance> findByStudentAndTimestampBetween(Student student, Timestamp startOfDay, Timestamp endOfDay);
}
