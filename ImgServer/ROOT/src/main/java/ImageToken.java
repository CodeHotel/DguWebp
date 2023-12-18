import java.io.IOException;
import java.io.PrintWriter;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/imageToken")
public class ImageToken extends HttpServlet {
    private static String masterKey = "akoImage";

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // ... [existing code]

        PrintWriter out = response.getWriter();
        try {
            String keyParam = request.getParameter("masterkey");
            String image = request.getParameter("imageName");

            if(keyParam == null || !masterKey.equals(keyParam)){
                out.print("invalid-auth");
            } else {
                String token = UUID.randomUUID().toString();

                // Create a new TokenInfo object
                TokenInfo tokenInfo = new TokenInfo(token, image);

                // Add to application scope
                getServletContext().setAttribute(token, tokenInfo);

                out.print(token);
            }
        } finally {
            if (out != null) {
                out.close();
            }
        }
    }
}