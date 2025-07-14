package com.proutechos.sandbox.radiolivealacarte.server.services;

import com.proutechos.sandbox.radiolivealacarte.server.model.Program;
import com.proutechos.sandbox.radiolivealacarte.server.model.UserModel;
import com.proutechos.sandbox.radiolivealacarte.server.service.dataServices.dataStorage.RadioLiveALaCarteDataStorage;
import com.proutechos.sandbox.radiolivealacarte.server.service.dataServices.RadioLiveALaCarteUserService;
import com.proutechos.sandbox.radiolivealacarte.server.service.audioServices.ia.TrimingWithIAService;
import com.proutechos.sandbox.radiolivealacarte.server.service.audioServices.planning.RadioInformationAndPlanningService;
import com.proutechos.sandbox.radiolivealacarte.server.service.audioServices.recording.RadioRecordingSchedulerService;
import com.proutechos.sandbox.radiolivealacarte.server.service.audioServices.streaming.StreamingService;
import com.proutechos.utils.server.rest.config.exceptions.ProutechosBaseException;

import org.junit.Test;

import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.DriverManager;

public class RadioLiveALaCarteServiceTest {

    @Test public void createUser() {
        UserModel user = new UserModel("1", "John", "Doe");

        try {
            System.out.println(RadioLiveALaCarteUserService.getInstance().createAccount(user));
        } catch (ProutechosBaseException e) {
            e.printStackTrace();
        }
    }

    @Test public void getUserByID() {
        try {
            System.out.println(RadioLiveALaCarteUserService.getInstance().getUserByID("aa768288-7621-49c8-99bd-"));
        } catch (ProutechosBaseException e) {
            e.printStackTrace();
        }
    }

    @Test public void addUserProgram() {

        try {
            RadioLiveALaCarteUserService.getInstance().addUserProgram("aa768288-7621-49d-c33c6fc02cc5", "e8d96a9e-d0cf-48de-a06b-809ecc95305c");
        } catch (ProutechosBaseException e) {
            e.printStackTrace();
        }

    }

    @Test public void getProgramsByRadioName() {

        try {
            System.out.println(RadioLiveALaCarteDataStorage.getInstance().getProgramsByRadioName("France Inter"));
        } catch (ProutechosBaseException e) {
            e.printStackTrace();
        }

    }

    @Test public void doesUserExists() {

        try {

            System.out.println(RadioLiveALaCarteUserService.getInstance().doesUserExists("aa768288-7621-49c8-99bd-c33c6fc02cc5"));

        } catch (ProutechosBaseException e) {
            e.printStackTrace();
        }

    }

    @Test public void fullCreateProgram() {
        Program program = new Program("430934", "Radio XYZ", 1751898073, 1751898569);
        UserModel user = new UserModel("1", "John", "Doe");

        try {

            String userId = RadioLiveALaCarteUserService.getInstance().createAccount(user);
            String programID = RadioLiveALaCarteUserService.getInstance().createProgram(program);
            RadioLiveALaCarteUserService.getInstance().addUserProgram(userId, programID);

        } catch (ProutechosBaseException e) {
            e.printStackTrace();
        }

    }

    @Test public void getProgramsByUserId() {

        try {

            System.out.println(RadioLiveALaCarteUserService.getInstance().getProgramsByUserId("aa76828621-49c8-99bd-c33c6fc02cc5"));

        } catch (ProutechosBaseException e) {
            throw new RuntimeException(e);
        }

    }

    @Test public void deleteProgramInUserMenu() {

        try {
            RadioLiveALaCarteDataStorage.getInstance().deleteUserProgram("e8d96a9e-d0cf-48de-a06b-809ecc95305c", "aa768288-7621-49c8-99bd-c33c6fc02cc5");
        } catch (ProutechosBaseException e) {
            e.printStackTrace();
        }
    }

    /*@Test public void tryToRecord()  {

        // Attendez que l'utilisateur appuie sur Entrée pour arrêter l'enregistrement
        try {
            RadioRecordingSchedulerService.getInstance().recordFromHourly(17, 5, 0, 17, 6, 0, 0, "https://stream.radiofrance.fr/franceinfo/franceinfo_hifi.m3u8?id=radiofrance");
            System.in.read();
        } catch (IOException e) {
            throw new RuntimeException(e);
        } catch (ProutechosBaseException e) {
            e.printStackTrace();
        }

    }*/

    @Test public void createProgram() {
        try {

            Program program = new Program("programId", "France Inter",1751898073, 1751805680);

            String programID = RadioLiveALaCarteUserService.getInstance().createProgram(program);
            RadioLiveALaCarteUserService.getInstance().addUserProgram("user001", programID);

            Program justCreatedProgram = RadioLiveALaCarteUserService.getInstance().getProgramByID(programID);
            RadioRecordingSchedulerService.getInstance().recordProgram(justCreatedProgram, 0);

        } catch (ProutechosBaseException e) {
            e.printStackTrace();
        }
    }

    @Test public void avancedTryToRecord()  {

        Program program = new Program("4934", "France Inter", 1751898073, 1751898074);

        // Attendez que l'utilisateur appuie sur Entrée pour arrêter l'enregistrement
        try {

            try {
                RadioRecordingSchedulerService.getInstance().recordProgram(program, 0);
            }  catch (ProutechosBaseException e) {
                e.printStackTrace();
            }

            System.in.read();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

    }

    @Test public void getSuitableFileNameByProgramIdTest() {

        try {
            System.out.println(RadioLiveALaCarteUserService.getInstance().getSuitableFileNameByProgramId("afc93a0f-d575-47d3-9047-9345b3305fcd"));
        } catch (ProutechosBaseException e) {
            throw new RuntimeException(e);
        }

    }

    @Test public void getFileWithoutSegmentBaseURL() {

        try {
            String[] programs = RadioLiveALaCarteUserService.getInstance().getFilesWithoutSegmentNamesList("aa768288-7621-49c8-99bd-c33c6fc02cc5");
            System.out.println(programs.length);
        } catch (ProutechosBaseException e) {
            throw new RuntimeException(e);
        }

    }

    @Test public void getFileWithSegmentBaseURL() {

        try {
            System.out.println(RadioLiveALaCarteUserService.getInstance().getFileWithSegmentBaseURL("aa768288-7621-49c8-99bd-c33c6fc02cc5"));
        } catch (ProutechosBaseException e) {
            throw new RuntimeException(e);
        }

    }

    @Test public void full() {

        try {

            Program program1 = new Program("programId", "France Inter", 1751898073, 1751898569);

            String program1ID = RadioLiveALaCarteUserService.getInstance().createProgram(program1);
            RadioLiveALaCarteUserService.getInstance().addUserProgram("user001", program1ID);

            Program justCreatedProgram1 = RadioLiveALaCarteUserService.getInstance().getProgramByID(program1ID);
            RadioRecordingSchedulerService.getInstance().recordProgram(justCreatedProgram1, 0);

            Program program2 = new Program("programId", "France Info", 1751898073, 1751898569);

            String program2ID = RadioLiveALaCarteUserService.getInstance().createProgram(program2);
            RadioLiveALaCarteUserService.getInstance().addUserProgram("user001", program2ID);

            Program justCreatedProgram2 = RadioLiveALaCarteUserService.getInstance().getProgramByID(program2ID);
            RadioRecordingSchedulerService.getInstance().recordProgram(justCreatedProgram2, 0);

            System.in.read();

        } catch (ProutechosBaseException e) {
            throw new RuntimeException(e);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

    }

    @Test public void concatened() {

        try {
            System.out.println(StreamingService.getInstance().concatene("output_c6c9575c-7628-41ea-9cc6-015688ba10b4_19140"));
        } catch (IOException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

    }

    @Test public void lightenSearchByName() throws Exception {
        try {
            System.out.println(RadioInformationAndPlanningService.getInstance().lightenSearchByName("France"));
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    @Test public void deleteProgram() throws Exception {
        try {
            RadioLiveALaCarteDataStorage.deleteProgram("0356e867-b433-4ccb-8ab1-600f50204885");
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    @Test public void trim() throws Exception {
        try {
            //RadioLiveALaCarteDataStorage.deleteProgram("0356e867-b433-4ccb-8ab1-600f50204885");
            TrimingWithIAService.trimAudio("/Users/eglantine/Dev/0.perso/2.Proutechos/8.RadioStreaming/0.RadioLiveALaCarteServer/app/src/main/resources/static/media/mp3/output_77a59712-8cd8-41be-a3c1-408afff12abf_12320.mp3", "/Users/eglantine/Dev/0.perso/2.Proutechos/8.RadioStreaming/0.RadioLiveALaCarteServer/app/src/main/resources/static/media/mp3/output_77a59712-8cd8-41be-a3c1-408afff12abf_12320-trimmed.mp3", 0);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    @Test public void newCreateProgram() throws  Exception {
        try {

            Program program = new Program("programId", "radioName", 1751898073, 1751898173);

            String programID = RadioLiveALaCarteUserService.getInstance().createProgram(program);
            RadioLiveALaCarteUserService.getInstance().addUserProgram("user001", programID);
            System.out.println(programID);

        } catch (ProutechosBaseException e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    @Test public void feedback() {
        try {
            System.out.println(RadioLiveALaCarteDataStorage.getInstance().getFeedback("3bbe60fc-c0cd-47c6-890d-cd93d425dde3"));
        } catch (ProutechosBaseException e) {
            System.out.println(e);
        }
    }

    @Test public void connection() {

        Path dbPath = Paths.get("").toAbsolutePath().getParent().resolve("@db/RadioLiveALaCarteDB.db");

        String url = "jdbc:sqlite:" + dbPath.toString();
        System.out.println(url);

    }
    //DriverManager.getConnection("jdbc:sqlite:/Users/eglantine/Dev/0.perso/2.Proutechos/8.RadioStreaming/0.RadioLiveALaCarteServer/@db/RadioLiveALaCarteDB.db");

}