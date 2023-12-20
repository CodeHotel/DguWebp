package DataBeans;

import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAccessType;

@XmlRootElement
@XmlAccessorType(XmlAccessType.FIELD) // Use field-based access
public class ChatsXml {
    @XmlElement(name = "chats")
    private ChatXml[] chats;
    public ChatsXml() {}

    public ChatsXml(ChatListXml[] chatList) {
        this.chats = chats;
    }

    // No need to annotate getters and setters
    public ChatXml[] getChatList() {
        return chats;
    }

    public void setChatList(ChatXml[] chatList) {
        this.chats = chatList;
    }
}
