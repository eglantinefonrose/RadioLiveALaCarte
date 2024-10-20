package com.proutechos.sandbox.radiolivealacarte.server.services;

import com.proutechos.sandbox.radiolivealacarte.server.model.Program;
import com.proutechos.sandbox.radiolivealacarte.server.model.UserModel;
import com.proutechos.sandbox.radiolivealacarte.server.service.RadioLiveALaCarteDataStorage;
import com.proutechos.sandbox.radiolivealacarte.server.service.RadioLiveALaCarteUserService;
import com.proutechos.utils.server.rest.config.exceptions.ProutechosBaseException;

import org.junit.jupiter.api.Test;
import java.util.List;

class RadioLiveALaCarteServiceTest {

    @Test void createProgramConnection() {
        UserModel user = new UserModel("1", "John", "Doe");
        Program program = new Program("123", "Radio XYZ", 8, 30, 0, 10, 0, 0);

        try {
            RadioLiveALaCarteDataStorage.getInstance().addUserProgram(user, program);
        } catch (ProutechosBaseException e) {
            e.printStackTrace();
        }
    }

    @Test void createUser() {
        UserModel user = new UserModel("1", "John", "Doe");

        try {
            System.out.println(RadioLiveALaCarteUserService.getInstance().createAccount(user));
        } catch (ProutechosBaseException e) {
            e.printStackTrace();
        }
    }

    @Test void fullCreateProgram() {
        Program program = new Program("430934", "Radio XYZ", 8, 30, 0, 10, 0, 0);
        UserModel user = new UserModel("1", "John", "Doe");

        try {
            RadioLiveALaCarteDataStorage.getInstance().createProgram(program);
            RadioLiveALaCarteDataStorage.getInstance().addUserProgram(user, program);
        } catch (ProutechosBaseException e) {
            e.printStackTrace();
        }

    }

    @Test void getProgramsFromUser() {

        UserModel user = new UserModel("1", "John", "Doe");

        try {
            List<Program> programList = RadioLiveALaCarteDataStorage.getInstance().getProgramsByUser(user);
            System.out.println(programList);
        } catch (ProutechosBaseException e) {
            e.printStackTrace();
        }
    }

    @Test void deleteProgramInUserMenu() {

        Program program = new Program("430934", "Radio XYZ", 8, 30, 0, 10, 0, 0);
        UserModel user = new UserModel("1", "John", "Doe");

        try {
            RadioLiveALaCarteDataStorage.getInstance().deleteUserProgram(program, user);
        } catch (ProutechosBaseException e) {
            e.printStackTrace();
        }
    }

}