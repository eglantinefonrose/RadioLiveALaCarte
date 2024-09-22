package com.proutechos.utils.server.rest.config.jaxrs.exceptionstoresponsemappers;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jakarta.ws.rs.WebApplicationException;


/**
 * 
 */
public class ProutechosRestAPIsExceptionMapper_WebApplicationException extends BaseProutechosRestAPIsExceptionMapper<WebApplicationException> {

    private static Logger logger = LoggerFactory.getLogger(ProutechosRestAPIsExceptionMapper_WebApplicationException.class);

    
    @Override
    protected RestErrorResponseEntity buildResponseEntity(WebApplicationException webApplicationException) {
        // Most of the time, the WebApplicationException(s) are wrapper for a nested exception which contains the description of the issue.
        //  - Try to extract the nestedException here, if it exists
        Throwable nestedException = webApplicationException.getCause();
        //  - Build the error message
        String errorMessage = (nestedException==null) ?
            String.format("Proutechos unexpected error with message=[%s] for exception=[%s]",  webApplicationException.getMessage(), webApplicationException.getClass().getSimpleName()) :
            String.format("Proutechos unexpected error with message=[%s] for nestedException=[%s]",    nestedException.getMessage(),         nestedException.getClass().getSimpleName());
        String userErrorMessage = String.format("%s", webApplicationException.getMessage());
        // Build the response
        RestErrorResponseEntity response = new RestErrorResponseEntity(
            "TEE-UNXPCTD-ERR-LVL2",
            errorMessage,
            userErrorMessage,
            webApplicationException);
        return response;
    }


    @Override
    protected Logger getLogger() {
        return logger;
    }

}

