package com.proutechos.utils.server.rest.config.jaxrs.exceptionstoresponsemappers;

import org.slf4j.Logger;

import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;

import java.util.ArrayList;


public abstract class BaseProutechosRestAPIsExceptionMapper<T extends Throwable>  implements ExceptionMapper<T> {

    /**
     * Return the Logger specific to the subclass
     */
    protected abstract Logger getLogger();

    /**
     * Build the body/entity of the Response that will be sent for this exception
     * @param runtimeException
     * @return
     */
    protected abstract RestErrorResponseEntity buildResponseEntity(T exception);


    /**
     * Build a custom response for RuntimeException
     * 
     * REMARK: We could also build a text/plain response
     *   return Response.status(status)
     *     .entity(status + ": " + message)
     *     .type(MediaType.TEXT_PLAIN)
     *     .build();
     * 
     */
    @Override
    public Response toResponse(T exception) {
        // Create the "Error response body"
        RestErrorResponseEntity restErrorResponseEntity = buildResponseEntity(exception);

        // Standardized server-side loggin of errors returned by the Proutechos APIs
        this.logError(getLogger(), exception, restErrorResponseEntity);

        // Return the HTTP response with a 418 (I'm a Teapot) status code
        Response response = Response.status(418)
          .entity(restErrorResponseEntity)
          .type(MediaType.APPLICATION_JSON)
          .build();
        return response;
    }
     
    /**
     * Log the error in a standardized way
     * @param zeLogger
     * @param zeException
     */
    public void logError(Logger zeLogger, Throwable zeException, RestErrorResponseEntity restErrorResponseEntity) {
        zeLogger.error("ProutechosStandardizedErrorReporting.teeErrorUUID[{}].teeErrorCode[{}] errorMessage - {}", restErrorResponseEntity.getPrtErrorUUID(), restErrorResponseEntity.getPrtErrorCode(), restErrorResponseEntity.getPrtErrorMessage());
        zeLogger.error("ProutechosStandardizedErrorReporting.teeErrorUUID[{}].teeErrorCode[{}] errorDetails - {}",  restErrorResponseEntity.getPrtErrorUUID(), restErrorResponseEntity.getPrtErrorCode(), restErrorResponseEntity.getPrtErrorDetails());
    }

}
