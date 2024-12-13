package com.pec.attendance.controller;

import com.pec.attendance.dto.MarkAttendanceRequest;
import com.pec.attendance.dto.Response;
import com.pec.attendance.model.Attendance;
import com.pec.attendance.model.Student;
import com.pec.attendance.service.ServiceInterface;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class Controller {

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
    public ResponseEntity<Response<Attendance>> checkIn(@RequestBody MarkAttendanceRequest request){

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
}
