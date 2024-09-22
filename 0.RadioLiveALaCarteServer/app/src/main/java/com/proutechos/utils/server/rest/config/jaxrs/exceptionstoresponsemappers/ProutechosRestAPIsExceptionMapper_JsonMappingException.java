package com.proutechos.utils.server.rest.config.jaxrs.exceptionstoresponsemappers;

import com.fasterxml.jackson.databind.JsonMappingException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


/**
 * 
 */
public class ProutechosRestAPIsExceptionMapper_JsonMappingException extends BaseProutechosRestAPIsExceptionMapper<JsonMappingException> {

    private static Logger logger = LoggerFactory.getLogger(ProutechosRestAPIsExceptionMapper_JsonMappingException.class);

    
    @Override
    protected RestErrorResponseEntity buildResponseEntity(JsonMappingException javaJsonMappingException) {
        // Most of the time, the Exception(s) are wrapper for a nested exception which contains the description of the issue.
        //  - Try to extract the nestedException here, if it exists
        Throwable nestedException = javaJsonMappingException.getCause();
        //  - Build the error message
        String errorMessage = (nestedException==null) ?
            String.format("Proutechos JsonMappingException with message=[%s] for exception=[%s]",       javaJsonMappingException.getMessage(),       javaJsonMappingException.getClass().getSimpleName()) :
            String.format("Proutechos JsonMappingException with message=[%s] for nestedException=[%s]", nestedException.getMessage(), nestedException.getClass().getSimpleName());
        String userErrorMessage = String.format("%s", javaJsonMappingException.getMessage());
        // Build the response
        RestErrorResponseEntity response = new RestErrorResponseEntity(
            "TEE-JSONMAPPING-ERR-LVL0",
            errorMessage,
            userErrorMessage,
            javaJsonMappingException);
        return response;
    }


    @Override
    protected Logger getLogger() {
        return logger;
    }

}

