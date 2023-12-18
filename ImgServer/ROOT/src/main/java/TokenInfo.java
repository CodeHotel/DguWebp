public class TokenInfo {
    private String token;
    private String imageName;
    private long timestamp;
    private boolean accessed;

    public TokenInfo(String token, String imageName) {
        this.token = token;
        this.imageName = imageName;
        this.timestamp = System.currentTimeMillis();
        this.accessed = false;
    }

    public boolean isAccessed() {
        return accessed;
    }

    public boolean isExpired() {
        // 5 minutes in milliseconds
        long fiveMinutesInMillis = 5 * 60 * 1000;
        // Check if current time is greater than timestamp + 5 minutes
        return System.currentTimeMillis() > (timestamp + fiveMinutesInMillis);
    }

    public String getImageName() {
        return imageName;
    }

    public String getToken() {
        return token;
    }

    // Setter for accessed
    public void setAccessed(boolean accessed) {
        this.accessed = accessed;
    }
}
