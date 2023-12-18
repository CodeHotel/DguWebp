package DataBeans;

public class ProgressData {
    public int id;
    public User user;
    public Product product;
    public Progress progress;

    public ProgressData(int id, User user, Product product, Progress progress) {
        this.id = id;
        this.user = user;
        this.product = product;
        this.progress = progress;
    }
}