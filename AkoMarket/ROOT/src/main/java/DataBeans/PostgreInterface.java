package DataBeans;

import java.sql.*;
import java.lang.StringBuilder;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.json.JSONArray;
import org.json.JSONObject;

import javax.xml.transform.Result;

public class PostgreInterface {

    public static User registerUser(String id, String pw, String nickname, String image, String id_card, String phone, String campus, String department, String degree, String studentId) {
        String sql = "WITH n_user AS (" +
                "    INSERT INTO akouser (login_id, login_pw, nickname, image, campus, department, degree, student_id)" +
                "    VALUES (?, ?, ?, ?, ?::campus_t, ?, ?::degree_t, ?) " +
                "    RETURNING id, login_id, login_pw, nickname, image, campus, department, degree, student_id" +
                "), " +
                "n_auth AS (" +
                "    INSERT INTO authentication (id_card, phone, user_id) " +
                "    VALUES (?, ?, (SELECT id FROM n_user)) " +
                "), " +
                "n_pay AS (" +
                "    INSERT INTO payment (user_id, point) " +
                "    VALUES ((SELECT id FROM n_user), 50000)" +
                ")" +
                "SELECT row_to_json(n_user) FROM n_user;";

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, id);
            pstmt.setString(2, pw);
            pstmt.setString(3, nickname);
            pstmt.setString(4, image);
            pstmt.setString(5, campus);
            pstmt.setString(6, department);
            pstmt.setString(7, degree);
            pstmt.setString(8, studentId);
            pstmt.setString(9, id_card);
            pstmt.setString(10, phone);

            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                JSONObject jsonObject = new JSONObject(rs.getString(1));
                return new User(
                    jsonObject.getInt("id"),
                    jsonObject.getString("login_id"),
                    jsonObject.getString("login_pw"),
                    jsonObject.getString("nickname"),
                    jsonObject.getString("image"),
                    Campus.valueOf(jsonObject.getString("campus")),
                    jsonObject.getString("department"),
                    Degree.valueOf(jsonObject.getString("degree")),
                    jsonObject.getString("student_id").toCharArray(),
                    null, // Assuming rating is not part of the return data
                    false // Assuming isAdmin is not part of the return data
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static boolean isIdExists(String id) {
        String sql = "SELECT u.login_id FROM akouser u WHERE u.login_id=?;";

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, id);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getString(1) != null;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean isNickExists(String nickname) {
        String sql = "SELECT u.nickname FROM akouser u WHERE u.nickname=?;";
        
        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, nickname);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getString(1) != null;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Updated registerAdmin method
    public static User registerAdmin(String id, String pw) {
        String sql = "WITH n_user AS (" +
                "    INSERT INTO akouser (login_id, login_pw, nickname)" +
                "    VALUES (?, ?, 'admin') " +
                "    RETURNING *" +
                "), " +
                "n_auth AS (" +
                "    INSERT INTO authentication (user_id, authorized) " +
                "    VALUES ((SELECT id FROM n_user), true) " +
                "), " +
                "n_pay AS (" +
                "    INSERT INTO payment (user_id) " +
                "    VALUES ((SELECT id FROM n_user))" +
                ")" +
                "SELECT row_to_json(n_user) FROM n_user;";

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, id);
            pstmt.setString(2, pw);

            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                JSONObject jsonObject = new JSONObject(rs.getString(1));
                return new User(
                        jsonObject.getInt("id"),
                        jsonObject.getString("login_id"),
                        jsonObject.getString("login_pw"),
                        jsonObject.getString("nickname"),
                        null,
                        null,
                        null,
                        null,
                        null, // Assuming rating is not part of the return data
                        null,
                        true
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static void deleteUser(int userId) {
        String sql = "DELETE FROM akouser WHERE id = ?;";

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    // getFullUserData method
    public static User getFullUserData(String loginId) {
        String sql = "WITH result AS (" +
                "    SELECT akouser.*, auth.id_card, auth.phone, auth.authorized" +
                "    FROM akouser, authentication auth" +
                "    WHERE akouser.login_id = ? AND akouser.id = auth.user_id" +
                ")" +
                "SELECT row_to_json(result) FROM result;";

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, loginId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                JSONObject jsonObject = new JSONObject(rs.getString(1));
                JSONArray ratingsJsonArray = jsonObject.optJSONArray("rating");
                Rating[] ratings = null;

                if (ratingsJsonArray != null) {
                    ratings = new Rating[ratingsJsonArray.length()];
                    for (int i = 0; i < ratingsJsonArray.length(); i++) {
                        JSONObject ratingObj = ratingsJsonArray.getJSONObject(i);
                        ratings[i] = new Rating(
                                ratingObj.getDouble("rating"),
                                ratingObj.getInt("user_id")
                        );
                    }
                }

                return new User(
                        jsonObject.optInt("id", -1),
                        jsonObject.optString("login_id", null),
                        jsonObject.optString("login_pw", null),
                        jsonObject.optString("nickname", null),
                        jsonObject.optString("image", null),
                        jsonObject.has("campus") ? Campus.valueOf(jsonObject.getString("campus")) : null,
                        jsonObject.optString("department", null),
                        jsonObject.has("degree") ? Degree.valueOf(jsonObject.getString("degree")) : null,
                        jsonObject.optString("student_id", "").toCharArray(),
                        ratings,
                        jsonObject.optBoolean("isAdmin", false)
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static User getFullUserData(int Id) {
        String sql = "WITH result AS (" +
                "    SELECT akouser.*, auth.id_card, auth.phone, auth.authorized" +
                "    FROM akouser, authentication auth" +
                "    WHERE akouser.id = ? AND akouser.id = auth.user_id" +
                ")" +
                "SELECT row_to_json(result) FROM result;";

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, Id);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                JSONObject jsonObject = new JSONObject(rs.getString(1));
                JSONArray ratingsJsonArray = jsonObject.optJSONArray("rating");
                Rating[] ratings = null;

                if (ratingsJsonArray != null) {
                    ratings = new Rating[ratingsJsonArray.length()];
                    for (int i = 0; i < ratingsJsonArray.length(); i++) {
                        JSONObject ratingObj = ratingsJsonArray.getJSONObject(i);
                        ratings[i] = new Rating(
                                ratingObj.getDouble("rating"),
                                ratingObj.getInt("user_id")
                        );
                    }
                }

                return new User(
                        jsonObject.optInt("id", -1),
                        jsonObject.optString("login_id", null),
                        jsonObject.optString("login_pw", null),
                        jsonObject.optString("nickname", null),
                        jsonObject.optString("image", null),
                        jsonObject.has("campus") ? Campus.valueOf(jsonObject.getString("campus")) : null,
                        jsonObject.optString("department", null),
                        jsonObject.has("degree") ? Degree.valueOf(jsonObject.getString("degree")) : null,
                        jsonObject.optString("student_id", "").toCharArray(),
                        ratings,
                        jsonObject.optBoolean("isAdmin", false)
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static void verifyUser(int userId) {
        String sql = "UPDATE authentication SET authorized = true WHERE user_id = ?;";

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static int userAuth(String loginId, String loginPw) {
        String sql = "SELECT id FROM akouser WHERE login_id = ? AND login_pw = ?;";

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, loginId);
            pstmt.setString(2, loginPw);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("id");
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    // Method to add a new product and associated hashtags
    public static Product addProduct(String title, int price, String image, String description, int ownerId, String[] hashtags) {
        String sql = "WITH product_info AS ( " +
                "    INSERT INTO product(title, price, image, description, owner_id)  " +
                "    VALUES (?, ?, ?, ?, ?) " +
                "    RETURNING * " +
                "),  " +
                "hashtags AS ( " +
                "    SELECT * FROM UNNEST(string_to_array(?, ',')) " +
                "), " +
                "n_hashtag AS ( " +
                "    INSERT INTO hashtag(tag, product_id) " +
                "    SELECT x.*, (SELECT id FROM product_info) " +
                "    FROM hashtags x" +
                ") " +
                "SELECT json_build_object( " +
                "    'id', (SELECT id FROM product_info), " +
                "    'title', (SELECT title FROM product_info), " +
                "    'price', (SELECT price FROM product_info), " +
                "    'image', (SELECT image FROM product_info), " +
                "    'description', (SELECT description FROM product_info), " +
                "    'views', (SELECT views FROM product_info), " +
                "    'progress', (SELECT progress FROM product_info), " +
                "    'owner_id', (SELECT owner_id FROM product_info), " +
                "    'hashtags', array_to_json(array( " +
                "        SELECT * FROM hashtags " +
                "    )) " +
                ");";

        StringBuilder hashtagStr = new StringBuilder();
        for (int inHash = 0; inHash<hashtags.length; inHash++) {
            String hashtag = hashtags[inHash];
            if(inHash!=0)
                hashtagStr.append(',').append(hashtag);
            else hashtagStr.append(hashtag);

        }

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
        
            // Insert product
            pstmt.setString(1, title);
            pstmt.setInt(2, price);
            pstmt.setString(3, image);
            pstmt.setString(4, description);
            pstmt.setInt(5, ownerId);
            pstmt.setString(6, hashtagStr.toString());

            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                JSONObject jsonObject = new JSONObject(rs.getString(1));
                JSONArray hashtagJson = jsonObject.optJSONArray("hashtags");
                String[] hashtagarr = null;

                if (hashtagJson != null) {
                    hashtagarr = new String[hashtagJson.length()];
                    for (int i = 0; i < hashtags.length; i++) {
                        hashtagarr[i] = hashtagJson.getString(i);
                        hashtagarr[i] = hashtags[i].substring(1, hashtags[i].length()-1);
                    }
                }

                return new Product(
                        jsonObject.getInt("id"),
                        jsonObject.getString("title"),
                        jsonObject.getInt("price"),
                        jsonObject.getString("image"),
                        jsonObject.getString("description"),
                        jsonObject.getLong("views"),
                        jsonObject.getInt("owner_id"),
                        hashtagarr,
                        Progress.valueOf(jsonObject.getString("progress"))
                );
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static boolean modifyProduct(int productId, String title, int price, String image, String description, String[] hashtags) {
        String sql = "WITH product_info AS (" +
                "    UPDATE product SET title=?, price=?, image=?, description=? " +
                "    WHERE product.id=? " +
                "    RETURNING id " +
                "), " +
                "tags AS ( " +
                "    SELECT * FROM UNNEST(string_to_array(?, ',')) " +
                "), " +
                "del AS ( " +
                "    DELETE FROM hashtag " +
                "    WHERE " +
                "        product_id=(SELECT id FROM product_info) AND " +
                "        tag NOT IN (SELECT * FROM tags) " +
                "), " +
                "n_tags AS (" +
                "   INSERT INTO hashtag(tag, product_id) " +
                "   SELECT tags.* , (SELECT id FROM product_info) " +
                "   FROM tags " +
                "   ON CONFLICT DO NOTHING" +
                ") " +
                "SELECT id FROM product_info;";

        StringBuilder hashtagStr = new StringBuilder("");
        for (int i = 0 ; i < hashtags.length; ++i) {
            hashtagStr.append(hashtags[i] + ',');
        }

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);) {

            pstmt.setInt(5, productId);
            pstmt.setString(1, title);
            pstmt.setInt(2, price);
            pstmt.setString(3, image);
            pstmt.setString(4, description);
            pstmt.setString(6, hashtagStr.toString());

            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                if (rs.getInt("id") == productId) {
                    return true;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Method to delete a product by its ID
    public static boolean deleteProduct(int productId) {
        String sql = "DELETE FROM product WHERE id = ?;";

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, productId);
            return pstmt.executeUpdate() == 1;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static UserData getBriefUserData(int userId) {
        String sql = "WITH user_info AS ( " +
                "    SELECT * FROM akouser WHERE akouser.id=? " +
                "), " +
                "product_list AS ( " +
                "    SELECT * " +
                "    FROM product p WHERE p.owner_id=(SELECT id FROM user_info) " +
                ") " +
                "SELECT json_build_object( " +
                "    'id', (SELECT id FROM user_info), " +
                "    'login_id', (SELECT login_id FROM user_info), " +
                "    'nickname', (SELECT nickname FROM user_info), " +
                "    'image', (SELECT image FROM user_info), " +
                "    'campus', (SELECT campus FROM user_info), " +
                "    'department', (SELECT department FROM user_info), " +
                "    'degree', (SELECT degree FROM user_info), " +
                "    'student_id', (SELECT student_id FROM user_info), " +
                "    'rating', array_to_json((SELECT rating FROM user_info)), " +
                "    'products', array_to_json(array(" +
                "        SELECT row_to_json(product_list) FROM product_list " +
                "    )) " +
                ");";

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                JSONObject jsonObject = new JSONObject(rs.getString(1));

                User user = new User(
                        jsonObject.getInt("id"),
                        jsonObject.getString("login_id"),
                        null, // Password hash is not returned in brief data
                        jsonObject.getString("nickname"),
                        jsonObject.getString("image"),
                        jsonObject.has("campus") ? Campus.valueOf(jsonObject.getString("campus")) : null,
                        jsonObject.getString("department"),
                        jsonObject.has("degree") ? Degree.valueOf(jsonObject.getString("degree")) : null,
                        jsonObject.getString("student_id").toCharArray(),
                        new Rating[0], // Ratings are not returned in brief data
                        false // isAdmin is not part of brief data
                );

                JSONArray productArray = jsonObject.getJSONArray("products");
                Product[] products = new Product[productArray.length()];

                for (int i = 0; i < productArray.length(); ++i) {
                    JSONObject productJson = productArray.getJSONObject(i);
                    products[i] = new Product(
                            productJson.getInt("id"),
                            productJson.getString("title"),
                            productJson.getInt("price"),
                            productJson.getString("image"),
                            productJson.getString("description"),
                            productJson.getLong("views"),
                            productJson.getInt("owner_id"),
                            new String[0],
                            Progress.valueOf(productJson.getString("progress"))
                    );
                }

                return new UserData(
                        user,
                        products
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static ProductData getProductData(int productId) {
        String sql = "WITH product_info AS ( " +
                "    UPDATE product SET views=views+1 " +
                "    WHERE product.id=? " +
                "    RETURNING * " +
                "), " +
                "user_info AS ( " +
                "    SELECT u.id, u.nickname, u.image, u.campus, u.department, u.degree, u.student_id " +
                "    FROM akouser u WHERE u.id=(SELECT owner_id FROM product_info) " +
                "), " +
                "hashtags AS ( " +
                "    SELECT h.tag " +
                "    FROM hashtag h WHERE h.product_id=(SELECT id FROM product_info) " +
                ") " +
                "SELECT json_build_object( " +
                "    'id', (SELECT id FROM product_info), " +
                "    'title', (SELECT title FROM product_info), " +
                "    'price', (SELECT price FROM product_info), " +
                "    'image', (SELECT image FROM product_info), " +
                "    'description', (SELECT description FROM product_info), " +
                "    'views', (SELECT views FROM product_info), " +
                "    'progress', (SELECT progress FROM product_info), " +
                "    'user_info', (SELECT row_to_json(user_info) FROM user_info), " +
                "    'hashtags', array_to_json(array( " +
                "        SELECT * FROM hashtags " +
                "    )) " +
                ");";

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, productId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                JSONObject jsonObject = new JSONObject(rs.getString(1));
                JSONArray hashtagJson = jsonObject.optJSONArray("hashtags");
                String[] hashtags = null;

                if (hashtagJson != null) {
                    hashtags = new String[hashtagJson.length()];
                    for (int i = 0; i < hashtags.length; i++) {
                        hashtags[i] = hashtagJson.getString(i);
                    }
                }

                Product product = new Product(
                        jsonObject.getInt("id"),
                        jsonObject.getString("title"),
                        jsonObject.getInt("price"),
                        jsonObject.optString("image", null),
                        jsonObject.optString("description", null),
                        jsonObject.getLong("views"),
                        -1,
                        hashtags,
                        Progress.valueOf(jsonObject.getString("progress"))
                );

                JSONObject userJson = jsonObject.getJSONObject("user_info");
                JSONArray ratingsJson = jsonObject.optJSONArray("rating", null);
                Rating[] ratings = new Rating[0];

                if (ratingsJson != null) {
                    ratings = new Rating[ratingsJson.length()];
                    for (int i = 0; i < ratingsJson.length(); i++) {
                        JSONObject ratingObj = ratingsJson.getJSONObject(i);
                        ratings[i] = new Rating(
                                ratingObj.getDouble("rating"),
                                ratingObj.getInt("user_id")
                        );
                    }
                }

                User user = new User(
                        userJson.getInt("id"),
                        null,
                        null,
                        userJson.getString("nickname"),
                        userJson.getString("image"),
                        Campus.valueOf(userJson.getString("campus")),
                        userJson.getString("department"),
                        Degree.valueOf(userJson.getString("degree")),
                        userJson.getString("student_id").toCharArray(),
                        ratings,
                        false
                );
                
                return new ProductData(
                        product,
                        user
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Method to add a product to the wishlist
    public static boolean addWishList(int userId, int productId) {
        // SQL to insert wishlist entry if it doesn't already exist
        String sql = "INSERT INTO list_wish (owner_id, buyer_id, product_id) " +
                "SELECT p.owner_id, ?, p.id FROM product p " +
                "WHERE p.id = ? AND NOT EXISTS (" +
                "    SELECT 1 FROM list_wish w " +
                "    WHERE w.product_id = ? AND w.buyer_id = ?" +
                ")";

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            // Set parameters for the prepared statement
            pstmt.setInt(1, userId);
            pstmt.setInt(2, productId);
            pstmt.setInt(3, productId);
            pstmt.setInt(4, userId);

            // Execute the insert operation
            int affectedRows = pstmt.executeUpdate();

            // Return true if the row was inserted, false otherwise
            return affectedRows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // Method to get a list of products on the user's wishlist
    public static Wishlist[] getWishList(int userId) {
        String sql = "WITH products AS (" +
                "    SELECT p.* FROM product p " +
                "    WHERE p.id = ANY (" +
                "        SELECT product_id FROM list_wish w WHERE w.buyer_id = ?" +
                "    )" +
                ")" +
                "SELECT array_to_json(array (" +
                "    SELECT json_build_object(" +
                "        'id', p.id," +
                "        'title', p.title," +
                "        'price', p.price," +
                "        'image', p.image," +
                "        'description', p.description," +
                "        'views', p.views," +
                "        'progress', p.progress, " +
                "        'user_info', (" +
                "            SELECT row_to_json(user_info) FROM (" +
                "                SELECT u.id, u.nickname FROM akouser u WHERE u.id = p.owner_id" +
                "            ) AS user_info" +
                "        )," +
                "        'hashtags', (" +
                "            SELECT array_to_json(array (" +
                "                SELECT h.tag FROM hashtag h WHERE h.product_id = p.id" +
                "            ))" +
                "        )" +
                "    ) FROM products p" +
                "));";

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                JSONArray jsonArray = new JSONArray(rs.getString(1));
                Wishlist[] wishlists = new Wishlist[jsonArray.length()];

                for (int i = 0; i < jsonArray.length(); ++i) {
                    JSONObject jsonObject = jsonArray.getJSONObject(i);
                    JSONArray hashtagJson = jsonObject.optJSONArray("hashtags");
                    String[] hashtags = null;

                    if (hashtagJson != null) {
                        hashtags = new String[hashtagJson.length()];
                        for (int j = 0; j < hashtags.length; j++) {
                            JSONObject hashtagObj = hashtagJson.getJSONObject(j);
                            hashtags[j] = hashtagObj.toString();
                        }
                    }


                    Product product = new Product(
                            jsonObject.getInt("id"),
                            jsonObject.getString("title"),
                            jsonObject.getInt("price"),
                            jsonObject.getString("image"),
                            jsonObject.getString("description"),
                            jsonObject.getLong("views"),
                            -1,
                            hashtags,
                            Progress.valueOf(jsonObject.getString("progress"))
                    );

                    JSONObject userJson = new JSONObject(jsonObject.getString("user_info"));
                    User user = new User(
                            userJson.getInt("id"),
                            null,
                            null,
                            userJson.getString("nickname"),
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            false
                    );

                    wishlists[i] = new Wishlist(
                            product,
                            user,
                            Progress.valueOf(jsonObject.getString("progress"))
                    );
                }

                return wishlists;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public static void createChatRoom(int user1, int user2) {
        String sql = "WITH info AS ( " +
                "    SELECT ? AS user1, ? AS user2 " +
                ") " +
                "INSERT INTO list_chat(user1, user2) " +
                "SELECT " +
                "    (SELECT user1 FROM info), " +
                "    (SELECT user2 FROM info) " +
                "WHERE NOT EXISTS ( " +
                "    SELECT * FROM list_chat l " +
                "    WHERE " +
                "        (l.user1=(SELECT user1 FROM info) AND l.user2=(SELECT user2 FROM info)) OR " +
                "        (l.user2=(SELECT user1 FROM info) AND l.user1=(SELECT user2 FROM info)) " +
                ");";

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, user1);
            pstmt.setInt(2, user2);
            ResultSet rs = pstmt.executeQuery();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static boolean buyRequest(int userId, int productId, String message) {
        String sql = "WITH info AS ( " +
                "    SELECT p.id, p.price, p.owner_id, u.id AS buyer_id " +
                "    FROM product p, akouser u  " +
                "    WHERE u.id=? AND p.id=? " +
                "), " +
                "n_progress AS ( " +
                "    INSERT INTO list_trade(owner_id, buyer_id, product_id, progress) " +
                "    SELECT " +
                "        (SELECT owner_id FROM info), " +
                "        (SELECT buyer_id FROM info),  " +
                "        (SELECT id FROM info), " +
                "        'applied' " +
                "    WHERE NOT EXISTS ( " +
                "        SELECT id FROM list_trade p " +
                "        WHERE " +
                "            p.product_id=(SELECT id FROM info) AND " +
                "            p.buyer_id=(SELECT buyer_id FROM info) " +
                "    ) " +
                "    RETURNING * " +
                "), " +
                "user_pay AS ( " +
                "    UPDATE payment SET point=payment.point-(SELECT price FROM info) " +
                "    WHERE payment.user_id=(SELECT buyer_id FROM info) " +
                "), " +
                "del_wish AS ( " +
                "    DELETE FROM list_wish w " +
                "    WHERE  " +
                "        w.buyer_id=(SELECT buyer_id FROM n_progress) AND " +
                "        w.product_id=(SELECT product_id FROM n_progress) " +
                "), " +
                "l_chat AS ( " +
                "    UPDATE list_chat AS c " +
                "    SET  " +
                "        last_chat_idx=c.last_chat_idx+1, " +
                "        last_chat=?, " +
                "        user1_read= " +
                "            CASE WHEN user1=(SELECT buyer_id FROM info) " +
                "            THEN c.last_chat_idx+1 " +
                "            ELSE user1_read END, " +
                "        user2_read= " +
                "            CASE WHEN user2=(SELECT buyer_id FROM info) " +
                "            THEN c.last_chat_idx+1 " +
                "            ELSE user2_read END " +
                "    WHERE " +
                "        (user1=(SELECT owner_id FROM INFO) AND user2=(SELECT buyer_id FROM INFO)) OR " +
                "        (user2=(SELECT owner_id FROM INFO) AND user1=(SELECT buyer_id FROM INFO)) " +
                "    RETURNING * " +
                ") " +
                "INSERT INTO chat(id, idx, message, sender, system) " +
                "VALUES ( " +
                "    (SELECT id FROM l_chat), " +
                "    (SELECT last_chat_idx FROM l_chat), " +
                "    (SELECT last_chat FROM l_chat), " +
                "    (SELECT buyer_id FROM info), " +
                "    'request'::sys_msg_t " +
                "); ";

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            pstmt.setInt(2, productId);
            pstmt.setString(3, message);
            return pstmt.executeUpdate() == 1;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }
    public static ProgressData[] getBuyRequests(int userId) {
        String sql = "WITH requests AS ( " +
                "    SELECT r.id, r.buyer_id, r.product_id, r.progress " +
                "    FROM list_trade r " +
                "    WHERE r.owner_id=? AND r.progress='applied' " +
                ") " +
                "SELECT array_to_json(array( " +
                "    SELECT json_build_object( " +
                "        'id', r.id, " +
                "        'buyer', ( " +
                "            SELECT row_to_json(u) FROM akouser u " +
                "            WHERE u.id=r.buyer_id " +
                "        ), " +
                "        'product', ( " +
                "            SELECT row_to_json(p) FROM product p " +
                "            WHERE p.id=r.product_id " +
                "        ), " +
                "        'progress', r.progress " +
                "    ) FROM requests r " +
                ")); ";

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                JSONArray jsonArray = new JSONArray(rs.getString(1));
                ProgressData[] datas = new ProgressData[jsonArray.length()];

                for (int i = 0; i < jsonArray.length(); i++) {
                    JSONObject jsonObject = jsonArray.getJSONObject(i);
                    JSONObject productObject = new JSONObject(jsonObject.getString("product"));
                    Product product = new Product(
                            productObject.getInt("id"),
                            productObject.getString("title"),
                            productObject.getInt("price"),
                            productObject.getString("image"),
                            productObject.getString("description"),
                            productObject.getLong("views"),
                            -1,
                            null,
                            Progress.valueOf(jsonObject.getString("progress"))
                    );

                    JSONObject userJson = new JSONObject(jsonObject.getString("buyer"));
                    User user = new User(
                            userJson.getInt("id"),
                            null,
                            null,
                            userJson.getString("nickname"),
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            false
                    );

                    datas[i] = new ProgressData(
                            jsonObject.getInt("id"),
                            user,
                            product,
                            Progress.valueOf(jsonObject.getString("progress"))
                    );
                }

                return datas;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public static boolean acceptBuyRequest(int userId, int productId, String message) {
        String sql = "WITH req_product AS ( " +
                "    SELECT p.* FROM product p WHERE p.id=? " +
                "), " +
                "prog AS ( " +
                "    UPDATE list_trade AS p SET progress='inprogress' " +
                "    WHERE  " +
                "        p.owner_id=(SELECT owner_id FROM req_product) AND " +
                "        p.buyer_id=? AND " +
                "        p.product_id=(SELECT id FROM req_product) AND " +
                "        p.progress='applied'::progress_t " +
                "    RETURNING * " +
                "), " +
                "u_product AS ( " +
                "    UPDATE product AS p SET progress='inprogress' " +
                "    WHERE p.id=(SELECT product_id FROM prog) " +
                "), " +
                "l_chat AS ( " +
                "    UPDATE list_chat AS c " +
                "    SET  " +
                "        last_chat_idx=c.last_chat_idx+1, " +
                "        last_chat=?, " +
                "        user1_read= " +
                "            CASE WHEN user1=(SELECT owner_id FROM prog) " +
                "            THEN c.last_chat_idx+1 " +
                "            ELSE user1_read END, " +
                "        user2_read= " +
                "            CASE WHEN user2=(SELECT owner_id FROM prog) " +
                "            THEN c.last_chat_idx+1 " +
                "            ELSE user2_read END " +
                "    WHERE " +
                "        (c.user1=(SELECT owner_id FROM prog) AND c.user2=(SELECT buyer_id FROM prog)) OR " +
                "        (c.user2=(SELECT owner_id FROM prog) AND c.user1=(SELECT buyer_id FROM prog)) " +
                "    RETURNING * " +
                ") " +
                "INSERT INTO chat(id, idx, message, sender, system) " +
                "VALUES ( " +
                "    (SELECT id FROM l_chat), " +
                "    (SELECT last_chat_idx FROM l_chat), " +
                "    (SELECT last_chat FROM l_chat), " +
                "    (SELECT owner_id FROM prog), " +
                "    'accept' " +
                ");";

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement((sql))) {

            pstmt.setInt(1, productId);
            pstmt.setInt(2, userId);
            pstmt.setString(3, message);

            return pstmt.executeUpdate() == 1;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public static boolean cancelBuyRequest(int userId, int productId, String message) {
        String sql = "WITH req AS ( " +
                "    SELECT u.id, p.id AS product_id  " +
                "    FROM akouser u, product p " +
                "    WHERE u.id=? AND p.id=? " +
                "), " +
                "prog AS ( " +
                "    DELETE FROM list_trade p " +
                "    WHERE ( " +
                "        p.owner_id=(SELECT id FROM req) OR  " +
                "        p.buyer_id=(SELECT id FROM req) " +
                "        ) AND p.product_id=(SELECT product_id FROM req) " +
                "    RETURNING * " +
                "),  " +
                "can_product AS ( " +
                "    UPDATE product AS p SET progress='none'::progress_t " +
                "    WHERE p.id=(SELECT product_id FROM prog) " +
                "    RETURNING * " +
                "), " +
                "buyer_pay AS ( " +
                "    UPDATE payment SET point=payment.point+(SELECT price FROM can_product) " +
                "    WHERE payment.user_id=(SELECT buyer_id FROM prog) " +
                "), " +
                "l_chat AS ( " +
                "    UPDATE list_chat AS c " +
                "    SET  " +
                "        last_chat_idx=c.last_chat_idx+1, " +
                "        last_chat=?, " +
                "        user1_read= " +
                "            CASE WHEN user1=(SELECT id FROM req) " +
                "            THEN c.last_chat_idx+1 " +
                "            ELSE user1_read END, " +
                "        user2_read= " +
                "            CASE WHEN user2=(SELECT id FROM req) " +
                "            THEN c.last_chat_idx+1 " +
                "            ELSE user2_read END " +
                "    WHERE " +
                "        (c.user1=(SELECT owner_id FROM prog) AND c.user2=(SELECT buyer_id FROM prog)) OR " +
                "        (c.user2=(SELECT owner_id FROM prog) AND c.user1=(SELECT buyer_id FROM prog)) " +
                "    RETURNING * " +
                ") " +
                "INSERT INTO chat(id, idx, message, sender, system) " +
                "VALUES ( " +
                "    (SELECT id FROM l_chat), " +
                "    (SELECT last_chat_idx FROM l_chat), " +
                "    (SELECT last_chat FROM l_chat), " +
                "    (SELECT id FROM req), " +
                "    'cancel'::sys_msg_t " +
                ");";


        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            pstmt.setInt(2, productId);
            pstmt.setString(3, message);

            return pstmt.executeUpdate() == 1;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public static boolean confirmGive(int productId, String message) {
        String sql = "WITH req AS ( " +
                "    UPDATE list_trade SET progress='sellergive' " +
                "    WHERE progress='inprogress' AND product_id=? " +
                "    RETURNING * " +
                "), " +
                "u_product AS ( " +
                "    UPDATE product AS p SET progress='sellergive' " +
                "    WHERE p.id=(SELECT product_id FROM req) " +
                "), " +
                "l_chat AS ( " +
                "    UPDATE list_chat AS c " +
                "    SET " +
                "        last_chat_idx=c.last_chat_idx+1, " +
                "        last_chat=?, " +
                "        user1_read= " +
                "            CASE WHEN user1=(SELECT owner_id FROM req) " +
                "            THEN c.last_chat_idx+1 " +
                "            ELSE user1_read END, " +
                "        user2_read= " +
                "            CASE WHEN user2=(SELECT owner_id FROM req) " +
                "            THEN c.last_chat_idx+1 " +
                "            ELSE user2_read END " +
                "    WHERE " +
                "       (c.user1=(SELECT owner_id FROM req) AND c.user2=(SELECT buyer_id FROM req)) OR" +
                "       (c.user2=(SELECT owner_id FROM req) AND c.user1=(SELECT buyer_id FROM req)) " +
                "    RETURNING * " +
                ") " +
                "INSERT INTO chat(id, idx, message, sender, system) " +
                "VALUES ( " +
                "    (SELECT id FROM l_chat), " +
                "    (SELECT last_chat_idx FROM l_chat), " +
                "    (SELECT last_chat FROM l_chat), " +
                "    (SELECT owner_id FROM req), " +
                "    'give'::sys_msg_t " +
                ");";
        
        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, productId);
            pstmt.setString(2, message);

            return pstmt.executeUpdate() == 1;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public static boolean confirmGot(int productId, String message) {
        String sql = "WITH req AS ( " +
                "    UPDATE list_trade AS s SET progress='soldout' " +
                "    WHERE s.progress='sellergive' AND s.product_id=? " +
                "    RETURNING * " +
                "), " +
                "l_chat AS ( " +
                "    UPDATE list_chat AS c " +
                "    SET " +
                "        last_chat_idx=c.last_chat_idx+1, " +
                "        last_chat=?, " +
                "        user1_read= " +
                "            CASE WHEN user1=(SELECT buyer_id FROM req) " +
                "            THEN c.last_chat_idx+1 " +
                "            ELSE user1_read END, " +
                "        user2_read= " +
                "            CASE WHEN user2=(SELECT buyer_id FROM req) " +
                "            THEN c.last_chat_idx+1 " +
                "            ELSE user2_read END " +
                "    WHERE " +
                "        (c.user1=(SELECT owner_id FROM req) AND c.user2=(SELECT buyer_id FROM req)) OR " +
                "        (c.user2=(SELECT owner_id FROM req) AND c.user1=(SELECT buyer_id FROM req)) " +
                "    RETURNING * " +
                ") " +
                "INSERT INTO chat(id, idx, message, sender, system) " +
                "VALUES ( " +
                "    (SELECT id FROM l_chat), " +
                "    (SELECT last_chat_idx FROM l_chat), " +
                "    (SELECT last_chat FROM l_chat), " +
                "    (SELECT owner_id FROM req), " +
                "    'got'::sys_msg_t " +
                "); ";

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, productId);
            pstmt.setString(2, message);

            return pstmt.executeUpdate() == 1;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public static Chatlist[] getChatPreview(int userId) {
        String sql = "WITH l_chat AS ( " +
                "    SELECT c.* FROM list_chat c " +
                "    WHERE c.user1=? OR c.user2=? " +
                "    ORDER BY c.last_time DESC " +
                ") " +
                "SELECT array_to_json(array( " +
                "    SELECT json_build_object( " +
                "        'id', c.id, " +
                "        'user1', ( " +
                "            SELECT row_to_json(u) FROM akouser u " +
                "            WHERE u.id=c.user1 " +
                "        ), " +
                "        'user2', ( " +
                "            SELECT row_to_json(u) FROM akouser u " +
                "            WHERE u.id=c.user2 " +
                "        ), " +
                "        'user1_read', c.user1_read, " +
                "        'user2_read', c.user2_read, " +
                "        'last_chat', c.last_chat, " +
                "        'last_chat_idx', c.last_chat_idx, " +
                "        'last_time', c.last_time " +
                "    ) FROM l_chat c " +
                ")); "; 
                
        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            pstmt.setInt(2, userId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                JSONArray jsonArray = new JSONArray(rs.getString(1));
                Chatlist[] chatlists = new Chatlist[jsonArray.length()];
                for (int i = 0; i < jsonArray.length(); i++) {
                    JSONObject jsonObject = jsonArray.getJSONObject(i);
                    JSONObject user1Obj = jsonObject.getJSONObject("user1");
                    JSONObject user2Obj = jsonObject.getJSONObject("user2");

                    User user1 = new User(
                            user1Obj.getInt("id"),
                            null,
                            null,
                            user1Obj.getString("nickname"),
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            false
                    );

                    User user2 = new User(
                            user2Obj.getInt("id"),
                            null,
                            null,
                            user2Obj.getString("nickname"),
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            false
                    );

                    chatlists[i] = new Chatlist(
                            jsonObject.getInt("id"),
                            user1,
                            user2,
                            jsonObject.getInt("user1_read"),
                            jsonObject.getInt("user2_read"),
                            jsonObject.optString("last_chat", null),
                            jsonObject.getInt("last_chat_idx"),
                            jsonObject.optString("last_time", null)
                    );
                }

                return chatlists;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public static boolean sendChat(int userId, int chatId, String message) {
        String sql = "WITH req AS ( " +
                "    SELECT u.id, c.id AS chat_id, ? AS msg " +
                "    FROM akouser u, list_chat c " +
                "    WHERE u.id=? AND c.id=? " +
                "), " +
                "l_chat AS ( " +
                "    UPDATE list_chat AS c " +
                "    SET " +
                "        last_chat_idx=c.last_chat_idx+1, " +
                "        last_chat=(SELECT msg FROM req), " +
                "        user1_read= " +
                "            CASE WHEN user1=(SELECT id FROM req) " +
                "            THEN c.last_chat_idx+1 " +
                "            ELSE user1_read END, " +
                "        user2_read= " +
                "            CASE WHEN user2=(SELECT id FROM req) " +
                "            THEN c.last_chat_idx+1 " +
                "            ELSE user2_read END " +
                "    WHERE c.id=(SELECT chat_id FROM req) " +
                "    RETURNING * " +
                ") " +
                "INSERT INTO chat(id, idx, message, sender) " +
                "VALUES ( " +
                "    (SELECT chat_id FROM req), " +
                "    (SELECT last_chat_idx FROM l_chat), " +
                "    (SELECT msg FROM req), " +
                "    (SELECT id FROM req) " +
                ");";

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, message);
            pstmt.setInt(2, userId);
            pstmt.setInt(3, chatId);
            return pstmt.executeUpdate() == 1;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean addRating(int sellerId, int buyerId, double rating) {
        String sql = "UPDATE akouser SET rating = array_append( " +
                "    rating, ROW(?, ?)::rating_t " +
                ") " +
                "WHERE akouser.id=?;";

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setDouble(1, rating);
            pstmt.setInt(2, buyerId);
            pstmt.setInt(3, sellerId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }

        } catch (Exception e) {
            e.printStackTrace();;
        }
        return false;
    }

    public static Chat[] getChat(int chatId, int userId) {
        String sql = "WITH l_chat AS ( " +
                "    SELECT * FROM chat c WHERE id=? " +
                "    ORDER BY c.time  " +
                "), " +
                "u_chat AS ( " +
                "    UPDATE list_chat AS c " +
                "    SET " +
                "        user1_read= " +
                "            CASE WHEN user1=? " +
                "            THEN c.last_chat_idx " +
                "            ELSE user1_read END, " +
                "        user2_read= " +
                "            CASE WHEN user2=? " +
                "            THEN c.last_chat_idx " +
                "            ELSE user2_read END " +
                "    WHERE c.id=? " +
                ") " +
                "SELECT array_to_json(array( " +
                "    SELECT json_build_object( " +
                "        'id', c.id, " +
                "        'idx', c.idx, " +
                "        'message', c.message, " +
                "        'sender', c.sender, " +
                "        'time', c.time, " +
                "        'system', c.system " +
                "    ) FROM l_chat c " +
                "));";

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, chatId);
            pstmt.setInt(2, userId);
            pstmt.setInt(3, userId);
            pstmt.setInt(4, chatId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                JSONArray jsonArray = new JSONArray(rs.getString(1));
                Chat[] chats = new Chat[jsonArray.length()];

                for (int i = 0; i < jsonArray.length(); ++i) {
                    JSONObject jsonObject = jsonArray.getJSONObject(i);
                    chats[i] = new Chat(
                            jsonObject.getInt("id"),
                            jsonObject.getInt("idx"),
                            jsonObject.getString("message"),
                            jsonObject.getInt("sender"),
                            jsonObject.getString("time"),
                            MessageType.valueOf(jsonObject.getString("system"))
                    );
                }

                return chats;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public static String parseHashtag(String tagStr) {
        String tag = tagStr.replaceAll("#", ",").replaceAll("\\s+", ",");

        if (tag.charAt(0) == ',') {
            tag = tag.substring(1);
        }

        return tag;
    }

    public static ArrayList<ProductData> search(double hWeight, double tWeight, double dWeight, String hashtag, String pattern) {
        String sql = "WITH search_result AS ( " +
                "    WITH h_score AS ( " +
                "        SELECT s.id, COUNT(s.id) AS score FROM ( " +
                "            SELECT h.product_id AS id FROM hashtag h " +
                "            WHERE h.tag LIKE ANY(string_to_array(?, ',')) " +
                "        ) s " +
                "        GROUP BY s.id " +
                "    ), " +
                "    t_score AS ( " +
                "        SELECT id, 1 AS score FROM ( " +
                "            SELECT p.id AS id FROM product p " +
                "            WHERE p.title ~ ANY(string_to_array(?, ',')) " +
                "        ) t " +
                "    ), " +
                "    d_score AS ( " +
                "        SELECT id, score FROM ( " +
                "            SELECT ts_rank_cd( " +
                "                to_tsvector(p.description),  " +
                "                to_tsquery(?) " +
                "            ) AS score, p.id  " +
                "            FROM product p " +
                "        ) d " +
                "    ), " +
                "    product_ids AS ( " +
                "        SELECT id FROM h_score UNION  " +
                "        SELECT id FROM t_score UNION  " +
                "        SELECT id FROM d_score " +
                "    ) " +
                "    SELECT p.id, ( " +
                "        (COALESCE((SELECT score FROM h_score WHERE h_score.id=p.id), 0) * ?) + " +
                "        (COALESCE((SELECT score FROM t_score WHERE t_score.id=p.id), 0) * ?) + " +
                "        (COALESCE((SELECT score FROM d_score WHERE d_score.id=p.id), 0) * ?) " +
                "    ) AS score FROM product_ids p " +
                "), " +
                "products AS ( " +
                "    SELECT p.*, r.score FROM product p, search_result r " +
                "    WHERE p.id=ANY(SELECT id FROM search_result) AND p.id=r.id AND score > 0 " +
                "    ORDER BY score DESC, p.views DESC " +
                ") " +
                "SELECT array_to_json(array( " +
                "    SELECT json_build_object( " +
                "        'id', p.id, " +
                "        'title', p.title, " +
                "        'price', p.price, " +
                "        'image', p.image, " +
                "        'description', p.description, " +
                "        'views', p.views, " +
                "        'progress', p.progress, " +
                "        'user_info', ( " +
                "            SELECT row_to_json(user_info)  " +
                "            FROM ( " +
                "                SELECT u.id, u.nickname  " +
                "                FROM akouser u WHERE u.id=p.owner_id " +
                "            ) AS user_info), " +
                "        'hashtags', ( " +
                "            SELECT array_to_json(array( " +
                "                SELECT h.tag " +
                "                FROM hashtag h WHERE h.product_id=p.id " +
                "            )))  " +
                "    ) FROM products p " +
                "));";

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            String titleP = pattern.replaceAll("\\s+", ",");
            String descP = pattern.replaceAll("\\s+", "|");

            if (titleP.charAt(titleP.length()-1) == ',') {
                titleP = titleP.substring(0, titleP.length() - 1);
            }
            if (descP.charAt(descP.length() - 1) == '|') {
                descP = descP.substring(0, descP.length() - 1);
            }

            pstmt.setString(1, hashtag);
            pstmt.setString(2, titleP);
            pstmt.setString(3, descP);
            pstmt.setDouble(4, hWeight);
            pstmt.setDouble(5, tWeight);
            pstmt.setDouble(6, dWeight);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                JSONArray jsonArray = new JSONArray(rs.getString(1));
                ArrayList<ProductData> result = new ArrayList<ProductData>();
                for (int i = 0; i < jsonArray.length(); ++i) {
                    JSONObject jsonObject = jsonArray.getJSONObject(i);
                    JSONArray hashtagJson = jsonObject.optJSONArray("hashtags");
                    String[] hashtags = null;

                    if (hashtagJson != null) {
                        hashtags = new String[hashtagJson.length()];
                        for (int j = 0; j < hashtags.length; j++) {
                            hashtags[j] = hashtagJson.getString(j);
                        }
                    }

                    Product product = new Product(
                            jsonObject.getInt("id"),
                            jsonObject.getString("title"),
                            jsonObject.getInt("price"),
                            jsonObject.optString("image", null),
                            jsonObject.optString("description", null),
                            jsonObject.getLong("views"),
                            -1,
                            hashtags,
                            Progress.valueOf(jsonObject.getString("progress"))
                    );

                    JSONObject userJson = jsonObject.getJSONObject("user_info");
                    User user = new User(
                            userJson.getInt("id"),
                            null,
                            null,
                            userJson.getString("nickname"),
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            false
                    );

                    result.add( new ProductData(
                            product,
                            user
                    ));
                }

                return result;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public static ProductData[] getPopularProducts() {
        String sql = "WITH products AS ( " +
                "    SELECT * FROM product " +
                "    ORDER BY views DESC " +
                "    LIMIT 3 " +
                ") " +
                "SELECT array_to_json(array( " +
                "    SELECT json_build_object( " +
                "        'id', p.id, " +
                "        'title', p.title, " +
                "        'price', p.price, " +
                "        'image', p.image, " +
                "        'description', p.description, " +
                "        'views', p.views, " +
                "        'progress', p.progress, " +
                "        'user_info', ( " +
                "            SELECT row_to_json(user_info)  " +
                "            FROM ( " +
                "                SELECT u.id, u.nickname  " +
                "                FROM akouser u WHERE u.id=p.owner_id " +
                "            ) AS user_info), " +
                "        'hashtags', ( " +
                "            SELECT array_to_json(array( " +
                "                SELECT h.tag " +
                "                FROM hashtag h WHERE h.product_id=p.id " +
                "            )))  " +
                "    ) FROM products p " +
                "));";

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                JSONArray jsonArray = new JSONArray(rs.getString(1));
                ProductData[] result = new ProductData[jsonArray.length()];
                for (int i = 0; i < jsonArray.length(); ++i) {
                    JSONObject jsonObject = jsonArray.getJSONObject(i);
                    JSONArray hashtagJson = jsonObject.optJSONArray("hashtags");
                    String[] hashtags = null;

                    if (hashtagJson != null) {
                        hashtags = new String[hashtagJson.length()];
                        for (int j = 0; j < hashtags.length; j++) {
                            hashtags[j] = hashtagJson.getString(j);
                        }
                    }

                    Product product = new Product(
                            jsonObject.getInt("id"),
                            jsonObject.getString("title"),
                            jsonObject.getInt("price"),
                            jsonObject.optString("image", null),
                            jsonObject.optString("description", null),
                            jsonObject.getLong("views"),
                            -1,
                            hashtags,
                            Progress.valueOf(jsonObject.getString("progress"))
                    );

                    JSONObject userJson = jsonObject.getJSONObject("user_info");
                    User user = new User(
                            userJson.getInt("id"),
                            null,
                            null,
                            userJson.getString("nickname"),
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            false
                    );

                    result[i] = new ProductData(
                            product,
                            user
                    );
                }

                return result;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}