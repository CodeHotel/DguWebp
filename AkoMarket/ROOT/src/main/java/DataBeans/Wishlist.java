package DataBeans;

public class Wishlist {
    Product product;
    User user;

    public Wishlist(Product product, User user, Progress progress) {
        this.product = product;
        this.user = user;
    }
}
