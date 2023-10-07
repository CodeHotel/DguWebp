import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	System.out.println("Login attempt...");
    	String id = request.getParameter("login_id");
        String password = request.getParameter("login_pw");

        try (Connection connection = DatabaseUtility.getConnection()) {
            PreparedStatement statement = connection.prepareStatement("SELECT pw FROM users WHERE id = ?");
            statement.setString(1, id);
            ResultSet resultSet = statement.executeQuery();
            
            if (resultSet.next() && password.equals(resultSet.getString("pw"))) {
                response.setContentType("application/json");
                PrintWriter out = response.getWriter();
                out.print("{ \"success\": true, \"message\": \"Login successful\" }");
                out.flush();
            } else {
                response.setContentType("application/json");
                PrintWriter out = response.getWriter();
                out.print("{ \"success\": false, \"message\": \"Login failed\" }");
                out.flush();
            }
            System.out.println("Login successful for ID: " + id);
        } catch (Exception e) {
            System.out.println("Error during login.");
            e.printStackTrace();
        }
    }
}
