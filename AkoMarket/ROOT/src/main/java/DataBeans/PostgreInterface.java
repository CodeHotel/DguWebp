package DataBeans;

import java.sql.*;
import java.util.StringJoiner;

import org.json.JSONArray;
import org.json.JSONObject;

public class PostgreInterface {

    public static User registerUser(String id, String pw, String nickname, String image, String id_card, String phone, String campus, String department, String degree, String studentId) {
        String sql = "WITH n_user AS (" +
                "    INSERT INTO akouser (login_id, login_pw, nickname, image, campus, deparment, degree, student_id)" +
                "    VALUES (?, ?, ?, ?, ?, ?, ?, ?) " +
                "    RETURNING id, login_id, login_pw, nickname, image, campus, deparment, degree, student_id" +
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
                        jsonObject.optString("login_id", null),
                        jsonObject.optString("login_pw", null),
                        jsonObject.optString("nickname", null),
                        jsonObject.optString("image", null),
                        jsonObject.has("campus") ? Campus.valueOf(jsonObject.getString("campus")) : null,
                        jsonObject.optString("department", null),
                        jsonObject.has("degree") ? Degree.valueOf(jsonObject.getString("degree")) : null,
                        jsonObject.optString("student_id", "").toCharArray(),
                        null, // Assuming rating is not part of the return data
                        jsonObject.optBoolean("isAdmin", false)
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
    public static User getFullUserData(String nickname) {
        String sql = "WITH result AS (" +
                "    SELECT akouser.*, auth.id_card, auth.phone, auth.authorized, akouser.rating" +
                "    FROM akouser, authentication auth" +
                "    WHERE akouser.nickname = ? AND akouser.id = auth.user_id" +
                ")" +
                "SELECT row_to_json(result) FROM result;";

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, nickname);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                JSONObject jsonObject = new JSONObject(rs.getString(1));
                JSONArray ratingsJsonArray = jsonObject.optJSONArray("rating");
                double[] ratings = null;

                if (ratingsJsonArray != null) {
                    ratings = new double[ratingsJsonArray.length()];
                    for (int i = 0; i < ratingsJsonArray.length(); i++) {
                        JSONObject ratingObj = ratingsJsonArray.getJSONObject(i);
                        double ratingValue = ratingObj.optDouble("rating");
                        ratings[i] = ratingValue;
                    }
                }

                return new User(
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
        String sqlProduct = "INSERT INTO product(title, price, image, description, owner_id) " +
                "VALUES (?, ?, ?, ?, ?) RETURNING id;";
        String sqlHashtag = "INSERT INTO hashtag(tag, product_id) VALUES (?, ?);";

        ResultSet rs = null;
        Product product = null;
        Connection conn = null;

        try {
            conn = PostgreConnect.getStmt().getConnection();
            PreparedStatement pstmtProduct = conn.prepareStatement(sqlProduct, PreparedStatement.RETURN_GENERATED_KEYS);
            PreparedStatement pstmtHashtag = conn.prepareStatement(sqlHashtag);

            // Disable auto-commit mode
            conn.setAutoCommit(false);

            // Insert product
            pstmtProduct.setString(1, title);
            pstmtProduct.setInt(2, price);
            pstmtProduct.setString(3, image);
            pstmtProduct.setString(4, description);
            pstmtProduct.setInt(5, ownerId);
            pstmtProduct.executeUpdate();

            // Retrieve the generated product ID
            rs = pstmtProduct.getGeneratedKeys();
            int productId = 0;
            if (rs.next()) {
                productId = rs.getInt(1);
            }

            // Insert hashtags
            for (String tag : hashtags) {
                pstmtHashtag.setString(1, tag);
                pstmtHashtag.setInt(2, productId);
                pstmtHashtag.addBatch();
            }
            pstmtHashtag.executeBatch();

            // Commit changes
            conn.commit();

            // Create a product object to return
            product = new Product(productId, price, image, description, 0, ownerId);

            pstmtProduct.close();
            pstmtHashtag.close();

        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback(); // Rollback on error
                } catch (SQLException exRollback) {
                    exRollback.printStackTrace();
                }
            }
        } finally {
            if (rs != null) {
                try {
                    rs.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }

        return product;
    }

    public static boolean modifyProduct(int productId, String title, int price, String image, String description, String[] hashtags) {
        Connection conn = null;
        boolean success = false;

        String updateProductSql = "UPDATE product SET title = ?, price = ?, image = ?, description = ? WHERE id = ? RETURNING id;";
        String deleteHashtagsSql = "DELETE FROM hashtag WHERE product_id = ? AND tag NOT IN (SELECT unnest(?::varchar[]));";
        String insertHashtagsSql = "INSERT INTO hashtag(tag, product_id) SELECT unnest(?::varchar[]), ? ON CONFLICT (tag, product_id) DO NOTHING;";

        try {
            conn = PostgreConnect.getStmt().getConnection();
            conn.setAutoCommit(false); // Start transaction

            // Update product details
            try (PreparedStatement pstmtUpdateProduct = conn.prepareStatement(updateProductSql)) {
                pstmtUpdateProduct.setString(1, title);
                pstmtUpdateProduct.setInt(2, price);
                pstmtUpdateProduct.setString(3, image);
                pstmtUpdateProduct.setString(4, description);
                pstmtUpdateProduct.setInt(5, productId);
                pstmtUpdateProduct.execute();
            }

            // Convert hashtags to a PostgreSQL array representation
            String[] tagArray = hashtags;
            Array tagSqlArray = conn.createArrayOf("varchar", tagArray);

            // Delete old hashtags not present in the new list
            try (PreparedStatement pstmtDeleteHashtags = conn.prepareStatement(deleteHashtagsSql)) {
                pstmtDeleteHashtags.setInt(1, productId);
                pstmtDeleteHashtags.setArray(2, tagSqlArray);
                pstmtDeleteHashtags.execute();
            }

            // Insert new hashtags, ignoring conflicts
            try (PreparedStatement pstmtInsertHashtags = conn.prepareStatement(insertHashtagsSql)) {
                pstmtInsertHashtags.setArray(1, tagSqlArray);
                pstmtInsertHashtags.setInt(2, productId);
                pstmtInsertHashtags.execute();
            }

            conn.commit(); // Commit transaction
            success = true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException exRollback) {
                    exRollback.printStackTrace();
                }
            }
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }

        return success;
    }

    // Method to delete a product by its ID
    public static boolean deleteProduct(int productId) {
        String sql = "DELETE FROM product WHERE id = ?;";

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, productId);
            int affectedRows = pstmt.executeUpdate();

            // If affectedRows is 1, the delete operation was successful.
            return affectedRows == 1;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static User getBriefUserData(int userId) {
        String sql = "WITH user_info AS (" +
                "    SELECT * FROM akouser WHERE akouser.id = ?" +
                "), " +
                "product_list AS (" +
                "    SELECT p.id, p.price, p.image, p.description, p.views " +
                "    FROM product p WHERE p.owner_id = (SELECT id FROM user_info)" +
                ")" +
                "SELECT json_build_object(" +
                // ... Rest of the SQL
                ");";

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                JSONObject jsonObject = new JSONObject(rs.getString(1));

                // Create a new User object and set the fields from the JSON object
                return new User(
                        jsonObject.optString("login_id", null),
                        null, // Password hash is not returned in brief data
                        jsonObject.optString("nickname", null),
                        jsonObject.optString("image", null),
                        jsonObject.has("campus") ? Campus.valueOf(jsonObject.getString("campus")) : null,
                        jsonObject.optString("department", null),
                        jsonObject.has("degree") ? Degree.valueOf(jsonObject.getString("degree")) : null,
                        jsonObject.optString("student_id", "").toCharArray(),
                        null, // Ratings are not returned in brief data
                        false // isAdmin is not part of brief data
                        // Additional fields can be added as per the User class definition
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static JSONObject getProductData(int productId) {
        String sql = "WITH product_info AS (" +
                "    SELECT p.id, p.title, p.price, p.image, p.description, p.views, p.owner_id" +
                "    FROM product p WHERE p.id = ?" +
                ")," +
                "prog AS (" +
                "    SELECT p.progress FROM list_progress p" +
                "    WHERE p.product_id = (SELECT id FROM product_info)" +
                ")," +
                "user_info AS (" +
                "    SELECT u.id, u.nickname, u.image, u.campus, u.department, u.degree, u.student_id" +
                "    FROM akouser u WHERE u.id = (SELECT owner_id FROM product_info)" +
                ")," +
                "hashtags AS (" +
                "    SELECT h.tag" +
                "    FROM hashtag h WHERE h.product_id = (SELECT id FROM product_info)" +
                ")" +
                "SELECT json_build_object(" +
                "    'id', (SELECT id FROM product_info)," +
                "    'title', (SELECT title FROM product_info)," +
                "    'price', (SELECT price FROM product_info)," +
                "    'image', (SELECT image FROM product_info)," +
                "    'description', (SELECT description FROM product_info)," +
                "    'views', (SELECT views FROM product_info)," +
                "    'progress', (SELECT progress FROM prog)," +
                "    'user_info', (SELECT row_to_json(user_info) FROM user_info)," +
                "    'hashtags', array_to_json(array(" +
                "        SELECT * FROM hashtags" +
                "    ))" +
                ");";

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, productId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                String resultString = rs.getString(1);
                return new JSONObject(resultString);
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
    public static JSONArray getWishList(int userId) {
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
                "        'progress', (" +
                "            SELECT l.progress FROM list_progress l WHERE l.product_id = p.id" +
                "        )," +
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

        JSONArray wishlist = new JSONArray();
        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                String resultString = rs.getString(1);
                wishlist = new JSONArray(resultString);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return wishlist;
    }

    public static JSONObject buyRequest(int userId, int productId) {
        JSONObject chatObject = new JSONObject();
        Connection conn = null;

        try {
            conn = PostgreConnect.getStmt().getConnection();
            conn.setAutoCommit(false); // Begin transaction

            // Check if the operation can proceed (user and product exist and no prior progress)
            String checkSql = "SELECT p.id, p.price, p.owner_id, u.id AS buyer_id " +
                    "FROM product p, akouser u " +
                    "WHERE p.id = ? AND u.id = ?";
            PreparedStatement checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setInt(1, productId);
            checkStmt.setInt(2, userId);
            ResultSet checkRs = checkStmt.executeQuery();
            if (!checkRs.next()) {
                throw new SQLException("Product or user does not exist or buy request already made.");
            }
            int price = checkRs.getInt("price");
            int ownerId = checkRs.getInt("owner_id");
            checkRs.close();
            checkStmt.close();

            // Insert into list_progress
            String progressSql = "INSERT INTO list_progress (owner_id, buyer_id, product_id, progress) " +
                    "VALUES (?, ?, ?, 'applied') RETURNING *";
            PreparedStatement progressStmt = conn.prepareStatement(progressSql);
            progressStmt.setInt(1, ownerId);
            progressStmt.setInt(2, userId);
            progressStmt.setInt(3, productId);
            ResultSet progressRs = progressStmt.executeQuery();
            if (!progressRs.next()) {
                throw new SQLException("Unable to insert into list_progress.");
            }
            progressRs.close();
            progressStmt.close();

            // Update payment information
            String paymentSql = "UPDATE payment SET point = point - ? WHERE user_id = ?";
            PreparedStatement paymentStmt = conn.prepareStatement(paymentSql);
            paymentStmt.setInt(1, price);
            paymentStmt.setInt(2, userId);
            paymentStmt.executeUpdate();
            paymentStmt.close();

            // Remove from list_wish if present
            String wishSql = "DELETE FROM list_wish WHERE buyer_id = ? AND product_id = ?";
            PreparedStatement wishStmt = conn.prepareStatement(wishSql);
            wishStmt.setInt(1, userId);
            wishStmt.setInt(2, productId);
            wishStmt.executeUpdate();
            wishStmt.close();

            // Insert into list_chat and return chat details
            String chatSql = "INSERT INTO list_chat (user1, user2) VALUES (?, ?) RETURNING *";
            PreparedStatement chatStmt = conn.prepareStatement(chatSql);
            chatStmt.setInt(1, ownerId);
            chatStmt.setInt(2, userId);
            ResultSet chatRs = chatStmt.executeQuery();
            if (chatRs.next()) {
                chatObject.put("id", chatRs.getInt("id"));
                chatObject.put("user1", chatRs.getInt("user1"));
                chatObject.put("user2", chatRs.getInt("user2"));
                chatObject.put("last_time", chatRs.getTimestamp("last_time"));
            } else {
                throw new SQLException("Unable to insert into list_chat.");
            }
            chatRs.close();
            chatStmt.close();

            conn.commit(); // Commit all changes

        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback(); // Rollback transaction on error
                } catch (SQLException exRollback) {
                    exRollback.printStackTrace();
                }
            }
            return null;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true); // Reset auto-commit
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }

        return chatObject;
    }
    public static JSONArray getBuyRequests(int userId) {
        String sql = "WITH requests AS (" +
                "    SELECT r.id, r.buyer_id, r.product_id, r.progress" +
                "    FROM list_progress r" +
                "    WHERE r.owner_id = ?" +
                ")," +
                "p_info AS (" +
                "    SELECT p.id, p.title, p.price, p.image, p.description, p.views" +
                "    FROM product p" +
                "    WHERE p.id IN (" +
                "        SELECT r.product_id FROM requests r" +
                "        WHERE r.progress = 'applied'" +
                "    )" +
                ")" +
                "SELECT json_build_object(" +
                "    'id', (SELECT id FROM requests)," +
                "    'buyer_id', (SELECT buyer_id FROM requests)," +
                "    'products', (SELECT row_to_json(p_info) FROM p_info)" +
                ");";

        JSONArray buyRequests = new JSONArray();

        try (Connection conn = PostgreConnect.getStmt().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                JSONObject buyRequest = new JSONObject(rs.getString(1));
                buyRequests.put(buyRequest);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return buyRequests;
    }

    public static boolean acceptBuyRequest(int userId, int productId, String message) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean success = false;

        try {
            conn = PostgreConnect.getStmt().getConnection();
            conn.setAutoCommit(false);

            // Update progress to 'inprogress'
            String updateProgressQuery = "UPDATE list_progress SET progress = 'inprogress' WHERE owner_id = ? AND buyer_id = ? AND product_id = ?";
            pstmt = conn.prepareStatement(updateProgressQuery);
            pstmt.setInt(1, userId);
            pstmt.setInt(2, productId);
            pstmt.setInt(3, productId);
            pstmt.executeUpdate();

            // Update the last chat information in list_chat
            String updateChatQuery = "UPDATE list_chat SET last_chat_idx = last_chat_idx + 1, last_chat = ?, user1_read = CASE WHEN user1 = ? THEN last_chat_idx + 1 ELSE user1_read END, user2_read = CASE WHEN user2 = ? THEN last_chat_idx + 1 ELSE user2_read END WHERE (user1 = ? AND user2 = ?) OR (user2 = ? AND user1 = ?) RETURNING id, last_chat_idx";
            pstmt = conn.prepareStatement(updateChatQuery);
            pstmt.setString(1, message);
            pstmt.setInt(2, userId);
            pstmt.setInt(3, userId);
            pstmt.setInt(4, userId);
            pstmt.setInt(5, productId);
            pstmt.setInt(6, userId);
            pstmt.setInt(7, productId);
            rs = pstmt.executeQuery();

            // Insert into chat table
            if (rs.next()) {
                int chatId = rs.getInt("id");
                int lastChatIdx = rs.getInt("last_chat_idx");
                String insertChatQuery = "INSERT INTO chat (id, idx, message, sender, system) VALUES (?, ?, ?, ?, true)";
                pstmt = conn.prepareStatement(insertChatQuery);
                pstmt.setInt(1, chatId);
                pstmt.setInt(2, lastChatIdx);
                pstmt.setString(3, message);
                pstmt.setInt(4, userId);
                pstmt.executeUpdate();
            }

            conn.commit();
            success = true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException exRollback) {
                    exRollback.printStackTrace();
                }
            }
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }

        return success;
    }

    public static boolean cancelBuyRequest(int userId, int productId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean success = false;

        try {
            conn = PostgreConnect.getStmt().getConnection();
            conn.setAutoCommit(false);

            // Delete from list_progress
            String deleteProgressQuery = "DELETE FROM list_progress WHERE (owner_id = ? OR buyer_id = ?) AND product_id = ? RETURNING *";
            pstmt = conn.prepareStatement(deleteProgressQuery);
            pstmt.setInt(1, userId);
            pstmt.setInt(2, userId);
            pstmt.setInt(3, productId);
            rs = pstmt.executeQuery();

            // Process the result of the deletion
            if (rs.next()) {
                int buyerId = rs.getInt("buyer_id");

                // Update payment for the buyer
                String updatePaymentQuery = "UPDATE payment SET point = point + (SELECT price FROM product WHERE id = ?) WHERE user_id = ?";
                pstmt = conn.prepareStatement(updatePaymentQuery);
                pstmt.setInt(1, productId);
                pstmt.setInt(2, buyerId);
                pstmt.executeUpdate();

                // Update last chat information in list_chat
                String updateChatQuery = "UPDATE list_chat SET last_chat_idx = last_chat_idx + 1, last_chat = 'User canceled your request', user1_read = CASE WHEN user1 = ? THEN last_chat_idx + 1 ELSE user1_read END, user2_read = CASE WHEN user2 = ? THEN last_chat_idx + 1 ELSE user2_read END WHERE (user1 = ? AND user2 = ?) OR (user2 = ? AND user1 = ?) RETURNING id, last_chat_idx";
                pstmt = conn.prepareStatement(updateChatQuery);
                pstmt.setInt(1, userId);
                pstmt.setInt(2, userId);
                pstmt.setInt(3, userId);
                pstmt.setInt(4, productId);
                pstmt.setInt(5, userId);
                pstmt.setInt(6, productId);
                rs = pstmt.executeQuery();

                // Insert into chat table
                if (rs.next()) {
                    int chatId = rs.getInt("id");
                    int lastChatIdx = rs.getInt("last_chat_idx");
                    String insertChatQuery = "INSERT INTO chat (id, idx, message, sender, system) VALUES (?, ?, ?, ?, true)";
                    pstmt = conn.prepareStatement(insertChatQuery);
                    pstmt.setInt(1, chatId);
                    pstmt.setInt(2, lastChatIdx);
                    pstmt.setString(3, "User canceled your request");
                    pstmt.setInt(4, userId);
                    pstmt.executeUpdate();
                }
            }

            conn.commit();
            success = true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException exRollback) {
                    exRollback.printStackTrace();
                }
            }
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }

        return success;
    }

    public static boolean confirmGive(int productId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean success = false;

        try {
            conn = PostgreConnect.getStmt().getConnection();
            conn.setAutoCommit(false);

            // Update list_progress to 'soldout'
            String updateProgressQuery = "UPDATE list_progress SET progress = 'soldout' WHERE progress = 'inprogress' AND product_id = ? RETURNING *";
            pstmt = conn.prepareStatement(updateProgressQuery);
            pstmt.setInt(1, productId);
            rs = pstmt.executeQuery();

            // Process the result of the update
            if (rs.next()) {
                int ownerId = rs.getInt("owner_id");

                // Update last chat information in list_chat
                String updateChatQuery = "UPDATE list_chat SET last_chat_idx = last_chat_idx + 1, last_chat = 'Seller have confirmed that he(she) has given you the product', user1_read = CASE WHEN user1 = ? THEN last_chat_idx + 1 ELSE user1_read END, user2_read = CASE WHEN user2 = ? THEN last_chat_idx + 1 ELSE user2_read END WHERE user1 = ? OR user2 = ? RETURNING id, last_chat_idx";
                pstmt = conn.prepareStatement(updateChatQuery);
                pstmt.setInt(1, ownerId);
                pstmt.setInt(2, ownerId);
                pstmt.setInt(3, ownerId);
                pstmt.setInt(4, ownerId);
                rs = pstmt.executeQuery();

                // Insert into chat table
                if (rs.next()) {
                    int chatId = rs.getInt("id");
                    int lastChatIdx = rs.getInt("last_chat_idx");
                    String insertChatQuery = "INSERT INTO chat (id, idx, message, sender, system) VALUES (?, ?, ?, ?, true)";
                    pstmt = conn.prepareStatement(insertChatQuery);
                    pstmt.setInt(1, chatId);
                    pstmt.setInt(2, lastChatIdx);
                    pstmt.setString(3, "Seller have confirmed that he(she) has given you the product");
                    pstmt.setInt(4, ownerId);
                    pstmt.executeUpdate();
                }
            }

            conn.commit();
            success = true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException exRollback) {
                    exRollback.printStackTrace();
                }
            }
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }

        return success;
    }

    public static boolean confirmGot(int productId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean success = false;

        try {
            conn = PostgreConnect.getStmt().getConnection();
            conn.setAutoCommit(false);

            // Delete from list_progress where progress is 'soldout'
            String deleteProgressQuery = "DELETE FROM list_progress WHERE progress = 'soldout' AND product_id = ? RETURNING *";
            pstmt = conn.prepareStatement(deleteProgressQuery);
            pstmt.setInt(1, productId);
            rs = pstmt.executeQuery();

            // Process the result of the deletion
            if (rs.next()) {
                int ownerId = rs.getInt("owner_id");
                int buyerId = rs.getInt("buyer_id");

                // Insert into list_trade
                String insertTradeQuery = "INSERT INTO list_trade (owner_id, buyer_id, product_id) VALUES (?, ?, ?)";
                pstmt = conn.prepareStatement(insertTradeQuery);
                pstmt.setInt(1, ownerId);
                pstmt.setInt(2, buyerId);
                pstmt.setInt(3, productId);
                pstmt.executeUpdate();

                // Update last chat information in list_chat
                String updateChatQuery = "UPDATE list_chat SET last_chat_idx = last_chat_idx + 1, last_chat = 'Seller have confirmed that he(she) has given you the product', user1_read = CASE WHEN user1 = ? THEN last_chat_idx + 1 ELSE user1_read END, user2_read = CASE WHEN user2 = ? THEN last_chat_idx + 1 ELSE user2_read END WHERE (user1 = ? AND user2 = ?) OR (user2 = ? AND user1 = ?) RETURNING id, last_chat_idx";
                pstmt = conn.prepareStatement(updateChatQuery);
                pstmt.setInt(1, buyerId);
                pstmt.setInt(2, buyerId);
                pstmt.setInt(3, ownerId);
                pstmt.setInt(4, buyerId);
                pstmt.setInt(5, ownerId);
                pstmt.setInt(6, buyerId);
                rs = pstmt.executeQuery();

                // Insert into chat table
                if (rs.next()) {
                    int chatId = rs.getInt("id");
                    int lastChatIdx = rs.getInt("last_chat_idx");
                    String insertChatQuery = "INSERT INTO chat (id, idx, message, sender, system) VALUES (?, ?, ?, ?, true)";
                    pstmt = conn.prepareStatement(insertChatQuery);
                    pstmt.setInt(1, chatId);
                    pstmt.setInt(2, lastChatIdx);
                    pstmt.setString(3, "Seller have confirmed that he(she) has given you the product");
                    pstmt.setInt(4, ownerId);
                    pstmt.executeUpdate();
                }
            }

            conn.commit();
            success = true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException exRollback) {
                    exRollback.printStackTrace();
                }
            }
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }

        return success;
    }

    public static JSONArray getChatPreview(int userId) {
        JSONArray chatPreviews = new JSONArray();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = PostgreConnect.getStmt().getConnection();
            String query = "SELECT * FROM list_chat WHERE user1 = ? OR user2 = ?";
            pstmt = conn.prepareStatement(query);
            pstmt.setInt(1, userId);
            pstmt.setInt(2, userId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                JSONObject chatPreview = new JSONObject();
                // Add all necessary fields to JSON object
                chatPreview.put("id", rs.getInt("id"));
                chatPreview.put("user1", rs.getInt("user1"));
                chatPreview.put("user2", rs.getInt("user2"));
                // Add other fields as needed

                chatPreviews.put(chatPreview);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }

        return chatPreviews;
    }

    public static JSONArray getChat(int chatId) {
        JSONArray chatMessages = new JSONArray();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = PostgreConnect.getStmt().getConnection();
            String query = "SELECT * FROM chat WHERE id = ?";
            pstmt = conn.prepareStatement(query);
            pstmt.setInt(1, chatId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                JSONObject chatMessage = new JSONObject();
                // Add all necessary fields to JSON object
                chatMessage.put("idx", rs.getInt("idx"));
                chatMessage.put("message", rs.getString("message"));
                chatMessage.put("sender", rs.getInt("sender"));
                // Add other fields as needed

                chatMessages.put(chatMessage);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }

        return chatMessages;
    }

    public static boolean sendChat(int userId, int chatId, String message) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean success = false;

        try {
            conn = PostgreConnect.getStmt().getConnection();
            conn.setAutoCommit(false);

            // Update list_chat with the new message
            String updateChatQuery = "UPDATE list_chat SET last_chat_idx = last_chat_idx + 1, last_chat = ?, user1_read = CASE WHEN user1 = ? THEN last_chat_idx + 1 ELSE user1_read END, user2_read = CASE WHEN user2 = ? THEN last_chat_idx + 1 ELSE user2_read END WHERE id = ? RETURNING last_chat_idx";
            pstmt = conn.prepareStatement(updateChatQuery);
            pstmt.setString(1, message);
            pstmt.setInt(2, userId);
            pstmt.setInt(3, userId);
            pstmt.setInt(4, chatId);
            rs = pstmt.executeQuery();

            // Insert the new message into chat table
            if (rs.next()) {
                int lastChatIdx = rs.getInt("last_chat_idx");
                String insertChatQuery = "INSERT INTO chat (id, idx, message, sender) VALUES (?, ?, ?, ?)";
                pstmt = conn.prepareStatement(insertChatQuery);
                pstmt.setInt(1, chatId);
                pstmt.setInt(2, lastChatIdx);
                pstmt.setString(3, message);
                pstmt.setInt(4, userId);
                pstmt.executeUpdate();
            }

            conn.commit();
            success = true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException exRollback) {
                    exRollback.printStackTrace();
                }
            }
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }

        return success;
    }

    public static JSONArray search(double hWeight, double tWeight, double dWeight, String[] keywords, String pattern) {
        JSONArray searchResults = new JSONArray();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = PostgreConnect.getStmt().getConnection();

            StringJoiner keywordJoiner = new StringJoiner(",");
            for (String keyword : keywords) {
                keywordJoiner.add("'" + keyword + "'");
            }

            String query = "WITH h_score AS ( "
                    + "SELECT s.id, COUNT(s.id) AS score FROM ( "
                    + "SELECT h.product_id AS id FROM hashtag h "
                    + "WHERE h.tag = ANY(ARRAY[" + keywordJoiner.toString() + "]) "
                    + ") s GROUP BY s.id), "
                    + "t_score AS (SELECT id, 1 AS score FROM ( "
                    + "SELECT p.id AS id FROM product p "
                    + "WHERE p.title LIKE '%" + pattern + "%') t), "
                    + "d_score AS (SELECT id, score FROM ( "
                    + "SELECT ts_rank_cd(to_tsvector(p.description), to_tsquery('" + pattern + "')) AS score, p.id "
                    + "FROM product p) d), "
                    + "product_ids AS (SELECT id FROM h_score UNION SELECT id FROM t_score UNION SELECT id FROM d_score) "
                    + "SELECT p.id, p.title, p.price, p.image, p.description, p.views, p.owner_id, "
                    + "((COALESCE((SELECT score FROM h_score WHERE h_score.id=p.id), 0) * " + hWeight + ") + "
                    + "(COALESCE((SELECT score FROM t_score WHERE t_score.id=p.id), 0) * " + tWeight + ") + "
                    + "(COALESCE((SELECT score FROM d_score WHERE d_score.id=p.id), 0) * " + dWeight + ")) AS score "
                    + "FROM product p WHERE p.id=ANY(SELECT id FROM product_ids) "
                    + "ORDER BY score DESC";

            pstmt = conn.prepareStatement(query);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                JSONObject product = new JSONObject();
                product.put("id", rs.getInt("id"));
                product.put("title", rs.getString("title"));
                product.put("price", rs.getInt("price"));
                product.put("image", rs.getString("image"));
                product.put("description", rs.getString("description"));
                product.put("views", rs.getLong("views"));
                product.put("owner_id", rs.getInt("owner_id"));
                product.put("score", rs.getDouble("score"));

                searchResults.put(product);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }

        return searchResults;
    }
}
