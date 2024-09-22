package com.proutechos.utils.server.rest.config.jaxrs.exceptionstoresponsemappers;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.UUID;

import java.util.List;
import java.util.Arrays;


/**
 * Class storing all the attributes for Proutechos Rest API errors reported to the caller
 */
public class RestErrorResponseEntity {

    private String prtErrorUUID;
    private String prtErrorCode;
    private String prtUserErrorMessage;
    private String prtErrorMessage;
    private List<String> prtErrorDetails;

    
    public RestErrorResponseEntity() {        
    }
    
    // public RestErrorResponseEntity(String teeErrorCode, String teeErrorMessage, String teeErrorDetails) {
    //     this.teeErrorUUID    = UUID.randomUUID().toString();
    //     this.teeErrorCode    = teeErrorCode;
    //     this.teeErrorMessage = teeErrorMessage;
    //     this.teeErrorDetails = teeErrorDetails;
    // }

    public RestErrorResponseEntity(String prtErrorCode, String prtErrorMessage, String prtUserErrorMessage, Throwable exceptionWhoseStacktraceWillBeStoredAsTeeErrorDetails) {
        this.prtErrorUUID = UUID.randomUUID().toString();
        this.prtErrorCode = prtErrorCode;
        this.prtErrorMessage = prtErrorMessage;
        this.prtUserErrorMessage = prtUserErrorMessage;
        this.prtErrorDetails = generateErrorDetailsFromExceptionStackTrace(exceptionWhoseStacktraceWillBeStoredAsTeeErrorDetails);
    }


    public String getPrtErrorUUID() {
        return this.prtErrorUUID;
    }

    public String getPrtErrorCode() {
        return this.prtErrorCode;
    }

    public void setErrorCode(String teeErrorCode) {
        this.prtErrorCode = teeErrorCode;
    }

    public String getPrtErrorMessage() {
        return this.prtErrorMessage;
    }

    public void setErrorMessage(String teeErrorMessage) {
        this.prtErrorMessage = teeErrorMessage;
    }

    public String getPrtUserErrorMessage() {
        return prtUserErrorMessage;
    }

    public void setPrtUserErrorMessage(String prtUserErrorMessage) {
        this.prtUserErrorMessage = prtUserErrorMessage;
    }

    public List<String> getPrtErrorDetails() {
        return this.prtErrorDetails;
    }

    public void setErrorDetails(List<String> teeErrorDetails) {
        this.prtErrorDetails = teeErrorDetails;
    }
    

    //
    //
    // IMPLEMENTATION
    //
    //

    private List<String> generateErrorDetailsFromExceptionStackTrace(Throwable exception) {
        // Turn the stacktrace into a List<String>
        //  - Dump the stacktrace to an in-memory String
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        exception.printStackTrace(printWriter);
        //  - Turn it into a list
        List<String> result = Arrays.asList(stringWriter.toString().split("\n"));
        return result;
    }

}
