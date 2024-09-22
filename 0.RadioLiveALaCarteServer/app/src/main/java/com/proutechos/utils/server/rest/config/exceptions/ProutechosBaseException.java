package com.proutechos.utils.server.rest.config.exceptions;

public class ProutechosBaseException extends Exception {

    public ProutechosBaseException(String message) {
        super(message);
    }

    public ProutechosBaseException(String message, Throwable rootException) {
        super(message, rootException);
    }

}
