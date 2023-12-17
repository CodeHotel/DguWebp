package DataBeans;

public class Product {
    private int id;
    private int price;
    private String image;
    private String description;
    private long views;
    private int ownerId;

    public Product(){}
    public Product(int id, int price, String image, String description, long views, int ownerId){
        this.id=id; this.price=price; this.image=image; this.description=description;
        this.views=views; this.ownerId=ownerId;
    }
    public Product(int price, String image, String description, long views, int ownerId){
        this.price=price; this.image=image; this.description=description;
        this.views=views; this.ownerId=ownerId;
    }

    public int getId() {return id;}
    public int getPrice() {return price;}
    public void setPrice(int newPrice) {price = newPrice;}
    public String getDescription() {return description;}
    public void setDescription(String newDescription) {description = newDescription;}
    public String getImage() {return image;}
    public void setImage(String newImage) {image = newImage;}
    public long getViews() {return views;}
    public void setViews(long newViews) {views = newViews;}
    public int getOwnerId() {return ownerId;}
    public void setOwnerId(int newOwnerId) {ownerId = newOwnerId;}
}
