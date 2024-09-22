package com.proutechos.utils.server.rest.config.jaxrs.exceptionstoresponsemappers;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


/**
 * 
 */
public class ProutechosRestAPIsExceptionMapper_RuntimeException extends BaseProutechosRestAPIsExceptionMapper<RuntimeException> {

    private static Logger logger = LoggerFactory.getLogger(ProutechosRestAPIsExceptionMapper_RuntimeException.class);

    
    @Override
    protected RestErrorResponseEntity buildResponseEntity(RuntimeException runtimeException) {
        // Most of the time, the RuntimeException(s) are wrapper for a nested exception which contains the description of the issue.
        //  - Try to extract the nestedException here, if it exists
        Throwable nestedException = runtimeException.getCause();
        //  - Build the error message
        String errorMessage = (nestedException==null) ?
            String.format("Proutechos unexpected error with message=[%s] for exception=[%s]",      runtimeException.getMessage(), runtimeException.getClass().getSimpleName()) :
            String.format("Proutechos unexpected error with message=[%s] for nestedException=[%s]", nestedException.getMessage(),  nestedException.getClass().getSimpleName());
        String userErrorMessage = String.format("%s", runtimeException.getMessage());
        // Build the response
        RestErrorResponseEntity response = new RestErrorResponseEntity(
            "TEE-UNXPCTD-ERR-LVL0",
            errorMessage,
            userErrorMessage,
            runtimeException);
        return response;
    }

    @Override
    protected Logger getLogger() {
        return logger;
    }

}

