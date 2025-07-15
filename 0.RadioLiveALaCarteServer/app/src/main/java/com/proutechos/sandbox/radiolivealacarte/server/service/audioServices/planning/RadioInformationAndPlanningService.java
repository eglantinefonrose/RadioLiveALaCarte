package com.proutechos.sandbox.radiolivealacarte.server.service.audioServices.planning;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.proutechos.sandbox.radiolivealacarte.server.api.cache.RadioCacheManager;
import com.proutechos.sandbox.radiolivealacarte.server.model.LightenedRadioStation;
import com.proutechos.sandbox.radiolivealacarte.server.model.LightenedRadioStationAndAmountOfResponses;
import com.proutechos.sandbox.radiolivealacarte.server.model.RadioStation;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.UUID;
import java.util.stream.Collectors;

import static com.proutechos.sandbox.radiolivealacarte.server.api.cache.RadioCacheManager.loadFromCache;
import static org.quartz.JobBuilder.newJob;

public class RadioInformationAndPlanningService {

    /**
     * La fonction utilise l'API Radio Browser pour renvoyer tous les pays disponibles.
     * @return
     * @throws Exception
     */
    public String getAllCountries() throws Exception {

        try {
            // L'URL à laquelle faire l'appel
            String url = "http://37.27.202.89/json/countries";

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
            System.out.println("Code de réponse HTTP : " + responseCode);

            // Lire la réponse
            BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
            String inputLine;
            StringBuffer response = new StringBuffer();

            while ((inputLine = in.readLine()) != null) {
                response.append(inputLine);
            }
            in.close();
            // Afficher la réponse JSON
            return (response.toString());
        } catch (Exception e) {
            throw (e);
        }

    }

    public LightenedRadioStationAndAmountOfResponses lightenSearchByName(String name) throws Exception {

        if (name == null) {
            throw new IllegalArgumentException("Le nom ne peut pas être null.");
        }

        // Chargement depuis le cache (ou depuis une autre source si tu veux)
        List<LightenedRadioStation> allStations = RadioCacheManager.loadFromCache(); // ou getRadioStations()

        // Filtrage : on garde celles dont le nom commence par la chaîne passée (insensible à la casse)
        List<LightenedRadioStation> matchingStations = allStations.stream()
                .filter(station -> station.getName() != null && station.getName().toLowerCase().startsWith(name.toLowerCase()))
                .limit(5)
                .collect(Collectors.toList());

        // Construction de la réponse
        LightenedRadioStationAndAmountOfResponses response = new LightenedRadioStationAndAmountOfResponses(matchingStations.toArray(new LightenedRadioStation[0]), matchingStations.size());

        return response;
    }

    public LightenedRadioStation lightenSearchByID(String id) throws Exception {

        if (id == null) {
            throw new IllegalArgumentException("Le nom ne peut pas être null.");
        }

        // Chargement depuis le cache (ou depuis une autre source si tu veux)
        List<LightenedRadioStation> allStations = RadioCacheManager.loadFromCache(); // ou getRadioStations()

        // Filtrage : on garde celles dont le nom commence par la chaîne passée (insensible à la casse)
        List<LightenedRadioStation> matchingStations = allStations.stream()
                .filter(station -> station.getId() != null && station.getId().toLowerCase().startsWith(id.toLowerCase()))
                .limit(5)
                .collect(Collectors.toList());

        LightenedRadioStation response = matchingStations.getFirst();

        return response;

    }

    public String getURLByUUID(String uuid) throws Exception {

        if (uuid == null || uuid.isEmpty()) {
            throw new IllegalArgumentException("L'UUID ne peut pas être null ou vide.");
        }

        // Chargement depuis le cache local
        List<LightenedRadioStation> stations = loadFromCache(); // ou getRadioStations()

        // Recherche de la station correspondante
        return stations.stream()
                .filter(station -> uuid.equals(station.getId()))
                .map(LightenedRadioStation::getUrl)
                .findFirst()
                .orElseThrow(() -> new Exception("Aucune station trouvée avec l'UUID : " + uuid));
    }

    public static String getFavIcoByRadioName(String name) throws Exception {

        if (name == null || name.isEmpty()) {
            throw new IllegalArgumentException("L'UUID ne peut pas être null ou vide.");
        }

        // Chargement depuis le cache local
        List<LightenedRadioStation> stations = loadFromCache(); // ou getRadioStations()

        // Recherche de la station correspondante
        return stations.stream()
                .filter(station -> name.equals(station.getId()))
                .map(LightenedRadioStation::getFavicon)
                .findFirst()
                .orElseThrow(() -> new Exception("Aucune station trouvée avec l'UUID : " + name));

    }

    public String[] getDailyProgramsNames() {
        return new String[] { "output_2dfaad39-d6e4-44c0-a5f4-5286d0a99654_1750.mp3", "output_9ae721f7-5dce-4381-b8ed-1a0f8bbf6f16_21420.mp3" };
    }




    //
    //
    // IMPLEMENTATION
    //
    //

    /**
     * Met au format Camel Case une chaine de caractère.
     * @param input Chaine de caractères à passer en CamelCase
     * @return
     */
    private String toCamelCase(String input) {
        if (input == null || input.isEmpty()) {
            return input;
        }

        // Diviser la chaîne en mots en utilisant les espaces, tirets et underscores comme séparateurs
        String[] words = input.split("[\\s-_]+");
        StringBuilder camelCaseString = new StringBuilder(words[0].toLowerCase());

        for (int i = 1; i < words.length; i++) {
            String word = words[i];
            // Mettre en majuscule la première lettre de chaque mot à partir du second mot
            camelCaseString.append(Character.toUpperCase(word.charAt(0)));
            camelCaseString.append(word.substring(1).toLowerCase());
        }

        return camelCaseString.toString();
    }



    //
    //
    // SINGLETON
    //
    //

    private static RadioInformationAndPlanningService _instance = new RadioInformationAndPlanningService();

    public static RadioInformationAndPlanningService getInstance() {
        return _instance;
    }

}
