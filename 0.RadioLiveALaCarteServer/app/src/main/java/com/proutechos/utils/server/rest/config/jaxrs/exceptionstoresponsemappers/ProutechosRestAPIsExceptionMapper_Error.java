package com.proutechos.utils.server.rest.config.jaxrs.exceptionstoresponsemappers;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


/**
 * Handle exception that happens when JSON requests/response payload can't be mapped properly to the Java classes
 * declared in the JAX-RS REST resources
 * Cf https://mkyong.com/webservices/jax-rs/json-example-with-jersey-jackson/#custom-jsonmappingexception
 */
public class ProutechosRestAPIsExceptionMapper_Error extends BaseProutechosRestAPIsExceptionMapper<Error> {

    private static Logger logger = LoggerFactory.getLogger(ProutechosRestAPIsExceptionMapper_Error.class);

    
    @Override
    protected RestErrorResponseEntity buildResponseEntity(Error javaError) {
        // Most of the time, the Exception(s) are wrapper for a nested exception which contains the description of the issue.
        //  - Try to extract the nestedException here, if it exists
        Throwable nestedException = javaError.getCause();
        //  - Build the error message
        String errorMessage = (nestedException==null) ?
            String.format("Proutechos unexpected ERROR with message=[%s] for exception=[%s]",             javaError.getMessage(),       javaError.getClass().getSimpleName()) :
            String.format("Proutechos unexpected ERROR with message=[%s] for nestedException=[%s]", nestedException.getMessage(), nestedException.getClass().getSimpleName());
        String userErrorMessage = String.format("%s", javaError.getMessage());
        // Build the response
        RestErrorResponseEntity response = new RestErrorResponseEntity(
            "TEE-UNXPCTD-ERR-LVL0",
            errorMessage,
            userErrorMessage,
            javaError);
        return response;
    }


    @Override
    protected Logger getLogger() {
        return logger;
    }

}

