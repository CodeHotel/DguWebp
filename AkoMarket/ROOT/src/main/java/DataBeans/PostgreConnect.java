package DataBeans;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

public class PostgreConnect {
    private static final String DB_URL = "jdbc:mysql://akodb.cwmg6nnupeuw.ap-northeast-2.rds.amazonaws.com/AkoDB";
    private static final String DB_USER = "akomarket";
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

    public static Statement getStmt() throws SQLException {
        Connection connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
        return connection.createStatement();
    }
}
