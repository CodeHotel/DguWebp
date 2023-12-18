package DataBeans;

public class Product {
    private int id;
    private String title;
    private int price;
    private String image;
    private String description;
    private long views;
    private int ownerId;
    private String[] hashtags;

    private Progress progress;

    public Product(int id, String title, int price, String image, String description, long views, int ownerId, String[] hashtags, Progress progress){
        this.id = id;
        this.title = title;
        this.price = price;
        this.image = image;
        this.description=description;
        this.views = views;
        this.ownerId = ownerId;
        this.hashtags = hashtags;
        this.progress = progress;
    }

    public int getId() {return id;}
    public String getTitle() {return title;}
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
    public String[] getHashtags() {return hashtags;}
    public void setHashtags(String[] hashtags) {this.hashtags = hashtags;}

    public Progress getProgress() {return progress;}
}