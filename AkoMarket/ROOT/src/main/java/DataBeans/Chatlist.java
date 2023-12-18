package DataBeans;

import java.sql.Timestamp;

public class Chatlist {
    private int id;
    private int user1;
    private int user2;
    private String time;

    public Chatlist(int id, int user1, int user2, String time) {
        this.id = id;
        this.user1 = user1;
        this.user2 = user2;
        this.time = time;
    }

    public int getId() {
        return id;
    }

    public int getUser1() {
        return user1;
    }

    public int getUser2() {
        return user2;
    }

    public String getTime() {
        return time;
    }
}
