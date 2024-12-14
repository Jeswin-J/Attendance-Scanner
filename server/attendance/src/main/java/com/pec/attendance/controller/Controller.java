package com.pec.attendance.controller;

import com.pec.attendance.dto.MarkAttendanceRequest;
import com.pec.attendance.dto.Response;
import com.pec.attendance.model.Attendance;
import com.pec.attendance.model.Student;
import com.pec.attendance.service.ServiceInterface;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

@RestController
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class Controller {

    private static final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");


    @Autowired
    private ServiceInterface attendanceService;

    @GetMapping("/")
    public ResponseEntity<Response<String>> sayHello() {
        return ResponseEntity.status(HttpStatus.OK).body(
                new Response<String>()
                        .setSuccess(true)
                        .setMessage("System Working Fine!")
                        .setStatusCode(0)
                        .setData("Hello World!")
        );
    }

    @PostMapping("/checkIn")
    public synchronized ResponseEntity<Response<Attendance>> checkIn(@RequestBody MarkAttendanceRequest request){
        System.out.println("HERE!!");
        if(attendanceService.hasAttendanceForToday(request.getRollNumber())){
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                    new Response<Attendance>()
                            .setSuccess(false)
                            .setMessage("Attendance Marked Already!")
                            .setStatusCode(-1)
                            .setData(null)
            );
        }

        Attendance info = attendanceService.markAttendance(request.getRollNumber());

        if(info != null){
            return ResponseEntity.status(HttpStatus.OK).body(
                    new Response<Attendance>()
                            .setSuccess(true)
                            .setMessage("Attendance Marked Successfully!")
                            .setStatusCode(0)
                            .setData(info)
            );
        }

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                new Response<Attendance>()
                        .setSuccess(false)
                        .setMessage("Invalid Attendance Request!")
                        .setStatusCode(1)
                        .setData(null)
        );
    }

    @GetMapping("/{date}")
    public ResponseEntity<Response<List<Student>>> viewRecordByDate(@PathVariable("date") String dateString){
        LocalDate date = LocalDate.parse(dateString, formatter);
        List<Student> studentsList = attendanceService.attendanceRecord(date);

        System.out.println("HERE");

        return ResponseEntity.status(HttpStatus.OK).body(
                new Response<List<Student>>()
                        .setSuccess(true)
                        .setMessage("Attendance Record dated " + date +  "!")
                        .setStatusCode(0)
                        .setData(studentsList)
        );
    }

    @GetMapping("/absentees/{date}")
    public ResponseEntity<Response<List<Student>>> viewAbsentees(@PathVariable("date") String dateString){
        LocalDate date = LocalDate.parse(dateString, formatter);
        List<Student> studentsList = attendanceService.absenteeRecord(date);

        return ResponseEntity.status(HttpStatus.OK).body(
                new Response<List<Student>>()
                        .setSuccess(true)
                        .setMessage("Attendance Record dated " + date +  "!")
                        .setStatusCode(0)
                        .setData(studentsList)
        );
    }

    @PostMapping("/upload")
    public ResponseEntity<String> uploadFile(@RequestParam("file") MultipartFile file) {
        try {
            attendanceService.saveStudentsFromCsv(file);
            return ResponseEntity.ok("File uploaded and data saved successfully!");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Failed to upload file: " + e.getMessage());
        }
    }
}
