import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.file.Paths;

@WebServlet("/upload")
@MultipartConfig
public class ImageUploadServlet extends HttpServlet {

    private static final String IMAGE_SERVER_UPLOAD_URL = "http://yourImageServer:port/uploadImage";
    private static final String MASTER_KEY = "akoImage"; // Shared master key

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Part filePart = request.getPart("file"); // Retrieves <input type="file" name="file">
        forwardFileToImageServer(filePart, response);
    }

    private void forwardFileToImageServer(Part filePart, HttpServletResponse response) throws IOException {
        String boundary = Long.toHexString(System.currentTimeMillis()); // Random boundary for multipart
        String CRLF = "\r\n"; // Line separator required by multipart/form-data
        URL url = new URL(IMAGE_SERVER_UPLOAD_URL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setDoOutput(true);
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "multipart/form-data; boundary=" + boundary);

        try (OutputStream output = conn.getOutputStream();
             PrintWriter writer = new PrintWriter(new OutputStreamWriter(output, "UTF-8"), true)) {

            // Send master key part
            writer.append("--" + boundary).append(CRLF);
            writer.append("Content-Disposition: form-data; name=\"masterkey\"").append(CRLF);
            writer.append(CRLF).append(MASTER_KEY).append(CRLF).flush();

            // Send file part
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString(); // Original file name
            writer.append("--" + boundary).append(CRLF);
            writer.append("Content-Disposition: form-data; name=\"file\"; filename=\"" + fileName + "\"").append(CRLF);
            writer.append("Content-Type: " + filePart.getContentType()).append(CRLF); // Auto-detected content type
            writer.append(CRLF).flush();

            // Stream the file content
            try (InputStream inputStream = filePart.getInputStream()) {
                byte[] buffer = new byte[4096];
                int bytesRead;
                while ((bytesRead = inputStream.read(buffer)) != -1) {
                    output.write(buffer, 0, bytesRead);
                }
                output.flush();
            }

            // End of multipart/form-data
            writer.append(CRLF).flush();
            writer.append("--" + boundary + "--").append(CRLF).flush();
        }

        // Handle the response from the image server
        int responseCode = conn.getResponseCode();
        if (responseCode == HttpURLConnection.HTTP_OK) {
            try (BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()))) {
                String inputLine;
                StringBuilder responseString = new StringBuilder();
                while ((inputLine = in.readLine()) != null) {
                    responseString.append(inputLine);
                }
                // Forward the response to the client
                response.getWriter().write(responseString.toString());
            }
        } else {
            // Handle error
            response.sendError(responseCode, "Failed to upload image to the image server.");
        }
    }
}
