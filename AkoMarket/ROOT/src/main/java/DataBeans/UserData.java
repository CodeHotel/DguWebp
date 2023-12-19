package DataBeans;

public class UserData {
    public User user;
    public Product[] products;

    public UserData(User user, Product[] products) {
        this.user = user;
        this.products = products;
    }
}
