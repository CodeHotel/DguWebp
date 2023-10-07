import java.sql.Connection;
import java.sql.DriverManager;

public class DatabaseUtility {
    
    private static final String DB_URL = "jdbc:mysql://akomarket-db.cwmg6nnupeuw.ap-northeast-2.rds.amazonaws.com/AkoMarket";
    private static final String DB_USER = "admin";
    private static final String DB_PASSWORD = "akomarket";
    
    static {
        try {
            System.out.println("Loading JDBC driver...");
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("JDBC driver loaded successfully.");
        } catch (ClassNotFoundException e) {
            System.out.println("Failed to load JDBC driver.");
            e.printStackTrace();
        }
    }


    public static Connection getConnection() throws Exception {
        System.out.println("Attempting to establish database connection...");
        Connection connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
        System.out.println("Database connection established!");
        return connection;
    }

}
