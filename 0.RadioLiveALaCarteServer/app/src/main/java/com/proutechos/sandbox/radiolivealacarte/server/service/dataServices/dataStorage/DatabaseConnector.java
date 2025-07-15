package com.proutechos.sandbox.radiolivealacarte.server.service.dataServices.dataStorage;

import java.net.URL;
import java.nio.file.Paths;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;

public class DatabaseConnector {
    public static Connection getConnection() throws Exception {
        // Remonter d’un dossier puis aller dans @db

        Path currentPath = Paths.get("").toAbsolutePath();

        // Répertoire parent
        Path parentPath = currentPath.getParent();

        // Aller dans le sous-dossier "@db" à partir du répertoire parent
        Path dbPath = parentPath.resolve("@db/RadioLiveALaCarteDB.db");

        String url = "jdbc:sqlite:" + dbPath.toString();
        System.out.println(url);
        return DriverManager.getConnection(url);
    }
}
