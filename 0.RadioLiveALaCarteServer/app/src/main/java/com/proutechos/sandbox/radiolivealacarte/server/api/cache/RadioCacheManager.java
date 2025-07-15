package com.proutechos.sandbox.radiolivealacarte.server.api.cache;
import com.fasterxml.jackson.databind.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.proutechos.sandbox.radiolivealacarte.server.model.LightenedRadioStation;
import com.proutechos.sandbox.radiolivealacarte.server.model.LightenedRadioStationAndAmountOfResponses;
import com.proutechos.sandbox.radiolivealacarte.server.model.RadioStation;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.*;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.stream.Collectors;
import java.util.concurrent.TimeUnit;

public class RadioCacheManager {

    private static final String CACHE_FILE = "radio_cache.json";

    private static final ObjectMapper objectMapper = new ObjectMapper();

    private static final ScheduledExecutorService scheduler = Executors.newSingleThreadScheduledExecutor();

    private static List<LightenedRadioStation> fetchFromApi() throws IOException {

        try {

            // Construction de l'URL en utilisant la variable camelCaseSearch
            String url = "https://de2.api.radio-browser.info/json/stations";

            // Créer un objet URL
            URL obj = new URL(url);

            // Ouvrir la connexion HTTP
            HttpURLConnection con = (HttpURLConnection) obj.openConnection();

            // Définir la méthode de requête comme GET
            con.setRequestMethod("GET");

            // Définir les propriétés de la requête
            con.setRequestProperty("User-Agent", "Mozilla/5.0");

            // Vérifier le code de réponse HTTP
            int responseCode = con.getResponseCode();

            // Lire la réponse
            BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
            String inputLine;
            StringBuffer response = new StringBuffer();

            while ((inputLine = in.readLine()) != null) {
                response.append(inputLine);
            }
            in.close();
            // Afficher la réponse JSON
            String jsonString = response.toString();

            ObjectMapper objectMapper = new ObjectMapper();
            List<RadioStation> stations = objectMapper.readValue(jsonString, new TypeReference<List<RadioStation>>() {
            });

            List<LightenedRadioStation> lightenedRadioStations = new ArrayList<>();
            for (RadioStation station : stations) {
                String id = station.getStationuuid();
                LightenedRadioStation lightenedRadioStation = new LightenedRadioStation(id, station.getName(), station.getFavicon(), station.getStationuuid(), station.getUrl());
                lightenedRadioStations.add(lightenedRadioStation);
            }

            return lightenedRadioStations;

        } catch (Exception e) {
            throw (e);
        }

    }

    public static void saveToCache() {
        try {
            List<LightenedRadioStation> stations = fetchFromApi();
            System.out.println("* SAUVEGARDE DANS LE CACHE *");
            objectMapper.writerWithDefaultPrettyPrinter()
                    .writeValue(new File(CACHE_FILE), stations);
        } catch (IOException e) {
            System.out.println("Erreur lors de l'écriture du cache : " + e.getMessage());
        }
    }

    public static List<LightenedRadioStation> loadFromCache() {
        try {
            File file = new File(CACHE_FILE);
            if (!file.exists()) return Collections.emptyList();

            return objectMapper.readValue(file, new TypeReference<List<LightenedRadioStation>>() {});
        } catch (IOException e) {
            System.out.println("Erreur de lecture du cache : " + e.getMessage());
            return Collections.emptyList();
        }
    }

    public static void scheduleCacheUpdate() {
        // Exécute immédiatement, puis toutes les 24h
        scheduler.scheduleAtFixedRate(() -> {
            System.out.println("Mise à jour du cache planifiée...");
            saveToCache();
        }, 0, 24, TimeUnit.HOURS);
    }

}

