package DataBeans;

import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAccessType;

@XmlRootElement
@XmlAccessorType(XmlAccessType.FIELD) // Use field-based access
public class ChatListXmlWrapper {
    @XmlElement(name = "chatList")
    private ChatListXml[] chatList;

    public ChatListXmlWrapper() {}

    public ChatListXmlWrapper(ChatListXml[] chatList) {
        this.chatList = chatList;
    }

    // No need to annotate getters and setters
    public ChatListXml[] getChatList() {
        return chatList;
    }

    public void setChatList(ChatListXml[] chatList) {
        this.chatList = chatList;
    }
}
