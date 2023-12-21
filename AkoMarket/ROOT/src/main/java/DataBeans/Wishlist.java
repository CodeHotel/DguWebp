package DataBeans;

public class Wishlist {
    public Product product;
    public User user;

    public Wishlist(Product product, User user, Progress progress) {
        this.product = product;
        this.user = user;
    }
}
