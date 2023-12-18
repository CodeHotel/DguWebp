package DataBeans;

import java.sql.Timestamp;

public class Chat {
    private String message;
    private int sender;
    private String time;
    private boolean system;
    private int id;
    private int idx;

    // Full parameter constructor (excluding id and idx)
    public Chat(int id, int idx, String message, int sender, String time, boolean system) {
        this.id = id;
        this.idx = idx;
        this.message = message;
        this.sender = sender;
        this.time = time;
        this.system = system;
    }

    // Getters and setters (excluding id and idx)
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public int getSender() { return sender; }
    public void setSender(int sender) { this.sender = sender; }

    public String getTime() { return time; }
    public void setTime(String time) { this.time = time; }

    public boolean isSystem() { return system; }
    public void setSystem(boolean system) { this.system = system; }

    public int getId() { return id; }
    // No setter for id

    public int getIdx() { return idx; }
    // No setter for idx
}
