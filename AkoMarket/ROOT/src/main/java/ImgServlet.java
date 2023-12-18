import DataBeans.ImageDB;

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
public class ImgServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("Uploading");
        Part filePart = request.getPart("file1"); // Retrieves <input type="file" name="file1">
        String d = ImageDB.uploadFile(filePart);
        if(d!=null) {
            System.out.println("Uploaded at:" + d);
            String token = ImageDB.getImageUrl(d);
            response.sendRedirect(token);
        }
    }
}
