package DataBeans;

public class Chatlist {
    public int id;
    public int user1;
    public int user2;
    public int user1_read;
    public int user2_read;
    public String last_msg;
    public int last_idx;
    public String time;

    public Chatlist(int id, int user1, int user2, int user1_read, int user2_read, String last_msg, int last_idx, String time) {
        this.id = id;
        this.user1 = user1;
        this.user2 = user2;
        this.user1_read = user1_read;
        this.user2_read = user2_read;
        this.last_msg = last_msg;
        this.last_idx = last_idx;
        this.time = time;
    }
}
