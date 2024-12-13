package com.pec.attendance.controller;

import com.pec.attendance.dto.Response;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class Controller {
    @GetMapping("/")
    public ResponseEntity<Response<String>> sayHello() {
        return ResponseEntity.status(HttpStatus.OK).body(
                new Response<String>()
                        .setSuccess(true)
                        .setMessage("System Working Fine!")
                        .setData("Hello World!")
        );
    }
}
