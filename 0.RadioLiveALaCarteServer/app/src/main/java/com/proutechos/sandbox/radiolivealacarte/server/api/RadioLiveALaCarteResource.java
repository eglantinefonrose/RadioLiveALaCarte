package com.proutechos.sandbox.radiolivealacarte.server.api;

import com.proutechos.sandbox.radiolivealacarte.server.model.RadioStation;
import com.proutechos.sandbox.radiolivealacarte.server.service.RadioStreamingService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.Context;
import jakarta.ws.rs.core.HttpHeaders;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.io.IOException;
import javax.ws.rs.core.*;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;

@Path("/radio")
public class RadioLiveALaCarteResource {

    @Context HttpServletRequest request;

    /**
     * curl -s -X GET "http://localhost:8287/api/radio/getAllCountries"
     * @return
     */
    @GET
    @Path("getAllCountries")
    @Produces(MediaType.APPLICATION_JSON)
    public String getAllCountries() throws Exception {
        try {
            return RadioStreamingService.getInstance().getAllCountries();
        } catch (Exception e) {
            throw e;
        }
    }


    /**
     * curl -s -X GET "http://localhost:8287/api/radio/searchByName/FranceInter"
     * param name
     * @return
     */
    @GET
    @Path("searchByName/{name}")
    @Produces(MediaType.APPLICATION_JSON)
    public RadioStation[] searchByName(@PathParam("name") String name) throws Exception {
        try {
            return RadioStreamingService.getInstance().searchByName(name);
        } catch (Exception e) {
            throw e;
        }
    }

    private static final String STREAM_URL = "https://stream.radiofrance.fr/franceinter/franceinter_hifi.m3u8?id=radiofrance"; // URL du flux HLS

    @GET
    @Path("getStream")
    @Produces("audio/mpeg")
    public Response streamAudio(@Context HttpHeaders headers) throws IOException {
        URL url = new URL(STREAM_URL);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestProperty("Accept-Encoding", "identity"); // Pour éviter la compression

        final String RANGE;
        RANGE = "Range";

        long fileLength = connection.getContentLengthLong();
        String rangeHeader = headers.getHeaderString(RANGE);
        long start = 0;
        long end = fileLength - 1;

        if (rangeHeader != null && rangeHeader.startsWith("bytes=")) {
            String[] ranges = rangeHeader.substring("bytes=".length()).split("-");
            start = Long.parseLong(ranges[0]);
            if (ranges.length > 1 && !ranges[1].isEmpty()) {
                end = Long.parseLong(ranges[1]);
            }
            end = Math.min(end, fileLength - 1);
        }

        // Connexion pour obtenir le flux audio
        HttpURLConnection streamConnection = (HttpURLConnection) url.openConnection();
        streamConnection.setRequestProperty("Range", "bytes=" + start + "-" + end);

        // Créez une instance de la classe Helper pour stocker les variables modifiables
        final long[] bytesToRead = {end - start + 1};

        Response.ResponseBuilder responseBuilder = Response.ok((StreamingOutput) output -> {
            try (InputStream inputStream = streamConnection.getInputStream()) {
                byte[] buffer = new byte[4096];
                int bytesRead;
                while (bytesToRead[0] > 0 && (bytesRead = inputStream.read(buffer, 0, (int) Math.min(buffer.length, bytesToRead[0]))) != -1) {
                    output.write(buffer, 0, bytesRead);
                    bytesToRead[0] -= bytesRead;
                }
            }
        });

        // En-têtes HTTP pour la réponse
        responseBuilder.header(HttpHeaders.CONTENT_LENGTH, (end - start + 1));
        responseBuilder.header("Content-Range", "bytes " + start + "-" + end + "/" + fileLength);
        //responseBuilder.header(HttpHeaders.CONTENT_RANGE, "bytes " + start + "-" + end + "/" + fileLength);
        responseBuilder.header("Accept-Range", "bytes " + start + "-" + end + "/" + fileLength);

        return responseBuilder.build();
    }

    @GET
    @Produces("audio/mpeg")
    @Path("/getAudioTest")
    public Response getMp3File() {
        String filePath = "/Users/eglantine/Dev/0.perso/2.Proutechos/8.RadioStreaming/0.RadioStreamingJavaServer/sore.mp3";
        File mp3File = new File(filePath);

        if (!mp3File.exists()) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("Fichier non trouvé")
                    .build();
        }

        StreamingOutput stream = new StreamingOutput() {
            @Override
            public void write(OutputStream output) throws IOException {
                try (FileInputStream inputStream = new FileInputStream(mp3File)) {
                    byte[] buffer = new byte[8192]; // Buffer plus grand pour les données binaires
                    int bytesRead;
                    while ((bytesRead = inputStream.read(buffer)) != -1) {
                        output.write(buffer, 0, bytesRead);
                    }
                    output.flush(); // Important pour vider les données
                }
            }
        };

        return Response.ok(stream, "audio/mpeg")
                .header("Content-Disposition", "attachment; filename=\"" + mp3File.getName() + "\"")
                .build();
    }


}
