package com.proutechos.sandbox.radiolivealacarte.server.service.dataServices.dataStorage;

import java.nio.file.Paths;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;

public class DatabaseConnector {
    public static Connection getConnection() throws Exception {
        // Remonter d’un dossier puis aller dans @db
        Path dbPath = Paths.get("").toAbsolutePath().getParent().resolve("/dbStorage/RadioLiveALaCarteDB.db");

        String url = "jdbc:sqlite:" + dbPath.toString();
        return DriverManager.getConnection(url);
    }
}
