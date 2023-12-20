package Servlets;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class LogoutServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Invalidate the session
        HttpSession session = request.getSession(false); // false: don't create a new session if one doesn't exist
        if (session != null) {
            session.invalidate();
        }

        // Redirect to a specific page after logout
        String redirectTo = "/Title.jsp"; // Change this to the URL where you want to redirect after logout
        response.sendRedirect(request.getContextPath() + redirectTo);
    }
}
