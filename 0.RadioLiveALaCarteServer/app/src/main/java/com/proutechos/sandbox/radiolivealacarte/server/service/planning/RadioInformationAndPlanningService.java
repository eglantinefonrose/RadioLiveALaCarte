package com.proutechos.sandbox.radiolivealacarte.server.service.planning;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
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

    /**
     * La fonction utilise l'API Radio Browser pour renvoyer toutes les radios qui ont un nom similaire à celui recherché.
     * La chaine de caractère passée en paramètre peut être composée de deux noms, l'espace sera enlevé par la suite.
     *
     * @param name
     * @return
     * @throws Exception
     */
    public RadioStation[] searchByName(String name) throws Exception {

        try {
            String wellFormattedRadioName = name.replace(" ", "%20");

            // Construction de l'URL en utilisant la variable camelCaseSearch
            String url = "http://37.27.202.89/json/stations/byname/" + wellFormattedRadioName;

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

            return stations.toArray(new RadioStation[0]);

        } catch (Exception e) {
            throw (e);
        }

    }

    public RadioStation[] searchByStationUUID(String uuid) throws Exception {

        try {

            // Construction de l'URL en utilisant la variable camelCaseSearch
            String url = "http://37.27.202.89/json/stations/byuuid/" + uuid;

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

            return stations.toArray(new RadioStation[0]);

        } catch (Exception e) {
            throw (e);
        }

    }

    public String getURLByName(String name) throws Exception {

        try {
            String wellFormattedRadioName = name.replace(" ", "%20");

            // Construction de l'URL en utilisant la variable camelCaseSearch
            String url = "http://37.27.202.89/json/stations/byname/" + wellFormattedRadioName;

            // Créer un objet URL
            URL obj = new URL(url);
            System.out.println(url);

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

            return stations.get(0).getUrl();

        } catch (Exception e) {
            throw (e);
        }

    }

    public LightenedRadioStationAndAmountOfResponses lightenSearchByName(String name) throws Exception {

        try {
            String wellFormattedRadioName = name.replace(" ", "%20");

            // Construction de l'URL en utilisant la variable camelCaseSearch
            String url = "http://37.27.202.89/json/stations/byname/" + wellFormattedRadioName;

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
                LightenedRadioStation lightenedRadioStation = new LightenedRadioStation(id, station.getName(), station.getFavicon(), station.getStationuuid());
                lightenedRadioStations.add(lightenedRadioStation);
            }

            LightenedRadioStation[] lightenedRadioStationsArray = lightenedRadioStations.toArray(new LightenedRadioStation[0]);
            return new LightenedRadioStationAndAmountOfResponses(Arrays.copyOfRange(lightenedRadioStationsArray, 0, Math.min(5, lightenedRadioStationsArray.length)), lightenedRadioStations.size());

        } catch (Exception e) {
            throw (e);
        }

    }

    public LightenedRadioStation lightenSearchByUUID(String uuid) throws Exception {

        try {

            // Construction de l'URL en utilisant la variable camelCaseSearch
            String url = "http://37.27.202.89/json/stations/byuuid/" + uuid;

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
                LightenedRadioStation lightenedRadioStation = new LightenedRadioStation(id, station.getName(), station.getFavicon(), station.getStationuuid());
                lightenedRadioStations.add(lightenedRadioStation);
            }

            LightenedRadioStation[] lightenedRadioStationsArray = lightenedRadioStations.toArray(new LightenedRadioStation[0]);
            return lightenedRadioStationsArray[0];

        } catch (Exception e) {
            throw (e);
        }

    }

    public String getURLByUUID(String uuid) throws Exception {

        try {

            // Construction de l'URL en utilisant la variable camelCaseSearch
            String url = "http://37.27.202.89/json/stations/byuuid/" + uuid;

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

            return stations.getFirst().getUrl();

        } catch (Exception e) {
            throw (e);
        }

    }

    public static String getFavIcoByRadioName(String name) throws Exception {

        try {
            String wellFormattedRadioName = name.replace(" ", "%20");

            // Construction de l'URL en utilisant la variable camelCaseSearch
            String url = "http://37.27.202.89/json/stations/byname/" + wellFormattedRadioName;

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

            // Afficher les objets RadioStation
            /*for (RadioStation station : stations) {
                System.out.println(station.toString());
            }*/

            return stations.getFirst().getFavicon();

        } catch (Exception e) {
            throw (e);
        }

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
