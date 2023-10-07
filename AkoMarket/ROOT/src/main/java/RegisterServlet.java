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

public class RegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	System.out.println("Registration attempt...");
    	String id = request.getParameter("reg_id");
        String password = request.getParameter("reg_pw");

        try (Connection connection = DatabaseUtility.getConnection()) {
            PreparedStatement statement = connection.prepareStatement("INSERT INTO users (id, pw) VALUES (?, ?)");
            statement.setString(1, id);
            statement.setString(2, password);
            statement.executeUpdate();
            
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("{ \"message\": \"Registration successful\" }");
            out.flush();
            System.out.println("Registration successful for ID: " + id);
        } catch (Exception e) {
            System.out.println("Error during registration.");
            e.printStackTrace();
        }
    }
}
