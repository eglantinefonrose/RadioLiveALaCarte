package com.proutechos.utils.server.rest.config.jaxrs;

import com.proutechos.utils.server.rest.config.jaxrs.exceptionstoresponsemappers.*;
import org.glassfish.jersey.server.ResourceConfig;


public class JerseyConfig  extends ResourceConfig {
    
    public JerseyConfig() {

        //
        // Configure Resources exposed via Jersey
        //
        //    - OpenAPI generation servlet (needed for the OpenAPI interface generation from JAXRS described resources)
        this.packages("io.swagger.v3.jaxrs2.integration.resources");
        this.packages("io.swagger.jaxrs.json");
        this.packages("io.swagger.jaxrs.listing");
        //    - Proutechos REST Resources
        this.packages("com.proutechos");

        //
        // Configure Exception Handlers to tune result returned (response) to errors
        //
        // - ProutechosExceptions
        this.register(ProutechosRestAPIsExceptionMapper_ProutechosBaseException.class);     // TEE-BIZNESS-ERR
        // - Generic exceptions
        this.register(ProutechosRestAPIsExceptionMapper_WebApplicationException.class);  // TEE-UNXPCTD-ERR-LVL2
        this.register(ProutechosRestAPIsExceptionMapper_Exception.class);                // TEE-UNXPCTD-ERR-LVL1
        this.register(ProutechosRestAPIsExceptionMapper_RuntimeException.class);         // TEE-UNXPCTD-ERR-LVL0
        this.register(ProutechosRestAPIsExceptionMapper_Error.class);                    // TEE-UNXPCTD-ERR-LVL0
        this.register(ProutechosRestAPIsExceptionMapper_JsonMappingException.class);     // TEE-JSONMAPPING-ERR-LVL0


//        //
//        // Configure Logging of requests and their payloads
//        //
//        Logger logger = Logger.getLogger("com.proutechos.sandbox.piggybank.server");
//        Level level = null;
//        Verbosity verbosity = LoggingFeature.Verbosity.PAYLOAD_ANY;
//        Integer maxEntitySize = null;
//        this.register(new LoggingFeature(logger, level, verbosity, maxEntitySize));
    }

}
