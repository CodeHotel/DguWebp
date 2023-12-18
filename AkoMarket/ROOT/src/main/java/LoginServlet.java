import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String loginId = request.getParameter("loginId");
        String loginPw = request.getParameter("loginPw");

        Integer result = DataBeans.PostgreInterface.userAuth(loginId, loginPw);

        if(result != -1) {
            // Creating or retrieving existing session
            HttpSession session = request.getSession(true);
            // Setting user ID (or any other user-related information) in session
            session.setAttribute("userId", result);

            // Send a success response
            response.getWriter().write("success");
        } else {
            response.getWriter().write("null");
        }
    }
}
