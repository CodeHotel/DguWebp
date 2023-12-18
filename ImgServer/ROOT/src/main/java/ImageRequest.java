import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/imageRequest")
public class ImageRequest extends HttpServlet {

    private static final String BASE_IMAGE_PATH = "/usr/local/Server_Repo/ImageDB/";

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String token = request.getParameter("token");
        TokenInfo tokenInfo = (TokenInfo) getServletContext().getAttribute(token);

        if (tokenInfo != null && !tokenInfo.isAccessed() && !tokenInfo.isExpired()) {
            String imagePath = BASE_IMAGE_PATH + tokenInfo.getImageName();
            File imageFile = new File(imagePath);
            System.out.println("Opening image "+imagePath);
            if (imageFile.exists()) {
                getServletContext().removeAttribute(token); // Remove token to prevent reuse
                tokenInfo.setAccessed(true);

                response.setContentType(getServletContext().getMimeType(imageFile.getName()));
                response.setContentLength((int) imageFile.length());
                response.setHeader("Content-Disposition", "inline; filename=\"" + imageFile.getName() + "\"");

                FileInputStream in = null;
                OutputStream out = null;

                try {
                    in = new FileInputStream(imageFile);
                    out = response.getOutputStream();

                    byte[] buffer = new byte[1024];
                    int count;
                    while ((count = in.read(buffer)) != -1) {
                        out.write(buffer, 0, count);
                    }
                } finally {
                    if (in != null) {
                        try {
                            in.close();
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
            } else {
                System.out.println("Image not found");
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } else {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
        }
    }
}
