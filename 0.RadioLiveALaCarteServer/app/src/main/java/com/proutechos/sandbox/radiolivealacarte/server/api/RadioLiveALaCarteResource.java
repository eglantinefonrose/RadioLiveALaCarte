package com.proutechos.sandbox.radiolivealacarte.server.api;

import com.proutechos.sandbox.radiolivealacarte.server.model.LightenedRadioStationAndAmountOfResponses;
import com.proutechos.sandbox.radiolivealacarte.server.model.Program;
import com.proutechos.sandbox.radiolivealacarte.server.model.RadioStation;
import com.proutechos.sandbox.radiolivealacarte.server.model.UserModel;
import com.proutechos.sandbox.radiolivealacarte.server.service.FeedbackService;
import com.proutechos.sandbox.radiolivealacarte.server.service.RadioLiveALaCarteDataStorage;
import com.proutechos.sandbox.radiolivealacarte.server.service.RadioLiveALaCarteUserService;
import com.proutechos.sandbox.radiolivealacarte.server.service.ia.TrimingWithIAService;
import com.proutechos.sandbox.radiolivealacarte.server.service.planning.RadioInformationAndPlanningService;
import com.proutechos.sandbox.radiolivealacarte.server.service.recording.RadioRecordingSchedulerService;
import com.proutechos.sandbox.radiolivealacarte.server.service.recording.RecordName;
import com.proutechos.sandbox.radiolivealacarte.server.service.streaming.StreamingService;
import com.proutechos.utils.server.rest.config.exceptions.ProutechosBaseException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.ws.rs.*;
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

import static org.quartz.JobBuilder.newJob;

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
        return RadioInformationAndPlanningService.getInstance().getAllCountries();
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
        return RadioInformationAndPlanningService.getInstance().searchByName(name);
    }

    /**
     * curl -s -X GET "http://localhost:8287/api/radio/lightenSearchByName/FranceInter"
     * param name
     * @return
     */
    @GET
    @Path("lightenSearchByName/{name}")
    @Produces(MediaType.APPLICATION_JSON)
    public LightenedRadioStationAndAmountOfResponses lightenSearchByName(@PathParam("name") String name) throws Exception {
        return RadioInformationAndPlanningService.getInstance().lightenSearchByName(name);
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

    /**
     * curl -s -X GET "http://localhost:8287/api/radio/getAllCountries"
     * @return
     */
    @GET
    @Path("getDailyProgramsNames")
    @Produces(MediaType.APPLICATION_JSON)
    public String[] getDailyProgramsNames() throws Exception {
        return RadioInformationAndPlanningService.getInstance().getDailyProgramsNames();
    }

    @GET
    @Path("/createUser/firstName/{firstName}/lastName/{lastName}")
    @Produces(MediaType.APPLICATION_JSON)
    public String createUser(@PathParam("firstName") String firstName, @PathParam("lastName") String lastName) throws ProutechosBaseException {

        try {
            UserModel user = new UserModel("1", firstName, lastName);
            return RadioLiveALaCarteUserService.getInstance().createAccount(user);
        } catch (ProutechosBaseException e) {
            throw e;
        }

    }

    @GET
    @Path("/getUserByID/userID/{userID}")
    @Produces(MediaType.APPLICATION_JSON)
    public UserModel getUserByID(@PathParam("userID") String userId) throws ProutechosBaseException {
        try {
            return RadioLiveALaCarteUserService.getInstance().getUserByID(userId);
        } catch (ProutechosBaseException e) {
            throw e;
        }
    }

    @GET
    @Path("/doesUserExists/userId/{userId}")
    @Produces(MediaType.APPLICATION_JSON)
    public Boolean doesUserExists(@PathParam("userId") String userId) throws ProutechosBaseException {

        try {
            return RadioLiveALaCarteUserService.getInstance().doesUserExists(userId);
        } catch (ProutechosBaseException e) {
            throw e;
        }

    }

    @POST
    @Path("/addUserProgram/userId/{userId}/programId/{programId}")
    public void addUserProgram(@PathParam("userId") String userId, @PathParam("programId") String programId) throws ProutechosBaseException {

        try {
            RadioLiveALaCarteUserService.getInstance().addUserProgram(userId, programId);
        } catch (ProutechosBaseException e) {
            throw e;
        }

    }

    @GET
    @Path("/getProgramsByUser/userId/{userId}")
    @Produces(MediaType.APPLICATION_JSON)
    public Program[] getProgramsByUser(@PathParam("userId") String userId) throws ProutechosBaseException {

        try {
            return RadioLiveALaCarteUserService.getInstance().getProgramsByUserId(userId);
        } catch (ProutechosBaseException e) {
            throw e;
        }

    }

    @POST
    @Path("/recordProgram/programId/{programId}/radioName/{radioName}/startTimeHour/{startTimeHour}/startTimeMinute/{startTimeMinute}/startTimeSeconds/{startTimeSeconds}/endTimeHour/{endTimeHour}/endTimeMinute/{endTimeMinute}/endTimeSeconds/{endTimeSeconds}/danielMorinVersion/{danielMorinVersion}")
    public void recordProgram(@PathParam("programId") String programId, @PathParam("radioName") String radioName, @PathParam("startTimeHour") int startTimeHour, @PathParam("startTimeMinute") int startTimeMinute, @PathParam("startTimeSeconds") int startTimeSeconds, @PathParam("endTimeHour") int endTimeHour, @PathParam("endTimeMinute") int endTimeMinute, @PathParam("endTimeSeconds") int endTimeSeconds, @PathParam("danielMorinVersion") int danielMorinVersion) throws ProutechosBaseException {

        try {
            Program program = new Program(programId, radioName, startTimeHour, startTimeMinute, startTimeSeconds, endTimeHour, endTimeMinute, endTimeSeconds);
            RadioRecordingSchedulerService.getInstance().recordProgram(program, danielMorinVersion);
        } catch (ProutechosBaseException e) {
            throw e;
        }

    }

    @GET
    @Path("/getSuitableFileNameByProgramId/programId/{programId}")
    @Produces(MediaType.APPLICATION_JSON)
    public RecordName getSuitableFileNameByProgramId(@PathParam("programId") String programId) throws ProutechosBaseException {

        try {
            return RadioLiveALaCarteUserService.getInstance().getSuitableFileNameByProgramId(programId);
        } catch (ProutechosBaseException e) {
            throw e;
        }

    }

    @GET
    @Path("/getFilesWithoutSegmentNamesList/userId/{userId}")
    @Produces(MediaType.APPLICATION_JSON)
    public String[] getFilesWithoutSegmentNamesList(@PathParam("userId") String userId) throws ProutechosBaseException {

        try {
            return RadioLiveALaCarteUserService.getInstance().getFilesWithoutSegmentNamesList(userId);
        } catch (ProutechosBaseException e) {
            throw e;
        }

    }

    @GET
    @Path("/getFileWithSegmentBaseURL/userId/{userId}")
    @Produces(MediaType.APPLICATION_JSON)
    public BaseURLName getFileWithSegmentNamesList(@PathParam("userId") String userId) throws ProutechosBaseException {

        try {

            String name = RadioLiveALaCarteUserService.getInstance().getFileWithSegmentBaseURL(userId);
            return new BaseURLName(name);

        } catch (ProutechosBaseException e) {
            throw e;
        }
    }

    /**
     * curl -s -X POST "http://localhost:8287/api/radio/createAndRecordProgram/radioName/FranceInter/startTimeHour/15/startTimeMinute/31/startTimeSeconds/0/endTimeHour/15/endTimeMinute/33/endTimeSeconds/0/userID/aa768288-7621-49c8-99bd-c33c6fc02cc5"
     * @return
     */
    @POST
    @Path("/createAndRecordProgram/radioName/{radioName}/startTimeHour/{startTimeHour}/startTimeMinute/{startTimeMinute}/startTimeSeconds/{startTimeSeconds}/endTimeHour/{endTimeHour}/endTimeMinute/{endTimeMinute}/endTimeSeconds/{endTimeSeconds}/userID/{userID}/danielMorinVersion/{danielMorinVersion}")
    public void recordProgram(@PathParam("radioName") String radioName, @PathParam("startTimeHour") int startTimeHour, @PathParam("startTimeMinute") int startTimeMinute, @PathParam("startTimeSeconds") int startTimeSeconds, @PathParam("endTimeHour") int endTimeHour, @PathParam("endTimeMinute") int endTimeMinute, @PathParam("endTimeSeconds") int endTimeSeconds, @PathParam("userID") String userID, @PathParam("danielMorinVersion") Integer danielMorinVersion) throws ProutechosBaseException {

        try {

            Program program = new Program("programId", radioName, startTimeHour, startTimeMinute, startTimeSeconds, endTimeHour, endTimeMinute, endTimeSeconds);

            String programID = RadioLiveALaCarteUserService.getInstance().createProgram(program);
            RadioLiveALaCarteUserService.getInstance().addUserProgram(userID, programID);

            Program justCreatedProgram = RadioLiveALaCarteUserService.getInstance().getProgramByID(programID);
            RadioRecordingSchedulerService.getInstance().recordProgram(justCreatedProgram, danielMorinVersion);

            RadioRecordingSchedulerService.getInstance().scheduleWake(startTimeHour+":"+startTimeMinute+":"+startTimeSeconds);

        } catch (ProutechosBaseException e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }

    }

    @GET
    @Path("/concateneFile/baseName/{baseName}")
    @Produces(MediaType.APPLICATION_JSON)
    public Integer getConcatenedFile(@PathParam("baseName") String baseName)  throws IOException, InterruptedException {

        return StreamingService.getInstance().concatene(baseName);

    }

    @GET
    @Path("/getFavIcoByRadioName/radioName/{radioName}")
    @Produces(MediaType.APPLICATION_JSON)
    public String getFavIcoByRadioName(@PathParam("radioName") String radioName)  throws Exception {

        return RadioInformationAndPlanningService.getInstance().getFavIcoByRadioName(radioName);

    }

    @POST
    @Path("/deleteProgram/programId/{programId}")
    @Produces(MediaType.APPLICATION_JSON)
    public void deleteProgram(@PathParam("programId") String programId)  throws Exception {

        try {
            RadioLiveALaCarteUserService.getInstance().deleteProgram(programId);
        } catch (ProutechosBaseException e) {
            throw e;
        }

    }

    @POST
    @Path("/createFeedback/programID/{programID}/feedback/{feedback}")
    @Produces(MediaType.APPLICATION_JSON)
    public void createFeedback(@PathParam("programID") String programID, @PathParam("feedback") String feedback)  throws Exception {

        try {
            FeedbackService.getInstance().createFeedback(programID, feedback);
        } catch (ProutechosBaseException e) {
            throw e;
        }

    }

    @POST
    @Path("/deleteFeedback/programID/{programID}")
    @Produces(MediaType.APPLICATION_JSON)
    public void deleteFeedback(@PathParam("programID") String programID)  throws Exception {

        try {
            FeedbackService.getInstance().deleteFeedback(programID);
        } catch (ProutechosBaseException e) {
            throw e;
        }

    }

    @GET
    @Path("/getFeedback/programID/{programID}")
    @Produces(MediaType.APPLICATION_JSON)
    public String getFeedback(@PathParam("programID") String programID)  throws Exception {

        try {
            return FeedbackService.getInstance().getFeedback(programID);
        } catch (ProutechosBaseException e) {
            throw e;
        }

    }*/

}
