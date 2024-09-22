package com.proutechos.utils.server.rest.config.jaxrs.exceptionstoresponsemappers;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


/**
 * 
 */
public class ProutechosRestAPIsExceptionMapper_Exception extends BaseProutechosRestAPIsExceptionMapper<Exception> {

    private static Logger logger = LoggerFactory.getLogger(ProutechosRestAPIsExceptionMapper_Exception.class);

    
    @Override
    protected RestErrorResponseEntity buildResponseEntity(Exception genericJavaException) {
        // Most of the time, the Exception(s) are wrapper for a nested exception which contains the description of the issue.
        //  - Try to extract the nestedException here, if it exists
        Throwable nestedException = genericJavaException.getCause();
        //  - Build the error message
        String errorMessage = (nestedException==null) ?
            String.format("Proutechos unexpected error with message=[%s] for exception=[%s]",     genericJavaException.getMessage(), genericJavaException.getClass().getSimpleName()) :
            String.format("Proutechos unexpected error with message=[%s] for nestedException=[%s]",    nestedException.getMessage(),      nestedException.getClass().getSimpleName());
        String userErrorMessage = String.format("%s", genericJavaException.getMessage());
        // Build the response
        RestErrorResponseEntity response = new RestErrorResponseEntity(
            "TEE-UNXPCTD-ERR-LVL1",
            errorMessage,
            userErrorMessage,
            genericJavaException);
        return response;
    }


    @Override
    protected Logger getLogger() {
        return logger;
    }

}

