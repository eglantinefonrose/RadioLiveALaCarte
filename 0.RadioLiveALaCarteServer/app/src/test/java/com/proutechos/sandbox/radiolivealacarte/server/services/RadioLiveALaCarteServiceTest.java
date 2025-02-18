package com.proutechos.sandbox.radiolivealacarte.server.services;

import com.proutechos.sandbox.radiolivealacarte.server.model.Program;
import com.proutechos.sandbox.radiolivealacarte.server.model.UserModel;
import com.proutechos.sandbox.radiolivealacarte.server.service.RadioLiveALaCarteDataStorage;
import com.proutechos.sandbox.radiolivealacarte.server.service.RadioLiveALaCarteUserService;
import com.proutechos.sandbox.radiolivealacarte.server.service.recording.RadioRecordingSchedulerService;
import com.proutechos.sandbox.radiolivealacarte.server.service.streaming.StreamingService;
import com.proutechos.utils.server.rest.config.exceptions.ProutechosBaseException;

import org.junit.Test;
import org.quartz.SchedulerException;

import java.io.IOException;

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
        Program program = new Program("430934", "Radio XYZ", 8, 30, 0, 10, 0, 0);
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

    @Test public void tryToRecord()  {

        // Attendez que l'utilisateur appuie sur Entrée pour arrêter l'enregistrement
        try {
            RadioRecordingSchedulerService.getInstance().recordFromHourly(17, 5, 0, 17, 6, 0, 0, "https://stream.radiofrance.fr/franceinfo/franceinfo_hifi.m3u8?id=radiofrance");
            System.in.read();
        } catch (IOException e) {
            throw new RuntimeException(e);
        } catch (ProutechosBaseException e) {
            e.printStackTrace();
        }

    }

    @Test public void createProgram() {
        try {

            Program program = new Program("programId", "France Inter", 17, 10, 0, 18, 0, 0);

            String programID = RadioLiveALaCarteUserService.getInstance().createProgram(program);
            RadioLiveALaCarteUserService.getInstance().addUserProgram("user001", programID);

            Program justCreatedProgram = RadioLiveALaCarteUserService.getInstance().getProgramByID(programID);
            RadioRecordingSchedulerService.getInstance().recordProgram(justCreatedProgram);

        } catch (ProutechosBaseException e) {
            e.printStackTrace();
        }
    }

    @Test public void avancedTryToRecord()  {

        Program program = new Program("4934", "France Inter", 22, 10, 0, 22, 11, 0);

        // Attendez que l'utilisateur appuie sur Entrée pour arrêter l'enregistrement
        try {

            try {
                RadioRecordingSchedulerService.getInstance().recordProgram(program);
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

            Program program1 = new Program("programId", "France Inter", 18, 39, 0, 18, 41, 0);

            String program1ID = RadioLiveALaCarteUserService.getInstance().createProgram(program1);
            RadioLiveALaCarteUserService.getInstance().addUserProgram("user001", program1ID);

            Program justCreatedProgram1 = RadioLiveALaCarteUserService.getInstance().getProgramByID(program1ID);
            RadioRecordingSchedulerService.getInstance().recordProgram(justCreatedProgram1);

            Program program2 = new Program("programId", "France Info", 18, 40, 0, 18, 42, 0);

            String program2ID = RadioLiveALaCarteUserService.getInstance().createProgram(program2);
            RadioLiveALaCarteUserService.getInstance().addUserProgram("user001", program2ID);

            Program justCreatedProgram2 = RadioLiveALaCarteUserService.getInstance().getProgramByID(program2ID);
            RadioRecordingSchedulerService.getInstance().recordProgram(justCreatedProgram2);

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

}