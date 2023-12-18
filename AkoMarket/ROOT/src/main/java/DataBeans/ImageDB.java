package DataBeans;

import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.file.Paths;
import java.util.UUID;

public class ImageDB {
    private static final String DB_URL = "localhost:2580";
    private static final String UPLOAD_DIRECTORY = "/usr/local/Server_Repo/ImageDB/";
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

    public static String uploadFile(Part filePart, String masterKeyParam) throws IOException {
        // Check master key
        if (!KEY.equals(masterKeyParam)) {
            throw new IOException("Wrong master key");
        }

        String fileName = "NULL";
        try (InputStream fileContent = filePart.getInputStream();
             FileOutputStream out = new FileOutputStream(new File(UPLOAD_DIRECTORY, fileName))) {

            String submittedFileName = filePart.getSubmittedFileName();
            String fileExtension = submittedFileName.substring(submittedFileName.lastIndexOf("."));
            fileName = UUID.randomUUID().toString() + fileExtension; // Manual string for filename

            File uploadDir = new File(UPLOAD_DIRECTORY);
            if (!uploadDir.exists()) uploadDir.mkdir(); // Create upload directory if it doesn't exist

            byte[] buffer = new byte[1024];
            int bytesRead;
            while ((bytesRead = fileContent.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
        } catch (Exception e) {
            // Handle exceptions
            e.printStackTrace();
            throw e; // Rethrow to indicate failure
        }
        return fileName;
    }
}
