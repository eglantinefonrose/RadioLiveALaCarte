package com.proutechos.utils.server.rest.config.jaxrs.exceptionstoresponsemappers;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.proutechos.utils.server.rest.config.exceptions.ProutechosBaseException;


/**
 * 
 */
public class ProutechosRestAPIsExceptionMapper_ProutechosBaseException extends BaseProutechosRestAPIsExceptionMapper<ProutechosBaseException> {

    private static Logger logger = LoggerFactory.getLogger(ProutechosRestAPIsExceptionMapper_RuntimeException.class);

    
    @Override
    protected RestErrorResponseEntity buildResponseEntity(ProutechosBaseException teevityBaseException) {
        Throwable nestedException = teevityBaseException.getCause();
        //  - Build the error message
        String errorMessage = (nestedException==null) ?
            String.format("Proutechos Service error with message=[%s] for exception=[%s]",      teevityBaseException.getMessage(), teevityBaseException.getClass().getSimpleName()) :
            String.format("Proutechos Service error with message=[%s] for nestedException=[%s]", nestedException.getMessage(),  nestedException.getClass().getSimpleName());
        String userErrorMessage = String.format("%s", teevityBaseException.getMessage());
        // Build the response
        RestErrorResponseEntity response = new RestErrorResponseEntity(
            "PRT-GNRICBIZNESS-ERR",
            errorMessage,
            userErrorMessage,
            teevityBaseException);
        return response;
    }

    @Override
    protected Logger getLogger() {
        return logger;
    }

}

