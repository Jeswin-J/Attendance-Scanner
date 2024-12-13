package com.pec.attendance.dto;


public class Response<T> {
    private boolean success;
    private String message;
    private Integer statusCode;
    private T data;

    public boolean isSuccess() {
        return success;
    }

    public Response<T> setSuccess(boolean success) {
        this.success = success;
        return this;
    }

    public String getMessage() {
        return message;
    }

    public Response<T> setMessage(String message) {
        this.message = message;
        return this;
    }

    public T getData() {
        return data;
    }

    public Response<T> setData(T data) {
        this.data = data;
        return this;
    }

    public Integer getStatusCode() {
        return statusCode;
    }

    public Response<T> setStatusCode(Integer statusCode) {
        this.statusCode = statusCode;
        return this;
    }

}
