package com.proutechos.utils.server.rest.config.staticcontentserving;

import com.google.common.io.ByteStreams;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.nio.file.Files;

/**
 * Needed to serve static resources for Tomcat. Not needed for Jetty.
 *
 * Created by cassius on 29/04/14.
 */
/*public class StaticContentServlet extends HttpServlet {

    private static final Logger log = LoggerFactory.getLogger(StaticContentServlet.class);

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {

        System.out.printf("resourcePath=[%s] -> turned into [/static/media%s]%n", req.getPathInfo(), req.getPathInfo());
        String resourceRequestPath = req.getPathInfo();
        if ("/".equals(resourceRequestPath)) {
            resourceRequestPath = "/index.html";
        }
        String resourcePath = String.format("/static/media%s", resourceRequestPath);

        URL resource = getClass().getResource(resourcePath);

        log.debug(String.format("Requesting static resource %s", resourcePath));

        if (resource == null) {
            resp.setContentType("text/plain");
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            resp.getWriter().write("Not Found");
            resp.getWriter().close();
        } else {
            resp.setContentType(getContentType(req.getPathInfo()));
            ByteStreams.copy(getClass().getResourceAsStream(resourcePath), resp.getOutputStream());
            resp.getOutputStream().close();
        }
    }

    private String getContentType(String fileName) {
        if (fileName.endsWith("js")) {
            return "application/javascript";
        } else if (fileName.endsWith("css")) {
            return "text/css";
        } else if (fileName.endsWith("ico")) {
            return "image/x-icon";
        } else {
            // This code causes 'java.lang.ClassNotFoundException: com.sun.activation.registries.LogSupport' at Runtime
            //    String contentType = URLConnection.guessContentTypeFromName(fileName);
            //    return contentType != null ? contentType : FileTypeMap.getDefaultFileTypeMap().getContentType(fileName);
            return "";
        }
    }
}*/

public class StaticContentServlet extends HttpServlet {

    private static final Logger log = LoggerFactory.getLogger(StaticContentServlet.class);

    // Remplace ce chemin par celui où tes fichiers sont stockés sur ton système
    private static final String BASE_DIRECTORY = "/Users/eglantine/Dev/0.perso/2.Proutechos/8.RadioStreaming/0.RadioLiveALaCarteServer/app/src/main/resources/static/media";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {

        System.out.printf("resourcePath=[%s] -> turned into [%s%s]%n", req.getPathInfo(), BASE_DIRECTORY, req.getPathInfo());
        String resourceRequestPath = req.getPathInfo();
        if ("/".equals(resourceRequestPath)) {
            resourceRequestPath = "/index.html";
        }

        // Concatène le chemin vers ton répertoire de fichiers avec la requête de fichier
        String resourcePath = BASE_DIRECTORY + resourceRequestPath;

        File resource = new File(resourcePath);

        log.debug(String.format("Requesting static resource %s", resourcePath));

        if (!resource.exists()) {
            resp.setContentType("text/plain");
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            resp.getWriter().write("Not Found");
            resp.getWriter().close();
        } else {
            resp.setContentType(getContentType(req.getPathInfo()));
            Files.copy(resource.toPath(), resp.getOutputStream());
            resp.getOutputStream().close();
        }
    }

    private String getContentType(String fileName) {
        if (fileName.endsWith("js")) {
            return "application/javascript";
        } else if (fileName.endsWith("css")) {
            return "text/css";
        } else if (fileName.endsWith("ico")) {
            return "image/x-icon";
        } else if (fileName.endsWith("mp3")) {
            return "audio/mpeg";
        } else {
            return "application/octet-stream";  // Par défaut si le type de contenu est inconnu
        }
    }
}

