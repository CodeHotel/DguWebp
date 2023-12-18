package DataBeans;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

public class ImageDB {
    private static final String DB_URL = "172.31.1.245:2580";
    private static final String KEY = "akoImage";

    // Method to get the image URL
    public static String getImageUrl(String fileName){
        String token = urlResponse(DB_URL + "imageToken?masterkey=" + KEY + "&imageName=" + fileName);
        return DB_URL + "/imageRequest?token=" + token;
    }

    // Implementing urlResponse
    public static String urlResponse(String urlString) {
        StringBuilder response = new StringBuilder();

        try {
            URL url = new URL(urlString);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");

            BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            String inputLine;

            while ((inputLine = in.readLine()) != null) {
                response.append(inputLine);
            }
            in.close();
        } catch (Exception e) {
            e.printStackTrace();
        }

        return response.toString();
    }
}
