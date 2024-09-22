package com.proutechos.sandbox.radiolivealacarte.server.services;
import java.io.File;
import java.io.FileInputStream;
import java.io.OutputStream;

import com.proutechos.sandbox.radiolivealacarte.server.service.RadioStreamingService;
import jakarta.ws.rs.core.Response;
import org.junit.jupiter.api.Test;

import javax.ws.rs.core.StreamingOutput;
import java.io.IOException;

class RadioLiveALaCarteServiceTest {

    @Test
    public void programRecording() {
        RadioStreamingService.getInstance().recordRadio();
    }

    @Test
    public Response testMP3() {
        String filePath = "/Users/eglantine/Dev/0.perso/2.Proutechos/8.RadioStreaming/0.RadioStreamingJavaServer/sore.mp3";
        File mp3File = new File(filePath);

        if (!mp3File.exists()) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("Fichier non trouvé")
                    .build();
        }

        // Utiliser StreamingOutput pour gérer le flux de données
        StreamingOutput stream = new StreamingOutput() {
            @Override
            public void write(OutputStream output) throws IOException {
                try (FileInputStream inputStream = new FileInputStream(mp3File)) {
                    byte[] buffer = new byte[4096]; // Lire le fichier par morceaux
                    int bytesRead;
                    while ((bytesRead = inputStream.read(buffer)) != -1) {
                        output.write(buffer, 0, bytesRead);
                    }
                    output.flush();
                }
            }
        };

        // Retourner la réponse avec le flux de données
        return Response.ok(stream, "audio/mpeg")
                .header("Content-Disposition", "attachment; filename=\"" + mp3File.getName() + "\"")
                .build();
    }

}