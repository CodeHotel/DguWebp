import org.apache.tomcat.util.http.fileupload.servlet.ServletFileUpload;

import java.io.*;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

@WebServlet("/uploadImage")
@MultipartConfig
public class UploadImage extends HttpServlet {

    private static final String UPLOAD_DIRECTORY = "/usr/local/Server_Repo/ImageDB/";
    private static String masterKey = "akoImage";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if the request is multipart content
        if (!ServletFileUpload.isMultipartContent(request)) {
            // Error handling
            return;
        }

        InputStream fileContent = null;
        FileOutputStream out = null;
        String fileName ="NULL";
        try {
            if(!request.getParameter("masterkey").equals(masterKey)){throw new Exception("Warong masterkey!");}
            Part filePart = request.getPart("file"); // Retrieves <input type="file" name="file">
            String submittedFileName = filePart.getSubmittedFileName();
            String fileExtension = submittedFileName.substring(submittedFileName.lastIndexOf("."));
            fileName = UUID.randomUUID().toString()+fileExtension; // Manual string for filename

            File uploadDir = new File(UPLOAD_DIRECTORY);
            if (!uploadDir.exists()) uploadDir.mkdir(); // Create upload directory if it doesn't exist

            File file = new File(UPLOAD_DIRECTORY, fileName);

            fileContent = filePart.getInputStream();
            out = new FileOutputStream(file);

            byte[] buffer = new byte[1024];
            int bytesRead;
            while ((bytesRead = fileContent.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
        } catch (Exception e) {
            // Handle exceptions
            e.printStackTrace();
        } finally {
            PrintWriter wr = response.getWriter();
            wr.print(fileName);
            wr.close();
            if (fileContent != null) {
                try {
                    fileContent.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            if (out != null) {
                try {
                    out.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
