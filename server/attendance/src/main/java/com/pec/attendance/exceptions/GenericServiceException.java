package com.pec.attendance.exceptions;

public class GenericServiceException extends RuntimeException {
    public GenericServiceException(String message, Throwable cause) {
        super(message, cause);
    }
}
