package DataBeans;

enum Campus {
    seoul, goyang, WISE
}

enum Degree {
    undergraduate, postgraduate, professor, staff
}

enum Progress {
    none, applied, inprogress, soldout, sellergive, buyergot
}

public class User {
    private int id;
    private String loginId;
    private String pwHash;
    private String nickName;
    private String image;
    private Campus campus;
    private String department;
    private Degree degree;
    private char[] studentId = new char[10];
    private double[] rating;
    private boolean isAdmin;

    // Full parameter constructor (except uid)
    public User(int id, String loginId, String pwHash, String nickName, String image, Campus campus, String department, Degree degree, char[] studentId, double[] rating, boolean isAdmin) {
        this.id = id;
        this.loginId = loginId;
        this.pwHash = pwHash;
        this.nickName = nickName;
        this.image = image;
        this.campus = campus;
        this.department = department;
        this.degree = degree;
        this.studentId = studentId;
        this.rating = rating;
        this.isAdmin = isAdmin;
    }

    // Getters and setters (except for uid)
    public String getLoginId() { return loginId; }
    public void setLoginId(String loginId) { this.loginId = loginId; }

    public String getPwHash() { return pwHash; }
    public void setPwHash(String pwHash) { this.pwHash = pwHash; }

    public String getNickName() { return nickName; }
    public void setNickName(String nickName) { this.nickName = nickName; }

    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }

    public Campus getCampus() { return campus; }
    public void setCampus(Campus campus) { this.campus = campus; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public Degree getDegree() { return degree; }
    public void setDegree(Degree degree) { this.degree = degree; }

    public char[] getStudentId() { return studentId; }
    public void setStudentId(char[] studentId) { this.studentId = studentId; }

    public double[] getRating() { return rating; }
    public void setRating(double[] rating) { this.rating = rating; }

    public boolean isAdmin() { return isAdmin; }
    public void setAdmin(boolean isAdmin) { this.isAdmin = isAdmin; }

    public int getUid() { return id; }
}
